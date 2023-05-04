$b =  Get-Recipient * |
     # Sort-Object RecipientType, DisplayName |
      Select-Object -Property Name,
                              @{n='Display Name';e={$_.DisplayName}},
                              @{n='Recipient Type';e={$_.RecipientType}},
                              @{n='Primary SMTP Address';e={$_.PrimarySmtpAddress}}|
    ConvertTo-HTML -Fragment

$c = Get-Mailbox | Select-Object -Property @{n='AD Sync';e={$_.IsDirSynced}}, @{n='Mailbox Enabled';e={$_.IsMailboxEnabled}} | ConvertTo-HTML -Fragment

$d = Get-Recipient * | Select-Object -Property @{n='Email Addresses';e={$_.EmailAddresses}} | ConvertTo-HTML -Fragment

$e = Get-Mailbox | Select-Object -Property @{n='Shared Mailbox';e={$_.IsShared}}, @{n='Forwarding SMTP Address';e={$_.ForwardingSmtpAddress}} | ConvertTo-HTML -Fragment

$a = "<style>"
#$a = $a + "BODY{background-color:peachpuff;}"
$a = $a + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
$a = $a + "TH{border-width: 1px;padding: 10px;border-style: solid;border-color: black;background-color:#2ECCFA;font-family: calibri;font-size:11pt}"
$a = $a + "TD{border-width: 1px;padding: 5px;border-style: solid;border-color: black;background-color:palegoldenrod;font-family: calibri;font-size:10pt}"
$a = $a + "</style>"
 
$head = @'
<style>
body { background-color:#dddddd;
       font-family:Calibri;
       font-size:12pt; }
td, th { border:1px solid black; 
         border-collapse:collapse;
         font-size:10pt; }
th { color:white;
     background-color:black; }
table, tr, td, th { padding: 5px; margin: 0px; }
table { margin-left:0px; }
</style>
'@

#Gathering Default Domain and removing unwanted characters

$TenantDefaultDomain = Get-MsolDomain | Where-Object {$_.IsDefault -eq 'True'} | Select Name
$TenantDefaultDomain = $TenantDefaultDomain -replace "@{Name="
$TenantDefaultDomain = $TenantDefaultDomain -replace "}"

Sort-Object RecipientType, DisplayName |
ConvertTo-HTML -head $head -body "<H1>$TenantDefaultDomain SMTP Status</H1> $b $c $d $e" -Title "Messaging Information" | Out-File D:\Scripts\PowerShell\status.htm
Invoke-Expression D:\Scripts\PowerShell\status.htm