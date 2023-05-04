Import-Module ActiveDirectory

$oldSuffix = Read-Host -Prompt 'Input OLD UPN Suffix'
$newSuffix = Read-Host -Prompt 'Input NEW UPN Suffix'
$OU = "OU=Test,DC=pnl,DC=com"
$server = "DRM-DC-SRV-DC1V"

Get-ADUser -SearchBase $OU -filter *

# Set Object UPN and E-Mail Field
ForEach-Object {
    $newUpn = $_.UserPrincipalName.Replace($oldSuffix,$newSuffix)
    $_ | Set-ADUser -server $server -UserPrincipalName $newUpn
    Set-ADUser -EmailAddress ($_.givenName + '.' + $_.surname + $newSuffix) -Identity $_
}

# Set E-Mail Address Field

#$Server = Read-Host -Prompt 'Input your server  name'
#$User = Read-Host -Prompt 'Input the user name'
#$Date = Get-Date
#Write-Host "You input server '$Servers' and '$User' on '$Date'"