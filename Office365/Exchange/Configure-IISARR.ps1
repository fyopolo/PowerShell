Add-PSsnapin *Exchange* -ErrorAction SilentlyContinue
Import-Module WebAdministration -ErrorAction SilentlyContinue

$Date = (Get-Date).ToString('dd-MM-yyyy')
$TranscriptFileName = "C:\TEMP\" + "CSR-VirtualDirectories" + "_" + $Date + ".txt"

Start-Transcript -LiteralPath $TranscriptFileName # | Out-Null
Write-Host "" # Output for Transcript

#   Setting IIS Basics
$SiteName = "OWA-CSR"                     # Website Name
$SiteFolder = "C:\TestWebSite\OWA-CSR"    # Website Root Folder
$LogPath = "C:\TestWebSite\OWA-CSR\Log"   # Log Folder
$OWAFolder = "C:\TestWebSite\OWA-CSR\OWA" # OWA Folder
$ECPFolder = "C:\TestWebSite\OWA-CSR\ECP" # ECP Folder
$SiteHostName = "owa-csr.hq.eiweb.local"  # Host Header

$MultiRoleServers = "BUECUSRV-MX02"
# $MultiRoleServers = Get-ExchangeServer | Where-Object {$_.ServerRole -notcontains "Edge"}

#   Virtual Directories - PROD
# $OWA = "https://owa-csr.dtvpan.com/owa"
# $ECP = "https://owa-csr.dtvpan.com/ecp"

#   Virtual Directories - TEST
# $Port = ":8024"
$OWA = "https://owa-csr.hq.eiweb.local/owa"
$ECP = "https://owa-csr.hq.eiweb.local/ecp"

Write-Host "Found $($MultiRoleServers.Count) Multi-role servers" -BackgroundColor Gray

