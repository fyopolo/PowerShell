<#

$credential = Get-Credential -Message "Please supply Global Admin credentials"
Import-Module MsOnline
Connect-MsolService -Credential $credential
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
Import-PSSession $exchangeSession -DisableNameChecking

#>

$DLs = Get-DistributionGroup -ResultSize unlimited

foreach ($O365DL in $DLs)
{  
    Write-Host $O365DL -ForegroundColor Cyan
    $Members = Get-DistributionGroupMember -Identity $O365DL.Identity | Out-Host
}

Get-PSSession | Remove-PSSession

$O365DL

New-DistributionGroup