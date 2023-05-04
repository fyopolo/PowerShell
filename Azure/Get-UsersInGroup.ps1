# $credential = Get-Credential
# Connect-MsolService -Credential $credential

$AllGroups = Get-MsolGroup -All | Where-Object {$_.DisplayName -like "SG-*" -and $_.GroupType -eq "Security"}
$Users = Get-MsolUser -All | Where-Object {$_.IsLicensed -eq "True" -and $_.BlockCredential -eq "True"}
# $UsersFiltered = $Users | Sort DisplayName | Select DisplayName, UserPrincipalName, IsLicensed, BlockCredential, ObjectId

$Info = @()
foreach ($Group in $AllGroups) {
    $Members = Get-MsolGroupMember -All -GroupObjectId $Group.ObjectId
    foreach ($Member in $Members){
        IF ($Users.ObjectId -match $Member.ObjectId) {
            $Hash =  [ordered]@{
                GroupName       = $Group.DisplayName
                GroupType       = $Group.GroupType
                Member          = $Member.DisplayName
                EmailAddress    = $Member.EmailAddress
                IsLicensed      = $Member.IsLicensed
                SignInBlocked   = "Yes"
            } # Closing HashTable
        
        $NewObject = New-Object psobject -Property $Hash
        $Info += $NewObject

        } # Closing IF
    } # Closing foreach $Members
} # Closing foreach $Groups

$Info | Sort Member | Export-Excel -Show

foreach ($User in $Users){
    $Sku = $User.Licenses.AccountSku.SkuPartNumber
    $GroupID = ($User.Licenses.GroupsAssigningLicense).Guid

    # Remove Direct Licenses
    # Set-MsolUserLicense -UserPrincipalName $_.UserPrincipalName -RemoveLicenses $Sku -Verbose

    # Remove Inherited Licenses // Remove user from Security Group
    # Remove-MsolGroupMember -GroupObjectId $GroupID -GroupMemberObjectId $User.ObjectId -Verbose
}