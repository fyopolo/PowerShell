# Import active directory module for running AD cmdlets
Import-Module ActiveDirectory
  
#Store the data from ADUsers.csv in the $ADUsers variable
$ADUsers = Import-csv "C:\TEMP\bulk_users1.csv"

#Loop through each row containing user details in the CSV file 
foreach ($User in $ADUsers)
{
	#Read user data from each field in each row and assign the data to a variable as below

    $DisplayName       = $User.DisplayName		
    $FirstName 	       = $User.FirstName
    $LastName 	       = $User.LastName
    $SamAccountName    = $User.SamAccountName
    $UserPrincipalName = $User.UserPrincipalName
    $OU                = $User.OU	
    $Password 	       = $User.Password


	#Check to see if the user already exists in AD
	if (Get-ADUser -F {SamAccountName -eq $Username})
	{
		 #If user does exist, give a warning
		 Write-Warning "A user account with username $Username already exist in Active Directory."
	}
	else
	{
		#User does not exist then proceed to create the new user account
		
        #Account will be created in the OU provided by the $OU variable read from the CSV file
		New-ADUser `
            -SamAccountName $SamAccountName `
            -Name "$Firstname $Lastname" `
            -GivenName $Firstname `
            -Surname $Lastname `
            -DisplayName "$Firstname, $Lastname" `
            -Password "$Firstname, $Lastname" `
            -Enabled $True `
            -Path $OU `
            -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -ChangePasswordAtLogon $False
            
	}
}
