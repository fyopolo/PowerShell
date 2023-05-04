Import-Module ActiveDirectory
$Domain = (Get-ADDomain).DNSRoot

# Storing Day Offset in 2 variables: One for 60 days offset and other for 120 days offset & Formatting Date

#$Offset90 = (Get-Date).AddDays(-90)
#$Offset120 = (Get-Date).AddDays(-120)
$CurrentDate = Get-Date -format "yyyy MMM d"

$Offset1 = Get-ADUser -Filter {LastLogonDate -lt $((Get-Date).AddDays(-90)) -and LastLogonDate -gt $((Get-Date).AddDays(-120))} -Properties *
$Offset2 = Get-ADUser -Filter {LastLogonDate -le $((Get-Date).AddDays(-90)) -and LastLogonDate -lt $((Get-Date).AddDays(-120))} -Properties *

$Array1 = @()
foreach ($User in $Offset1){

    IF (-NOT([string]::IsNullOrWhiteSpace($User.LastLogon) -OR ($User.lastLogon -like "*null*"))) { $LastLogon = ($(w32tm /ntte $User.LastLogon) -split " - ",2)[1] } ELSE { $LastLogon = "Never" }

    $Hash = [ordered] @{
        DisplayName       = $User.DisplayName
        SamAccountName    = $User.SamAccountName
        LastLogon         = $LastLogon
        OU                = ($User.CanonicalName).TrimEnd($User.Name).TrimEnd("/").Replace("/"," > ")
        UserPrincipalName = $User.UserPrincipalName
        Enabled           = $User.Enabled
        PwdLastSet        = $(Get-ADUser -Filter ("SamAccountName -eq '$($User.SamAccountName)'") -Properties PasswordLastSet).PasswordLastSet

    }
    
    $Object = New-Object psobject -Property $Hash
    $Array1 += $Object
}
           
$Array1 | Sort OU | Out-GridView -Title "Users not logged in during the last 90 days"

# Query 2: More than 120 days

$Array2 = @()
foreach ($User in $Offset2){

    IF (-NOT([string]::IsNullOrWhiteSpace($User.LastLogon) -OR ($User.lastLogon -like "*null*"))) { $LastLogon = ($(w32tm /ntte $User.LastLogon) -split " - ",2)[1] } ELSE { $LastLogon = "Never" }

    $Hash = [ordered] @{
        DisplayName       = $User.DisplayName
        SamAccountName    = $User.SamAccountName
        LastLogon         = $LastLogon
        OU                = ($User.CanonicalName).TrimEnd($User.Name).TrimEnd("/").Replace("/"," > ")
        UserPrincipalName = $User.UserPrincipalName
        Enabled           = $User.Enabled
        PwdLastSet        = $(Get-ADUser -Filter ("SamAccountName -eq '$($User.SamAccountName)'") -Properties PasswordLastSet).PasswordLastSet

    }
    
    $Object = New-Object psobject -Property $Hash
    $Array2 += $Object
}

$Array2 | Sort OU | Out-GridView -Title "Users not logged in for more than 120 days"

$HTML = $Array1 | Sort OU | ConvertTo-HTML -Fragment -PreContent "<h2>Not logged in between 90 and 120 days:</h2>"                          
$HTML += $Array2 | Sort OU | ConvertTo-HTML -Fragment -PreContent "<h2>Not logged in for more than 120 days:</h2>"


# CSS Style Definition

$head = @'
<style>
body {
    background-color:white;
    font-family:Tahoma;
    font-size:11pt;
    }

th {
    color:white;
    background-color:black;
    }

table, tr, td, th {
    padding: 0px;
    margin: 0px;
    border:none;
    border-width:thin;
    border-style:inset
    }

table { margin-left:50px; }

</style>
'@

# Preparing HTML

ConvertTo-HTML -head $head -body "<H1>User Last Logon for $Domain on $CurrentDate</H1> $HTML" | Out-File C:\Temp\User-Offset-Report.htm
Invoke-Expression C:\Temp\User-Offset-Report.htm