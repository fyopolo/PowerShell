$Path = "OU=CCD,DC=cambridgecoinc,DC=com"
$Exclusion = "OU=Service Accounts,OU=CCD,DC=cambridgecoinc,DC=com"

$Users = Get-ADUser -Filter {(Enabled -eq $True)} -SearchBase $Path -SearchScope Subtree -Properties * | Where-Object {$_.DistinguishedName -notlike "*$Exclusion*"}

Function Remove-PWDNeverExpires(){
    ForEach($User in $Users){
	    IF ($User.PasswordNeverExpires -eq "True"){
            Write-Host "Changing account: $($User.SamAccountName)" -ForegroundColor Cyan
            # Set-ADUser $User.SamAccountName -PasswordNeverExpires $False
        }
    }
}


Function Remove-ChangePWDNextLogon (){
    ForEach($User in $Users){
        Write-Host "Changing account: $($User.SamAccountName)" -ForegroundColor Green
        # Set-ADUser $User.SamAccountName -ChangePasswordAtLogon $True

    }
}

$Users  | Select DisplayName, SamAccountName, PasswordExpired, PasswordNeverExpires, PasswordLastSet, DistinguishedName | Sort-Object DisplayName | Out-GridView