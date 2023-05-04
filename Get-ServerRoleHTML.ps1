# -------------------------------------------------------------------------------
# Script: Get-ServerRoleHTML.ps1
# Author: Fernando Yopolo
# Date: 12/19/2019
# Keywords: Windows Server, Roles, Features
# Comments: Compose an HTML report of all Windows servers in the environment
#           including their Roles and Software installed. As an alternative
#           output, you can also use Transcript file.
#
# Change Control
# 12/19/2019  Initial Script.
# xx/xx/xxxx  Progress bar added.
# xx/xx/xxxx  Server Features added as a column to the list.
# -------------------------------------------------------------------------------


Function Create-Report {
    $rptFile = "C:\Temp\$Company" + "-ServersAndRolesRPT.htm"
    $rpt | Set-Content -Path $rptFile -Force
    Invoke-Item $rptFile
    sleep 1
}

$Company = Read-Host "Please type Company Name"
$Company = $Company.Replace(" ","-")
$TranscriptFile = "C:\Temp\$Company" + "-ServersAndRoles-Transcript.txt"

Start-Transcript $TranscriptFile

Import-Module ReportHTML
$rpt = @()
$rpt += Get-HTMLOpenPage -TitleText "Installed Server Roles & Software" -LeftLogoString "https://ownakoa.com/wp-content/uploads/2016/09/TeamLogic-IT-Logo.png"
$TABS = @("Overview","Details")
$rpt += Get-HTMLTabHeader -TabNames $TABS

# Getting Enabled computer accounts, whose OS edition starts with "Windows Server"
$Servers = Get-ADComputer -Filter {OperatingSystem -Like "Windows Server*" -and Enabled -eq "True"} -Properties * | Select Name, OperatingSystem, WhenCreated | sort Name

Write-Host "The following objects were found in Active Directory" -ForegroundColor Cyan
$Servers | Format-Table –AutoSize # Console output

# Report TAB 1 "Overview"
$rpt += Get-HTMLTabContentOpen -TabName $TABS.Item(0) -Tabheading (" ")
$rpt+= Get-HtmlContentOpen -HeaderText "Servers found in Active Directory"
    $rpt+= Get-HtmlContentTable $Servers -Fixed
$rpt+= Get-HtmlContentClose
$rpt += Get-HTMLTabContentClose

Write-Host ""
Write-Host "Trying to gather installed server roles..." -ForegroundColor Yellow
Write-Host ""

# Report TAB 2 "Details"
$rpt += Get-HTMLTabContentOpen -TabName $TABS.Item(1) -Tabheading (" ")

foreach ($Computer in $Servers){

    IF (Test-Connection -ComputerName $($Computer.Name) -Quiet) {
        Write-Host "Hostname" $($Computer.Name) -ForegroundColor Cyan
        $Roles = Invoke-Command -ComputerName $($Computer.Name) {Get-WindowsFeature | Where-Object {$_.InstallState -eq 'Installed' -and $_.FeatureType -eq 'Role'}}
        $Roles | Select DisplayName, InstallState, PSComputerName | Format-Table –AutoSize # Console output

        $rpt+= Get-HtmlContentOpen -HeaderText "Hostname: $($Computer.Name)" -IsHidden
            $rpt+= Get-HtmlContentOpen -HeaderText "Roles "
                $rpt+= Get-HtmlContentTable ($Roles | Select DisplayName, InstallState, PSComputerName) -Fixed
            $rpt+= Get-HtmlContentClose

        Write-Host ""
        Write-Host "Getting installed software..." -ForegroundColor Cyan
        $Software = Invoke-Command -ComputerName $($Computer.Name) {Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*}
        $Software | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table –AutoSize # Console output
        Write-Host ""

            $rpt+= Get-HtmlContentOpen -HeaderText "Installed Software"
                $rpt+= Get-HtmlContentTable ($Software | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Sort DisplayName) -Fixed -GroupBy Publisher
            $rpt+= Get-HtmlContentClose
        $rpt+= Get-HtmlContentClose

    } ELSE {
        Write-Warning "Host $($Computer.Name) is not responding to ICMP"
        Write-Host ""
        }
}
$rpt += Get-HTMLTabContentClose
$rpt += Get-HTMLClosePage

Create-Report

Stop-Transcript