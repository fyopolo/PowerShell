Function Create-SelfSignedCertificate(){

    [CmdletBinding(SupportsShouldProcess=$True)]
    Param
    (
        # Certificate Friendly Name
        [Parameter(ValueFromPipelineByPropertyName=$true,Position=0)]
           [string]
        $FriendlyName = "Hyper-V Replication"
    )


    $FQDN = [System.Net.Dns]::GetHostByName(($env:COMPUTERNAME)).HostName
    $Cert = New-SelfSignedCertificate -FriendlyName "Hyper-V Replica Service" -DnsName "DCSERVER11.dsgn.com","DCASERVER10.dsgn.com" -CertStoreLocation "cert:\LocalMachine\My" -KeyExportPolicy Exportable -KeyUsage KeyEncipherment, DataEncipherment -KeyLength 2048 -NotAfter (Get-Date).AddYears(10)
    $Cert = New-SelfSignedCertificate -FriendlyName $FriendlyName -DnsName "remote.marigold.local",$FQDN -CertStoreLocation "cert:\LocalMachine\My" -KeyExportPolicy Exportable -KeyUsage KeyEncipherment, DataEncipherment -KeyLength 2048 -NotAfter (Get-Date).AddYears(6)

    # Exporting Certificate
    $PFXPWD = "Team1990!!"
    $CertPWD = ConvertTo-SecureString -String $PFXPWD -Force -AsPlainText
    $FilePath = "C:\TEMP\" + "DCSERVER11.dsgn.com" + ".pfx"
    $CertPath = "cert:\LocalMachine\my\" + $Cert.Thumbprint
    Export-PfxCertificate -Cert $CertPath -Password $CertPWD -FilePath $FilePath -ChainOption BuildChain -Force | Out-Null
    
    # Importing Certificate into 'Trusted Root Certification Authorities' store.
    Import-PfxCertificate -FilePath $FilePath -Exportable -Password $CertPWD -CertStoreLocation Cert:\LocalMachine\AuthRoot

    # Deleting Exported Certificate file
    # $File = Get-ChildItem -Path C:\TEMP -Filter $("DCSERVER11.dsgn.com" + ".pfx")
    # Remove-Item -Path $File.FullName

    <#
        Certificate Requirements for TLS:
        https://documentation.meraki.com/MX/Content_Filtering_and_Threat_Protection/Configuring_Active_Directory_with_MX_Security_Appliances#Certificate_Requirements_for_TLS
    #>

}

Create-SelfSignedCertificate


############ WORKING ############

New-SelfSignedCertificate -Type "Custom" -KeyExportPolicy "Exportable" -Subject "Hyper-V CA" -CertStoreLocation "Cert:\LocalMachine\My" -KeySpec "Signature" -KeyUsage "CertSign" -NotAfter (Get-Date).AddDays(10000)

New-SelfSignedCertificate -type "Custom" -KeyExportPolicy "Exportable" -Subject "CN=DCSERVER10.dsgn.com" -CertStoreLocation "Cert:\LocalMachine\My" -KeySpec "KeyExchange" -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.1,1.3.6.1.5.5.7.3.2") -Signer "Cert:LocalMachine\My\cbae10bd2ce0fc85467d4d1ef7eb6ec9b3e3814e" -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" -NotAfter (Get-Date).AddYears(10)

New-SelfSignedCertificate -type "Custom" -KeyExportPolicy "Exportable" -Subject "CN=DCSERVER11" -CertStoreLocation "Cert:\LocalMachine\My" -KeySpec "KeyExchange" -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.1,1.3.6.1.5.5.7.3.2") -Signer "Cert:LocalMachine\My\cbae10bd2ce0fc85467d4d1ef7eb6ec9b3e3814e" -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" -NotAfter (Get-Date).AddYears(10)



    $PFXPWD = "Team1990!!"
    $CertPWD = ConvertTo-SecureString -String $PFXPWD -Force -AsPlainText
    $FilePath = "C:\TEMP\" + "DCSERVER11" + ".pfx"
    $CertPath = "cert:\LocalMachine\my\" + "1491e1e4fca8fc4183bdc1bebe1c0c0f40f60eaa"
    Export-PfxCertificate -Cert $CertPath -Password $CertPWD -FilePath $FilePath -ChainOption BuildChain -Force | Out-Null