
<#

$credential = Get-Credential -Message "Enter Global Admin credentials"
Import-Module MsOnline
Connect-MsolService -Credential $credential
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
Import-PSSession $exchangeSession -DisableNameChecking

Add-PSSnapin *Exchange*

#>

$O365SignInInfo = Get-MsolUser | Where-Object {$_.UserPrincipalName -like "*@langenfeld.com*" } | Select UserPrincipalName | Sort

foreach ($CloudIdentity in $O365SignInInfo){

    $Flag = 0
    
    $O365Alias = ($CloudIdentity.UserPrincipalName).TrimEnd("@langenfeld.com")
    $LocalMBX = Get-Mailbox -Server $env:COMPUTERNAME | Where-Object { $_.PrimarySMTPAddress -eq $CloudIdentity -or $_.Alias -eq $O365Alias}
    
    foreach ($SMTPAddress in $LocalMBX.EmailAddresses){ IF ($SMTPAddress.SmtpAddress -eq $CloudIdentity.UserPrincipalName){ $Flag = 1 } }

    IF (-NOT($Flag -eq 1)){
        Write-Host "Adding On-Prem alias: $($CloudIdentity.UserPrincipalName)" -ForegroundColor Cyan
        Get-Mailbox $CloudIdentity.UserPrincipalName | Set-Mailbox -EmailAddresses @{add=$($CloudIdentity.UserPrincipalName)}
    }
}