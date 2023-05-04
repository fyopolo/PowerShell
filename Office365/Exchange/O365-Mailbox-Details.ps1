# -------------------------------------------------------------------------------
# Script: O365-Mailbox-Details.ps1
# Author: Fernando Yopolo
# Date: 03/03/2016
# Keywords: Exchange, Email, SMTP, Office 365
# Comments: Gather Office 365 mailbox details and output to HTML
#
# Versioning
# 03/03/2016  Initial Script
# 03/04/2016  Feature Added: Email capabilities
# 03/10/2016  Cleanup of variables for better coding
# 03/10/2016  Feature Disabled: Email capabilities
# 03/10/2016  CSS Style changed for a better visual impact
# 03/10/2016  Feature Added: Contacts & Distribution Lists as a new HTML table
# 03/10/2016  Feature Added: Identities with Extended Permissions as a new HTML table
# 13/02/2018  Support for new Office 365 groups added
# -------------------------------------------------------------------------------


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

Get-PSSession | Remove-PSSession
Clear-Host

# Function: Prompt the user where to store HTML result file

Function Select-FolderDialog
{
    param([string]$Description="Select Folder in where to store HTML result file",[string]$RootFolder="Desktop")

 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
     Out-Null     

   $objForm = New-Object System.Windows.Forms.FolderBrowserDialog
        $objForm.Rootfolder = $RootFolder
        $objForm.Description = $Description
        $Show = $objForm.ShowDialog()
        If ($Show -eq "OK")
        {
            Return $objForm.SelectedPath
        }
        Else
        {
            Write-Error "Operation cancelled by user."
        }
    }

    $OutputFolder = Select-FolderDialog



# Creating remote PowerShell session to Exchange Online

$credential = Get-Credential
Import-Module MsOnline
Connect-MsolService -Credential $credential
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
Import-PSSession $exchangeSession -DisableNameChecking



# Gathering Default Domain and removing unwanted characters

$TenantDefaultDomain = Get-MsolDomain | Where-Object {$_.IsDefault -eq 'True'} | Select Name
$TenantDefaultDomain = $TenantDefaultDomain -replace "@{Name="
$TenantDefaultDomain = $TenantDefaultDomain -replace "}"


# Querying Mailboxes

$Query = Get-Mailbox * -ResultSize unlimited |
    Where-Object {$_.RecipientTypeDetails -ne "DiscoveryMailbox" -and $_.RecipientTypeDetails -ne "SystemMailbox"}|
    Sort-Object DisplayName |
    Select -Property @{n='Display Name';e={$_.DisplayName}},
                @{n='Recipient Type';e={$_.RecipientType}},
                @{n='Recipient Type Details';e={$_.RecipientTypeDetails}},
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
                @{n='Retention Policy Name';e={$_.RetentionPolicy}}|

    
    ConvertTo-HTML -Fragment -PreContent "<h2>Mailboxes</h2>"


# Querying Office 365 Groups

$Query += Get-UnifiedGroup -ResultSize unlimited |
         Sort-Object DisplayName |
         Select -Property @{n='Display Name';e={$_.DisplayName}},
                @{n='Group Owner';e={$_.ManagedBy}},
                @{n='Primary SMTP Address';e={$_.PrimarySmtpAddress}},
                @{n='E-mail Addresses';e={$_.EmailAddresses}}|
                                
                    
    ConvertTo-HTML -Fragment -PreContent "<h2>Office 365 Groups</h2>"


# Querying DLs and Mail Contacts

$Query += Get-Recipient * -ResultSize unlimited |
         Sort-Object RecipientType, DisplayName |
         Where-Object {$_.RecipientType -eq "MailUniversalDistributionGroup" -or $_.RecipientType -eq "MailContact"} |
         Select -Property @{n='Display Name';e={$_.DisplayName}},
                @{n='Recipient Type';e={$_.RecipientType}},
                @{n='Recipient Type Details';e={$_.RecipientTypeDetails}},
                @{n='Primary SMTP Address';e={$_.PrimarySmtpAddress}},
                @{n='E-mail Addresses';e={$_.EmailAddresses}}|
                                
                    
    ConvertTo-HTML -Fragment -PreContent "<h2>Contacts & Distribution Lists</h2>"



# Querying Extended Permissions

$Query += Get-RecipientPermission | Where-Object {$_.Trustee -ne "NT AUTHORITY\SELF"} |
           Sort Identity |
           Select -Property @{n='Source Identity';e={$_.Identity}},
                @{n='Trusted Identity';e={$_.Trustee}},
                @{n='Access Rights';e={$_.AccessRights}},
                @{n='Inherited';e={$_.IsInherited}}|    

          ConvertTo-HTML -Fragment -PreContent "<h2>Identities with Extended Permissions</h2>"



# Querying other Recipient Types

$Query += Get-Recipient * -ResultSize unlimited |
         Sort-Object RecipientType |
         Where-Object {$_.RecipientType -ne "MailUniversalDistributionGroup" -and $_.RecipientType -ne "MailContact" -and $_.RecipientType -ne "UserMailbox"} |
         Select -Property @{n='Display Name';e={$_.DisplayName}},
                @{n='Recipient Type';e={$_.RecipientType}},
                @{n='Recipient Type Details';e={$_.RecipientTypeDetails}},
                @{n='Primary SMTP Address';e={$_.PrimarySmtpAddress}},
                @{n='E-mail Addresses';e={$_.EmailAddresses}}|
                                
                    
    ConvertTo-HTML -Fragment -PreContent "<h2>Other Recipient Types</h2>"



# CSS Style Definitions (for output)

$a = "<style>"
$a = $a + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
$a = $a + "TH{border-width: 1px;padding: 10px;border-style: solid;border-color: black;background-color:#2ECCFA;font-family: calibri;font-size:11pt}"
$a = $a + "TD{border-width: 1px;padding: 5px;border-style: solid;border-color: black;background-color:palegoldenrod;font-family: calibri;font-size:10pt}"
$a = $a + "</style>"

$head = @'
<style>
body { background-color:#dddddd;
       font-family:Tahoma;
       font-size:10pt; }
td, th { border:1px solid black; 
         border-collapse:collapse; }
th { color:white;
     background-color:black; }
table, tr, td, th { padding: 2px; margin: 1px }
table { margin-left:50px; }
</style>
'@


# Create HTML File

ConvertTo-Html -head $head -body "<H1>$TenantDefaultDomain</H1> $Query" -Title "Messaging Information" | Out-File $OutputFolder\SMTP-Report-$TenantDefaultDomain.htm



# Open HTML

  Invoke-Expression $OutputFolder\SMTP-Report-$TenantDefaultDomain.htm


# Sending e-mail

# Send-MailMessage -SmtpServer "outlook.office365.com" -UseSsl -Credential $credential -From "tecteam@ciolanding.com" -To "tecteam@ciolanding.com" -Subject "Office 365 Mailbox Details Report for $TenantDefaultDomain" -Body "Please find attached the information regarding your query" -Attachments $OutputFolder\SMTP-Report-$TenantDefaultDomain.htm


# Closing Remote PowerShell Session

  Get-PSSession | Remove-PSSession