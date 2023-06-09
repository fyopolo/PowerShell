# Import active directory module for running AD cmdlets
Import-Module activedirectory
  
#Store the data from ADUsers.csv in the $ADUsers variable
$ADUsers = Import-csv "C:\TEMP\bulk_users1.csv"

#Loop through each row containing user details in the CSV file 
foreach ($User in $ADUsers)
{
	#Read user data from each field in each row and assign the data to a variable as below
		
	$UserName 	    = $User.UserName
    $SamAccountName = $User.SamAccountName
    $UPN            = $User.UPN
    $DisplayName    = $User.DisplayName
	$Password 	    = $User.Password
	$FirstName 	    = $User.FirstName
	$LastName 	    = $User.LastName
	$OU 		    = $User.OU #This field refers to the OU the user account is to be created in
    $email          = $User.email
    $StreetAddress  = $User.StreetAddress
    $City           = $User.City
    $ZipCode        = $User.ZipCode
    $State          = $User.State
    $Country        = $User.Country
    $OfficePhone    = $User.OfficePhone
    $MobilePhone    = $User.MobilePhone
    $JobTitle       = $User.JobTitle
    $Company        = $User.Company
    $Department     = $User.Department
    $Password       = $User.Password


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
            -Enabled $True `
            -DisplayName "$Firstname, $Lastname" `
            -Path $OU `
            -City $City `
            -Company $Company `
            -State $State `
            -StreetAddress $StreetAddress `
            -OfficePhone $OfficePhone `
            -MobilePhone $MobilePhone `
            -EmailAddress $email `
            -Title $JobTitle `
            -Department $Department
            # -AccountPassword (convertto-securestring $Password -AsPlainText -Force) -ChangePasswordAtLogon $True
            
	}
}
