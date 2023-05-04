# Cleaning up Variables

$Domain = $null
$Domain = @{}
$Query = $null
$Query = @{}
$Offset120 = $null
$Offset120 = @{}
$Offset60 = $null
$Offset60 = @{}
$CurrentDate = $null
$CurrentDate = @{}

Import-Module ActiveDirectory
$Domain = Get-ADDomain | Select DNSRoot
$Domain = $Domain -replace "@{DNSRoot="
$Domain = $Domain -replace "}"

# Storing Day Offset in 2 variables: One for 60 days offset and other for 120 days offset & Formatting Date

$Offset60 = (Get-Date).AddDays(-60)
$Offset120 = (Get-Date).AddDays(-120)
$CurrentDate = Get-Date -format "yyyy MMM d"

# Query 1: Between 60 and 120 days

$Query = Get-ADComputer -Filter {LastLogonDate -lt $Offset60 -and LastLogonDate -gt $Offset120} -Properties LastLogonDate |
           Sort Name |
           Select -Property @{n='Hostname';e={$_.Name}},
                @{n='Last Logon Date';e={$_.LastLogonDate}},
                @{n='Account Enabled';e={$_.Enabled}},
                @{n='Distinguished Name';e={$_.DistinguishedName}}|
           
           ConvertTo-HTML -Fragment -PreContent "<h2>Between 60 and 120 days:</h2>"

# Query 2: More than 120 days

$Query += Get-ADComputer -Filter {LastLogonDate -le $Offset60 -and LastLogonDate -lt $Offset120} -Properties LastLogonDate |
           Sort Name |
           Select -Property @{n='Hostname';e={$_.Name}},
                @{n='Last Logon Date';e={$_.LastLogonDate}},
                @{n='Account Enabled';e={$_.Enabled}},
                @{n='Distinguished Name';e={$_.DistinguishedName}}|
                          
           ConvertTo-HTML -Fragment -PreContent "<h2>More than 120 days:</h2>"


# CSS Style Definition

$head = @'
<style>
body { background-color:#dddddd;
       font-family:Tahoma;
       font-size:11pt; }
td, th { border:1px solid black; 
         border-collapse:collapse; }
th { color:white;
     background-color:black; }
table, tr, td, th { padding: 2px; margin: 0px }
table { margin-left:50px; }
</style>
'@

# Preparing HTML

ConvertTo-HTML -head $head -body "<H1>Computer Last Logon for $Domain on $CurrentDate</H1> $Query" | Out-File C:\Temp\Offset-Report.htm
Invoke-Expression C:\Temp\Offset-Report.htm