foreach ($Server in $MultiRoleServers){
    
    # $RemoteSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://$Server.dtvpan.com/powershell" -AllowRedirection
    # $RemoteSession = New-PSSession -ComputerName $Server -ConfigurationName Microsoft.Exchange

    Write-Host "Working on $Server" -BackgroundColor Gray
    
#   Checking Folders for hosting IIS Site
    Invoke-Command -ComputerName $Server -ScriptBlock {
        param($RSiteFolder,$RLogPath,$ROWAFolder,$RECPFolder)
    
            IF (-NOT (Get-ChildItem $RSiteFolder -Recurse -Directory -ErrorAction SilentlyContinue)){

                Write-Host "Creating WebSite folders..." -BackgroundColor Gray
                New-Item $RSiteFolder -ItemType Directory
                New-Item $RLogPath -ItemType Directory # -ErrorAction SilentlyContinue
                # New-Item $ROWAFolder -ItemType Directory # -ErrorAction SilentlyContinue
                # New-Item $RECPFolder -ItemType Directory # -ErrorAction SilentlyContinue
                Write-Host "Folders Created"
                Write-Host ""
                Write-Host "Copying files..." -BackgroundColor Gray
                Copy-Item "$env:SystemDrive\inetpub\wwwroot\*" -Destination $RSiteFolder -Recurse -Verbose
                Copy-Item "$env:ExchangeInstallPath\FrontEnd\HttpProxy\owa" -Destination $RSiteFolder -Recurse -Verbose
                Copy-Item "$env:ExchangeInstallPath\FrontEnd\HttpProxy\ecp" -Destination $RSiteFolder -Recurse -Verbose
                Write-Host "Files copied"

                #   Setting NTFS permissions for 'BUILTIN\IIS_IUSRS' local group
                $ACL = Get-Acl $RSiteFolder
                $User = "BUILTIN\IIS_IUSRS"
                $ACLrule = New-Object System.Security.AccessControl.FileSystemAccessRule("$User", "ReadAndExecute", "ContainerInherit, ObjectInherit", "None", "Allow")
                $ACL.AddAccessRule($ACLrule)
                Set-Acl $RSiteFolder $ACL

            } # ELSE { Write-Host "Directories already found on disk." -BackgroundColor Gray }
    
    } -ArgumentList $SiteFolder,$LogPath
    
#   Checking IIS WebSite

    Invoke-Command -ComputerName $Server -ScriptBlock {
        param($RSiteName,$RSiteFolder,$RLogPath,$RSiteHostName)
        Import-Module WebAdministration

        $certificate = (Get-ChildItem cert:\LocalMachine\My | where-object { $_.Subject -like "*CN=$env:COMPUTERNAME*" }).Thumbprint
        $WebSite = Get-Website | Select Name

        IF ($WebSite.Name -notcontains $RSiteName){
            Write-Host ""
            Write-Host "Creating IIS WebSite..." -ForegroundColor Cyan
            New-Website -Name $RSiteName -PhysicalPath $RSiteFolder -HostHeader $RSiteHostName -ErrorAction Ignore | Out-Null
            #   Set Website Log Path
            Set-ItemProperty IIS:\Sites\$RSiteName -Name logfile -value @{directory=$RLogPath} -ErrorAction Ignore
            Write-Host "Done"
            Write-Host ""
            Write-Host "Setting bindings..." -ForegroundColor Cyan
            New-WebBinding -Name $RSiteName -IPAddress "*" -HostHeader $RSiteHostName -Port 443 -Protocol https -SslFlags 0
            Write-Host "Done"
            Write-Host ""
            Write-Host "Assigning SSL Certificate..." -ForegroundColor Cyan
            (Get-WebBinding -Name $RSiteName -Port 443 -Protocol "https" -HostHeader $RSiteHostName).AddSslCertificate($certificate, "my")
            Write-Host "Done"
            Write-Host ""
            
            IF ((Get-Website -Name $SiteName).State -eq "Stopped") { Start-Website -Name $RSiteName }

            Write-Host "Restarting IIS service" -ForegroundColor Cyan
            IISReset
            Write-Host "WebSite Up & Running" -BackgroundColor Gray

        } ELSE { Write-Host "WebSite found in IIS. Continuing to Virtual Directories." -BackgroundColor Gray }

    } -ArgumentList $SiteName,$SiteFolder,$LogPath,$SiteHostName

Write-Host "" # Separator

#   Checking Exchange Virtual Directories

    Write-Host "Checking Exchange Virtual Directories..." -ForegroundColor Cyan

    IF (-NOT (Get-OwaVirtualDirectory -Server $Server | Where-Object {$_.WebSite -Contains $SiteName})){

        Write-Host "Creating OWA Virtual Directory..." -ForegroundColor Cyan
        New-OwaVirtualDirectory -Server $Server -WebSiteName "$SiteName” -InternalUrl $OWA -ExternalUrl $OWA | Out-Null

    } ELSE { Write-Host "OWA Virtual Directory found already" -ForegroundColor Green }

    IF (-NOT (Get-EcpVirtualDirectory -Server $Server | Where-Object {$_.WebSite -Contains $SiteName})){

        Write-Host "Creating ECP Virtual Directory..." -ForegroundColor Cyan
        New-EcpVirtualDirectory -Server $Server -WebSiteName "$SiteName” -InternalUrl $ECP -ExternalUrl $ECP | Out-Null

    } ELSE { Write-Host "ECP Virtual Directory found already" -ForegroundColor Green }

}

Write-Host ""
Write-Host "All Set" -BackgroundColor Gray

Stop-Transcript

# Get-OwaVirtualDirectory -Server $Server | Where-Object {$_.WebSite -Contains $SiteName} | Remove-OwaVirtualDirectory
# Get-EcpVirtualDirectory -Server $Server | Where-Object {$_.WebSite -Contains $SiteName} | Remove-EcpVirtualDirectory 

# Get-WebBinding -Name $SiteName | fl