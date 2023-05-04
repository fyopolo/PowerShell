# Import-Module activeDirectory
$Newlist.Clear()
$Array.Clear()
$FQDN = $(Get-ADForest).Name
$Domain = (Get-ADDomain $FQDN | select distinguishedName, pdcEmulator, DNSroot, DomainControllersContainer)

Write-Host "Contacting $FQDN domain..." -ForegroundColor Yellow

$Domain = (Get-ADDomain $FQDN | select distinguishedName, pdcEmulator, DNSroot, DomainControllersContainer)

Write-Host "Completed. Enumerating OUs.." -ForegroundColor Yellow

$OUlist = @(Get-ADOrganizationalUnit -filter * -Properties * -SearchBase "OU=Wilson_Albers_&_Company,DC=Corp,DC=aleragroup,DC=com" -SearchScope Subtree -Server $Domain.DNSroot)
Write-Host "Completed. Counting users..." -ForegroundColor Yellow

for ($i = 1; $i -le $OUlist.Count; $i++) {
    write-progress -Activity "Collecting OUs" -Status "Finding OUs $i" -PercentComplete ($i/$OUlist.count * 100)
}

$Newlist = @{ }
$Array = @()

foreach ($_objectitem in $OUlist) {

    $getUser = Get-ADuser -Filter * -Properties * -SearchBase $_objectItem.DistinguishedName -Server $Domain.pdcEmulator
    $userCount = $getUser | Measure-Object | select Count

    for ($i = 1; $i -le $getUser.Count; $i++) {
        write-progress -Activity "Counting users" -Status "Finding users $i in $_objectitem" -PercentComplete ($i/$userCount.Count * 100)
    }

    #$OU = $_objectItem.CanonicalName.Replace("/"," > ")
    $Newlist.Add($OU, $userCount.Count)

    foreach ($item in $getUser){
        
        $item.DisplayName + $OU
        #$OU = $_objectItem.CanonicalName.Replace("/"," > ")

        $Hash = [ordered]@{
            CanonicalName  = $item.CanonicalName
            OU             = $_objectItem.CanonicalName.Replace("/"," > ")
            DisplayName    = $item.DisplayName
            SamAccountName = $item.SamAccountName
            UPN            = $item.UserPrincipalName
            Enabled        = $item.Enabled
            LastLogonDate  = $item.LastLogonDate
            ScriptPath     = $item.ScriptPath
            HomeDrive      = $item.HomeDrive
            HomeDirectory  = $item.HomeDirectory
        }

        $Object = New-Object psobject -Property $Hash
        $Array += $Object

    }
}

# $NewList | Out-GridView
$Array | Sort SamAccountName -Unique | Out-GridView

($Array | Sort SamAccountName -Unique).Count

