#Storing Tenant Admin Credentials

$Username = "fyopolo@ciolanding.com"
$Password = ConvertTo-SecureString 'champu.20' -AsPlainText -Force

$credential = New-Object System.Management.Automation.PSCredential $Username, $Password
Import-Module MsOnline
Connect-MsolService -Credential $credential

#Connecting to Exchange Online

$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
Import-PSSession $exchangeSession -DisableNameChecking

#Defining HMTL Tags

$a = "<style>"
#$a = $a + "BODY{background-color:peachpuff;}"
$a = $a + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
$a = $a + "TH{border-width: 1px;padding: 10px;border-style: solid;border-color: black;background-color:#2ECCFA;font-family: calibri;font-size:11pt}"
$a = $a + "TD{border-width: 1px;padding: 5px;border-style: solid;border-color: black;background-color:palegoldenrod;font-family: calibri;font-size:10pt}"
$a = $a + "</style>"

#Renaming Columns - Not Working

#$b = @{Expression={$_.DisplayName};Label="Display Name"}, `
#@{Expression={$_.RecipientType};Label="Recipient Type"}, `
#@{Expression={$_.PrimarySmtpAddress};Label="Primary SMTP Address"}, `
#@{Expression={$_.EmailAddresses};Label="Email Addresses"}, `
#@{Expression={$_.IsDirSynced};Label="Is Dir Synced"}, `
#@{Expression={$_.ArchiveName};Label="Archive Name"}, `
#@{Expression={$_.ArchiveStatus};Label="Archive Status"}, `
#@{Expression={$_.ArchiveDatabase};Label="Archive Database"}, `
#@{Expression={$_.IsShared};Label="Is Shared"}, `
#@{Expression={$_.IsMailboxEnabled};Label="Is Mailbox Enabled"}, `
#@{Expression={$_.ForwardingSmtpAddress};Label="Forwarding SMTP Address"}, `
#@{Expression={$_.RetentionPolicy};Label="Retention Policy"}

#Gathering Default Domain and removing unwanted characters

$TenantDefaultDomain = Get-MsolDomain | Where-Object {$_.IsDefault -eq 'True'} | Select Name
$TenantDefaultDomain = $TenantDefaultDomain -replace "@{Name="
$TenantDefaultDomain = $TenantDefaultDomain -replace "}"


#General Query & HTML Export

$FinalRecipient = Get-Recipient * | Select DisplayName, RecipientType, PrimarySmtpAddress, EmailAddresses, ArchiveName, ArchiveStatus, ArchiveDatabase, IsShared, IsMailboxEnabled, ForwardingSmtpAddress, RetentionPolicy | Sort-Object RecipientType, DisplayName

$FinalMailbox = Get-Mailbox | Select IsDirSynced

$FinalRecipient + $FinalMailbox | ConvertTo-HTML -head $a -body "<H2>$TenantDefaultDomain</H2>" -Title "Messaging Information" | Out-File C:\SMTP-Report2.htm

#Open HTML

Invoke-Expression C:\SMTP-Report2.htm