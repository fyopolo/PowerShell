# Cleaning up Variables

$OutputFolder = $null
$OutputFolder = @{}
$credential = $null
$credential = @{}
$exchangeSession = $null
$exchangeSession = @{}
$Query = $null
$Query = @{}
$TenantDefaultDomain = $null
$TenantDefaultDomain = @{}
$a = $null
$a = @{}

$credential = Get-Credential
Import-Module MsOnline
Connect-MsolService -Credential $credential
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
Import-PSSession $exchangeSession -DisableNameChecking


# Query 1: Between 60 and 120 days
$Query = Get-Mailbox * -ResultSize unlimited | Sort-Object RecipientType, DisplayName | Select -Property @{n='Display Name';e={$_.DisplayName}},
                @{n='Recipient Type';e={$_.RecipientType}},
                @{n='Mailbox Enabled';e={$_.IsMailboxEnabled}},
                # @{n='Mailbox Size';e={$_.}},
                @{n='Mailbox Created On';e={$_.WhenMailboxCreated}},
                @{n='Primary SMTP Address';e={$_.PrimarySmtpAddress}},
                @{n='E-mail Addresses';e={$_.EmailAddresses}},
                @{n='AD Synchronized';e={$_.IsDirSynced}},
                @{n='Shared Mailbox';e={$_.IsShared}},
                @{n='Forwarding SMTP Address';e={$_.ForwardingSmtpAddress}},
                @{n='Archive Status';e={$_.ArchiveStatus}},
                @{n='Archive Name';e={$_.ArchiveName}},
                @{n='Archive Database Name';e={$_.ArchiveDatabase}},
                @{n='Archive Quota';e={$_.ArchiveQuota}},
                @{n='Archive Warning Quota';e={$_.ArchiveWarningQuota}},
                @{n='Retention Policy Name';e={$_.RetentionPolicy}}|

    # Sort-Object 'Recipient Type', 'Display Name' |

    ConvertTo-HTML -Fragment -PreContent "<h2>Mailboxes</h2>"


$Query += Get-RecipientPermission | Where-Object {$_.Trustee -ne "NT AUTHORITY\SELF"} |
           Sort Identity |
           Select -Property @{n='Source Identity';e={$_.Identity}},
                @{n='Trusted Identity';e={$_.Trustee}},
                @{n='Access Rights';e={$_.AccessRights}},
                @{n='Inherited';e={$_.IsInherited}}|    

          ConvertTo-HTML -Fragment -PreContent "<h2>Identities with Extended Permissions</h2>"



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

ConvertTo-HTML -head $head -body "<H1>Computer Last Logon for on $</H1> $Query" | Out-File C:\Temp\Offset-Report2.htm
Invoke-Expression C:\Temp\Offset-Report2.htm