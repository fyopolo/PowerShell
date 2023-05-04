# Import-Module ActiveDirectory

$Groups = Get-ADGroup -Filter * # -Properties Member
foreach ($Group in $Groups)
{

Get-ADGroupMember -Identity $Group.Name

#Write-Host "Group Name: " $Group.Name
#Write-Host "Members: " $Group.Member

}

#Get-ADGroupMember