# Get-AzureADUser | Select DisplayName, Mail, UserType, CreationType, UserState | Where-Object {$_.UserType -eq "Guest"} | sort DisplayName | ft -auto

Connect-AzureAD
$ExtUsers = Get-Content D:\Scripts\NAHQ-ExtUsers.txt #User list was built using Mail attribute
foreach ($User in $ExtUsers) {

    (Get-AzureADUser -Filter "Mail eq '$User'").ObjectId | Remove-AzureADUser -Verbose

}