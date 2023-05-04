# Import-Module ActiveDirectory

$FQDN = $(Get-ADForest).Name
$Domain = (Get-ADDomain $FQDN | select distinguishedName, pdcEmulator, DNSroot, DomainControllersContainer)
$AllUsersInDomain = Get-ADObject -Filter {(objectClass -eq "user") -and (objectCategory -eq "user")} -Properties * # -SearchBase "OU=Wilson_Albers_&_Company,DC=Corp,DC=aleragroup,DC=com" -SearchScope Subtree
$Array = @()

foreach ($User in $AllUsersInDomain){
            
    IF (-NOT([string]::IsNullOrWhiteSpace($User.LastLogon) -OR ($User.lastLogon -like "*null*"))) { $LastLogon = ($(w32tm /ntte $User.LastLogon) -split " - ",2)[1] } ELSE { $LastLogon = "Never" }
    # $CN = Get-ADObject -LDAPFilter "(objectClass=user)" -Properties CanonicalName

    $Hash = [ordered] @{
        OU                = ($User.CanonicalName).TrimEnd($User.Name).TrimEnd("/").Replace("/"," > ")
        DisplayName       = $User.DisplayName
        SamAccountName    = $User.SamAccountName
        UserPrincipalName = $User.UserPrincipalName
        Enabled           = $User.Enabled
        PwdLastSet        = $(Get-ADUser -Filter ("SamAccountName -eq '$($User.SamAccountName)'") -Properties PasswordLastSet).PasswordLastSet
        LastLogon         = $LastLogon
        LogonScript       = $User.ScriptPath
        HomeDrive         = $User.HomeDrive
        HomeDirectory     = $User.HomeDirectory

    }
    
    $Object = New-Object psobject -Property $Hash
    $Array += $Object
}

$Array | Sort SamAccountName -Unique | Out-GridView
#   $Array | Sort SamAccountName -Unique | Export-Csv -Path "C:\TEMP\$($FQDN)" + "_Users.csv" -NoTypeInformation

# ($Array | sort SamAccountName -Unique).count
# $Array.Count

