$Users = Get-ADuser -Filter * -Properties * | select Name, Mail, CanonicalName | Sort-Object Name # | Select-String -Pattern "ciolanding.inc/" # | ft -Wrap -AutoSize
$Users = $Users -replace "ciolanding.inc/" + "@{CanonicalName=" + "}"
$Users



# $CN = Get-ADuser -Filter * -Properties * | select CanonicalName | Sort-Object Name | ft -Wrap -AutoSize

<#
$Users | ForEach-Object
{
    if ($Users.CanonicalName -eq $_.CanonicalName)
        {
        $Users.CanonicalName -replace "ciolanding.inc/"
        $Users.CanonicalName -replace "@{CanonicalName="
        $Users.CanonicalName -replace "}"
        }

}
$Users.Item(12)

/#>

<#
foreach ($User in $Users)
{
$CN = $CN -replace "ciolanding.inc/"
$CN = $CN -replace "@{CanonicalName="
$CN = $CN -replace "}"

Write-Host $Users, $CN
}
/#>



#foreach ($User in $Users)
#{
#$($Users.CanonicalName) -replace "ciolanding.inc/" + "@{CanonicalName=" + "}"
#Write-Host $Users
#}
# $CN