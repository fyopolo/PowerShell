$one = Get-Mailbox | Select-Object -Property @{n='AD Sync';e={$_.IsDirSynced}}, @{n='Mailbox Enabled';e={$_.IsMailboxEnabled}} |
ConvertTo-HTML -Fragment 

$two = Get-Recipient * | Select-Object -Property @{n='Email Addresses';e={$_.EmailAddresses}} |
ConvertTo-HTML -Fragment 

$three = Get-Mailbox | Select-Object -Property @{n='Shared Mailbox';e={$_.IsShared}}, @{n='Forwarding SMTP Address';e={$_.ForwardingSmtpAddress}} |
ConvertTo-HTML -Fragment 

$four = Get-Recipient * |
     # Sort-Object RecipientType, DisplayName |
      Select-Object -Property Name,
                              @{n='Display Name';e={$_.DisplayName}},
                              @{n='Recipient Type';e={$_.RecipientType}},
                              @{n='Primary SMTP Address';e={$_.PrimarySmtpAddress}} |
ConvertTo-HTML -Fragment 

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

ConvertTo-HTML -Head $head -Body "$one $two $three $four" -Title "Server Status" -CssUri D:\Scripts\PowerShell\style.css | Out-File D:\Scripts\PowerShell\status.htm

Invoke-Expression D:\Scripts\PowerShell\status.htm