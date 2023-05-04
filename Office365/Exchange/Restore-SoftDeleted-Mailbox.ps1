#Connect to Office 365 
$UserCredential = Get-Credential 
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection 
Import-PSSession $Session

# List the Soft Deleted Mailboxs and pick the one that needs to be imported 
$DeletedMailbox = Get-Mailbox -SoftDeletedMailbox | Select DisplayName,ExchangeGuid,PrimarySmtpAddress,ArchiveStatus,DistinguishedName | Out-GridView -Title "Select Mailbox and GUID" -PassThru

# Get Target Mailbox 
$MergeMailboxTo = Get-Mailbox | Select Name,PrimarySmtpAddress,DistinguishedName | Out-GridView -Title "Select the mailbox to merge the deleted mailbox to" -PassThru

# Run the Merge Command 
New-MailboxRestoreRequest -SourceMailbox $DeletedMailbox.DistinguishedName -TargetMailbox $MergeMailboxTo.PrimarySmtpAddress -AllowLegacyDNMismatch

# View the progress 
#Grab the restore ID for the one you want progress on. 
$RestoreProgress = Get-MailboxRestoreRequest | Select Name,TargetMailbox,Status,RequestGuid | Out-GridView -Title "Restore Request List" -PassThru

# Get the progress in Percent complete 
Get-MailboxRestoreRequestStatistics -Identity $RestoreProgress.RequestGuid | Select Name,StatusDetail,TargetAlias,PercentComplete