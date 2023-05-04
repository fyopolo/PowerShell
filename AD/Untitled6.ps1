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


$Query = Get-ADUser -Filter * -Properties LastLogonDate |
           Sort-Object LastLogonDate -Descending |
           Select -Property @{n='Hostname';e={$_.Name}},
                @{n='Last Logon Date';e={$_.LastLogonDate}},
                @{n='Account Enabled';e={$_.Enabled}},
                @{n='Distinguished Name';e={$_.DistinguishedName}}|
           
           ConvertTo-HTML -Fragment -PreContent "<h2>Sort by Last Logon Date:</h2>"


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

ConvertTo-HTML -head $head -body "<H1>User Last Logon for $Domain on $CurrentDate</H1> $Query" | Out-File C:\Temp\User-Offset-Report.htm
Invoke-Expression C:\Temp\User-Offset-Report.htm