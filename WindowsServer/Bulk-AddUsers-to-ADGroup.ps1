$Grp = Get-ADGroup -Filter * | Where-Object {$_.Name -like "*SG-AZW-IS-AZWP12WSWBX14*"}
$GrpMembers = Get-Content C:\Temp\GrpMembers.txt


foreach ($User in $GrpMembers){
    # Add-ADGroupMember -Identity $Grp.SamAccountName -Members $User
    # Get-ADUser -Filter * | Where-Object {$_.SamAccountName -like "$User*"}

    Get-ADUser -Filter "SamAccountName -like '$User*'"
}

Write-Host ""
Write-Host "Current Users in" $Grp.Name -ForegroundColor Cyan
Get-ADGroupMember -Identity $Grp.DistinguishedName | Select SamAccountName

foreach ($User in $GrpMembers){
Get-ADUser -Filter "SamAccountName -like '$User*'" | Select Name, SamAccountName
}