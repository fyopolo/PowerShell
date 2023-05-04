# Import-Module activeDirectory

$FQDN = $(Get-ADForest).Name
$Domain = (Get-ADDomain $FQDN | Select distinguishedName, pdcEmulator, DNSroot, DomainControllersContainer)

Write-Host "Contacting $FQDN domain..." -ForegroundColor Yellow

$Domain = (Get-ADDomain $FQDN | Select distinguishedName, pdcEmulator, DNSroot, DomainControllersContainer)

Write-Host "Completed. Enumerating OUs.." -ForegroundColor Yellow

$OUlist = @(Get-ADOrganizationalUnit -filter * -Properties CanonicalName -SearchBase $Domain.distinguishedName -SearchScope Subtree -Server $Domain.DNSroot)
Write-Host "Completed. Counting users..." -ForegroundColor Yellow

for ($i = 1; $i -le $OUlist.Count; $i++) {
    write-progress -Activity "Collecting OUs" -Status "Finding OUs $i" -PercentComplete ($i/$OUlist.count * 100)
}

$Newlist = @{ }

foreach ($_objectitem in $OUlist) {

    $getUser = Get-ADuser -Filter * -Properties CanonicalName -SearchBase $_objectItem.DistinguishedName -SearchScope OneLevel -Server $Domain.pdcEmulator
    $userCount = $getUser | Measure-Object | select Count

    for ($i = 1; $i -le $getUser.Count; $i++) {
        write-progress -Activity "Counting users" -Status "Finding users $i in $_objectitem" -PercentComplete ($i/$userCount * 100)
    }

    $Newlist.add($_objectItem.CanonicalName.Replace("/"," > "), $userCount)

}

$NewList | Out-GridView
