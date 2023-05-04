Start-Transcript -LiteralPath C:\temp\MBX-KVK-MIG.txt | Out-Null
Write-Host ""

Add-PSsnapin *Exchange*
Import-Module ActiveDirectory

Write-Host "The following @KVKNET.COM Contacts will be delted from Exchange..." -ForegroundColor Cyan
Write-Host ""

$Contacts = Get-MailContact | Where-Object { $_.WindowsEmailAddress -like "*@kvknet.com" } | Select DisplayName, WindowsEmailAddress, RecipientTypeDetails | Sort DisplayName | ft -AutoSize -Wrap
$Contacts | Remove-MailContact -Verbose

Write-Host ""
Write-Host "Creating Linked accounts in Exchange..." -ForegroundColor Cyan
Write-Host ""

$KVKUsers = Get-ADUser -Filter * -SearchBase "OU=KVK Users,DC=kvk,DC=local" -Server "KVK-DC01.kvk.local"

foreach ($User in $KVKUsers){

    $HashArguments = @{
      Name                   = $User.Name
      FirstName              = $User.GivenName
      LastName               = $User.Surname
      DisplayName            = $User.Name
      Alias                  = $User.SamAccountName
      SamAccountName         = $User.SamAccountName
      LinkedMasterAccount    = $User.SamAccountName
      LinkedDomainController = "KVK-DC01.kvk.local"
      OrganizationalUnit     = "OU=Users,OU=KVK,DC=CSI,DC=local"
      UserPrincipalName      = $($User.SamAccountName) + "@CSI.local"
      DataBase               = "Mailbox Database 1545820479"
    }

    New-Mailbox @HashArguments -Verbose
}

Stop-Transcript