Function Create-SelfSignedCertificate(){

    [CmdletBinding(SupportsShouldProcess=$True)]
    Param
    (
        # Certificate Friendly Name
        [Parameter(ValueFromPipelineByPropertyName=$true,Position=0)]
           [string]
        $FriendlyName = "Meraki Client VPN Authentication"
    )


    $FQDN = [System.Net.Dns]::GetHostByName(($env:COMPUTERNAME)).HostName
    $Cert = New-SelfSignedCertificate -FriendlyName $FriendlyName -DnsName $FQDN -CertStoreLocation "cert:\LocalMachine\My" -KeyExportPolicy Exportable -KeyUsage DigitalSignature, DataEncipherment -KeyLength 2048 -NotAfter (Get-Date).AddYears(6)

    # Exporting Certificate
    $PFXPWD = "Team1990!!"
    $CertPWD = ConvertTo-SecureString -String $PFXPWD -Force -AsPlainText
    $FilePath = "C:\TEMP\" + $FQDN + ".pfx"
    $CertPath = "cert:\LocalMachine\my\" + $Cert.Thumbprint
    Export-PfxCertificate -Cert $CertPath -Password $CertPWD -FilePath $FilePath -ChainOption BuildChain -Force | Out-Null
    
    # Importing Certificate into 'Trusted Root Certification Authorities' store.
    Import-PfxCertificate -FilePath $FilePath -Exportable -Password $CertPWD -CertStoreLocation Cert:\LocalMachine\AuthRoot

    # Deleting Exported Certificate file
    $File = Get-ChildItem -Path C:\TEMP -Filter $($FQDN + ".pfx")
    Remove-Item -Path $File.FullName

    <#
        Certificate Requirements for TLS:
        https://documentation.meraki.com/MX/Content_Filtering_and_Threat_Protection/Configuring_Active_Directory_with_MX_Security_Appliances#Certificate_Requirements_for_TLS
    #>

}

Create-SelfSignedCertificate