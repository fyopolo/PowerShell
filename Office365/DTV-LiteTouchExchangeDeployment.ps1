# Header Settings

$PreReqBasePath    = "C:\Instaladores\"
$ImagePath         = "C:\Instaladores\SW_DVD9_Exchange_Svr_2016_MultiLang_-11__Std_Ent_.iso_MLF_X21-85570.ISO"
$TranscriptLog     = "C:\Instaladores\ExchangeDeploymentLog.txt"
$ScriptName        = "DTV-LiteTouchExchangeDeployment.PS1"
$ScriptVersion     = "1.0"
$ScriptDescription = "Deploy Exchange Server 2016 Unattended"
$ServerName        = "BUECUSRV-MX02"

$OSProductName      = $((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ProductName)
$OSType             = $((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").InstallationType)
$OSCurrentBuild     = $((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentBuild)
$OSCurrentVersion   = $((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentVersion)
$OSReleaseID        = $((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId)
$OSVersionCode      = @("1511","1607","1703","1709","1803","1809","1903")

IF ($OSReleaseID -lt 1511) { $MarketingName = "N/A" } # Windows 10 Releases
ELSE {
    Switch ($OSReleaseID){

        "1511" {$MarketingName = "- November Update"}
        "1607" {$MarketingName = "- Anniversary Update"}
        "1703" {$MarketingName = "- Creators Update"}
        "1709" {$MarketingName = "- Fall Creators Update"}
        "1803" {$MarketingName = "- April 2018 Update"}
        "1809" {$MarketingName = "- October 2018 Update"}
        "1903" {$MarketingName = "- TBA"}
        Default {$MarketingName = "N/A"}

    }
}

Function Get-FileName()
{   
 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.Title = "Select File"
 $OpenFileDialog.filter = "All files (*.*)| *.*"
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
} #end function


Start-Transcript -LiteralPath $TranscriptLog | Out-Null

$("
Transcript started. Output file is $TranscriptLog

======================================

   TSI-ADEX-Automation Tools

Script Name    : $ScriptName
Script Version : $ScriptVersion
Description    : $ScriptDescription

======================================

Environment INFORMATION:
----------- ------------

Start Time        : $(Get-Date)
User Name         : $env:USERNAME
User Domain       : $env:USERDNSDOMAIN
Computer Name     : $env:COMPUTERNAME
Windows Version   : $OSProductName
Installation Type : $OSType
Current Build     : $OSCurrentBuild
Current Version   : $OSCurrentVersion
Release ID        : $OSReleaseID $MarketingName

======================================

")

#Add Exchange snapin if not already loaded in the PowerShell session
IF (Test-Path $env:ExchangeInstallPath\bin\RemoteExchange.ps1)
{
    . $env:ExchangeInstallPath\bin\RemoteExchange.ps1
    Connect-ExchangeServer -auto -AllowClobber
}
ELSE
{
    Write-Host ""
    Write-Warning "Exchange Server management tools are not installed on this computer. Terminating Script execution."
    Write-Host ""
    Stop-Transcript | Out-Null
    EXIT
}

Write-Host "Checking Prerequisites Files" -BackgroundColor Black

$PreReqFile = (Get-ChildItem -Path $PreReqBasePath).Name
foreach ($File in $PreReqFile)
{
    IF (Test-Path $PreReqBasePath\NDP471-KB4033342-x86-x64-AllOS-ENU.exe)
    {
        Write-Host ".Net Framework Installer found. Launching installation in background." -ForegroundColor Green
        Write-Warning "Please do not interrupt this process!"
        Start-Process $PreReqBasePath + "NDP471-KB4033342-x86-x64-AllOS-ENU.exe" -Wait
    }
    ELSE
    {
        $File = Get-FileName
        Write-Host "Launching $File installation"
    }

}

# Installing Windows Features
IF ($OSType -like "*Server*"){
    Install-WindowsFeature AS-HTTP-Activation, Server-Media-Foundation, NET-Framework-45-Features, RPC-over-HTTP-proxy, RSAT-Clustering, RSAT-Clustering-CmdInterface, RSAT-Clustering-Mgmt, RSAT-Clustering-PowerShell, Web-Mgmt-Console, WAS-Process-Model, Web-Asp-Net45, Web-Basic-Auth, Web-Client-Auth, Web-Digest-Auth, Web-Dir-Browsing, Web-Dyn-Compression, Web-Http-Errors, Web-Http-Logging, Web-Http-Redirect, Web-Http-Tracing, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Lgcy-Mgmt-Console, Web-Metabase, Web-Mgmt-Console, Web-Mgmt-Service, Web-Net-Ext45, Web-Request-Monitor, Web-Server, Web-Stat-Compression, Web-Static-Content, Web-Windows-Auth, Web-WMI, Windows-Identity-Foundation, RSAT-ADDS
}
ELSE {
    Write-Warning "Install-WindowsFeature is not a supported cmdlet in DESKTOP editions."
    $ServerName = Read-Host "Please type the server name you'd like to connect to"
    Write-Host "Attempting to connect to remote computer $ServerName and installing required Windows Features" -BackgroundColor Blue
        Invoke-Command -ComputerName $ServerName -ScriptBlock {
            Install-WindowsFeature AS-HTTP-Activation, Server-Media-Foundation, NET-Framework-45-Features, RPC-over-HTTP-proxy, RSAT-Clustering, RSAT-Clustering-CmdInterface, RSAT-Clustering-Mgmt, RSAT-Clustering-PowerShell, Web-Mgmt-Console, WAS-Process-Model, Web-Asp-Net45, Web-Basic-Auth, Web-Client-Auth, Web-Digest-Auth, Web-Dir-Browsing, Web-Dyn-Compression, Web-Http-Errors, Web-Http-Logging, Web-Http-Redirect, Web-Http-Tracing, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Lgcy-Mgmt-Console, Web-Metabase, Web-Mgmt-Console, Web-Mgmt-Service, Web-Net-Ext45, Web-Request-Monitor, Web-Server, Web-Stat-Compression, Web-Static-Content, Web-Windows-Auth, Web-WMI, Windows-Identity-Foundation, RSAT-ADDS } -ErrorAction Inquire
    }


# $ImagePath = "C:\Instaladores\SW_DVD9_Exchange_Svr_2016_MultiLang_-11__Std_Ent_.iso_MLF_X21-85570.ISO"
$ImagePath = "D:\Apps\Microsoft\SW_DVD5_Visio_Pro_2016_64Bit_English_MLF_X20-42764.ISO"

Mount-DiskImage -ImagePath $ImagePath # Mounting Exchange Server ISO

$ISOVolume = (Get-DiskImage $ImagePath | Get-Volume).DriveLetter + ":" # Storing mounted volume drive letter

$ExArgs1 = @{

}

$ExArgs2 = @()

Start-Process $ISOVolume\Setup.exe -Wait

# Dismount-DiskImage -ImagePath $ImagePath # Dismounting Exchange Server ISO



Stop-Transcript | Out-Null