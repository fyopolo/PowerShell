# Import active directory module for running AD cmdlets
Import-Module ActiveDirectory
  
#Store the data from ADUsers.csv in the $ADUsers variable
$ADGroups = Import-csv "C:\TEMP\AD-Groups.csv"

foreach ($Group in $ADGroups){

    Add-ADGroupMember -Identity $Group.GoupName -Members $($Group.Members).Split(",")

}