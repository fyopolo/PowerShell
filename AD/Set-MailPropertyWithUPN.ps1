Import-Module ActiveDirectory

$ADUsers = Get-ADUser -LDAPFilter '(userPrincipalName=*)' -Properties UserPrincipalName,mail | Select-Object *

foreach ($User in $ADUsers){

    Set-ADObject -Identity $User.DistinguishedName -Replace @{mail=$($User.userPrincipalName)}

}