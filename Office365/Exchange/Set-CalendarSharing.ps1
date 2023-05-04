<# 
$credential = Get-Credential
Import-Module MsOnline
Connect-MsolService -Credential $credential
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
Import-PSSession $exchangeSession -DisableNameChecking
#>

# https://docs.microsoft.com/en-us/powershell/module/exchange/mailboxes/add-mailboxfolderpermission?view=exchange-ps


$Recipients = Get-Mailbox -ResultSize Unlimited | Where-Object {$_.RecipientTypeDetails -eq "UserMailbox"}

foreach ($User in $Recipients){
    
    Write-Host "Working on $User" -ForegroundColor Cyan
    $Identity = $User.UserPrincipalName + ":\Calendar"
    $CalendarUser = $User.DisplayName
    $Calendar = Get-MailboxFolderPermission -Identity $Identity

    IF($Calendar.User.DisplayName -like '*$CalendarUser*'){
    write-host "TRUE"
    }

    $Hash

}

# Get-MailboxFolderPermission -Identity smercado@nahq.org:\Calendar