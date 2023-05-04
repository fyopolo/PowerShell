$UserProfile = Get-ADUser -Filter { ScriptPath -ne "*" -or HomeDrive -ne "*" -or HomeDirectory -ne "*" } -Properties * | Sort DisplayName | Select DisplayName, SamAccountName, ScriptPath, HomeDrive, HomeDirectory
$UserProfile | ft -AutoSize
$UserProfile | Out-File C:\TEMP\UserADProfile.txt

# Removing properties

foreach ($User in $UserProfile){
    Set-ADUser -Identity $User.SamAccountName -ScriptPath $null -Confirm -Verbose
    Set-ADUser -Identity $User.SamAccountName -HomeDrive $null -Confirm -Verbose
    Set-ADUser -Identity $User.SamAccountName -HomeDirectory $null -Confirm -Verbose
}