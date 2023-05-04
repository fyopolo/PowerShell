# Import-Module activeDirectory

$FQDN = $(Get-ADForest).Name
$Domain = (Get-ADDomain $FQDN | select distinguishedName, pdcEmulator, DNSroot, DomainControllersContainer)
$OUList = @(Get-ADOrganizationalUnit -filter * -SearchBase $Domain.distinguishedName -SearchScope Subtree -Server $Domain.DNSroot -Properties CanonicalName)

$OuStats = @{ }
$UArray = @()

foreach ($Item in $OUList){

    $Users = Get-ADObject -Filter * -SearchBase $Item.DistinguishedName -Server $Domain.pdcEmulator -Properties *
    $UserCount = $Users | Measure-Object | Select Count
    # $OUs = Get-ADuser -Filter * -SearchBase $Item.DistinguishedName -SearchScope OneLevel -Server $Domain.pdcEmulator -Properties CanonicalName | measure | select Count
    $OuStats.Add(($Item.CanonicalName).TrimEnd("/").Replace("/"," > "), $UserCount.Count)

    foreach ($User in $Users){

        IF ($User.ObjectClass -eq "user"){

            $Hash = [ordered] @{
                OU                = IF (-NOT([string]::IsNullOrWhiteSpace($User.CanonicalName))) { ($User.CanonicalName).TrimEnd($User.Name).TrimEnd("/").Replace("/"," > ") } ELSE {"Error"}
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
        }
        $Object = New-Object psobject -Property $Hash
        $UArray += $Object
    }

}

Write-Host "OUs Statistics" -ForegroundColor Cyan
$OuStats | ft -AutoSize -Wrap
Write-Host ""


$UArray | Sort SamAccountName -Unique | Export-Csv -Path C:\temp\users.csv  -NoTypeInformation