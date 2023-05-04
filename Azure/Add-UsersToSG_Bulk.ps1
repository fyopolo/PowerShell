# Connect-AzureAD
$Users = Import-Excel -Path 'D:\DOCS\Companies\Alera Group\Firms\GCG\GCG Employee List.xlsx'

$AzGroup = "SSO-AwardCo-GCG"

Write-Host "Items to be processed:" $Users.Count -ForegroundColor Cyan
Write-Host ""

foreach($User in $Users) {
     Write-Host "Processing:" $($User.'First Name'), $($User.'Last Name') -ForegroundColor Yellow
     $AzureADUser = Get-AzureADUser -Filter "UserPrincipalName eq '$($User.UPN)'"
     IF ($AzureADUser -ne $null) {
         try {
             $AzureADGroup = Get-AzureADGroup -Filter "DisplayName eq '$AzGroup'" -ErrorAction Stop
             $isUserMemberOfGroup = Get-AzureADGroupMember -ObjectId $AzureADGroup.ObjectId -All $true | Where-Object {$_.UserPrincipalName -like "*$($AzureADUser.UserPrincipalName)*"}
             IF ($isUserMemberOfGroup -eq $null) {
                 Add-AzureADGroupMember -ObjectId $AzureADGroup.ObjectId -RefObjectId $AzureADUser.ObjectId -Verbose
             }
         }
         catch {
             Write-Output "Azure AD Group does not exist or insufficient right"
         }
     }
     ELSE {
         Write-Output "User does not exist"
     }
}

