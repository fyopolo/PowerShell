$Users = Get-ADUser -Filter * -SearchBase "OU=Users,OU=Atlanta,OU=Marigold,DC=Marigold,DC=local"
$GRPNav = Get-ADGroup -Identity "SG-RDS-NavUsers"
$GRPASC = Get-ADGroup -Identity "SG-RDS-ASCUsers"

foreach ($User in $Users){

    Add-ADGroupMember -Identity $GRPNav -Members $User -Verbose
    Add-ADGroupMember -Identity $GRPASC -Members $User -Verbose

}