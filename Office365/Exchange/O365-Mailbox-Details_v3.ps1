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
# 02/13/2018  Support for new Office 365 groups added
# 04/09/2018  Added HTML reporting capabilities by using ReportHTML module.
#             This requires PowerShell v4+ and having installed the following:
#             Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
#             Install-Module -Name ReportHTML -Force
#             Added feature: getting DLs and O365 group members in a loop sequence
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

# Get-PSSession | Remove-PSSession
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

<#
$credential = Get-Credential
Import-Module MsOnline
Connect-MsolService -Credential $credential
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
Import-PSSession $exchangeSession -DisableNameChecking
#>

# Gathering Default Domain and removing unwanted characters

$TenantDefaultDomain = (Get-MsolDomain | Where-Object {$_.IsDefault -eq 'True'}).Name

########## REPORT SETTINGS ##########

Import-Module ReportHTML

# Create an empty array for HTML strings
$rpt = @()


# NOTE: From here on we always append to the $rpt array variable.
# First, let's add the HTML header information including report title
$rpt += Get-HtmlOpenPage -TitleText "Office 365 Identities Report for: $TenantDefaultDomain" -LeftLogoString "https://d2oc0ihd6a5bt.cloudfront.net/wp-content/uploads/sites/1064/2015/06/logo.png"


#  Report: Summary Section
$ReportName = "Office 365 Identities"

### Testing Tabs
$TABarray = @('Mailboxes','Distribution Lists','Office 365 Groups','Mail Contacts','Extended Permissions','Other Identities')
$rpt += Get-HTMLTabHeader -TabNames $TABarray 

### Querying Mailboxes

$Mailboxes = Get-Mailbox * -ResultSize unlimited |
    Where-Object {$_.RecipientTypeDetails -ne "DiscoveryMailbox" -and $_.RecipientTypeDetails -ne "SystemMailbox"} |
    Sort-Object DisplayName |
    Select -Property @{n='Recipient Type Details';e={$_.RecipientTypeDetails}},
                @{n='Display Name';e={$_.DisplayName}},
                @{n='Recipient Type';e={$_.RecipientType}},
                @{n='Mailbox Enabled';e={$_.IsMailboxEnabled}},
                @{n='Mailbox Created On';e={$_.WhenMailboxCreated}},
                @{n='Primary SMTP Address';e={$_.PrimarySmtpAddress}},
                @{n='E-mail Addresses';e={$_.EmailAddresses}},
                @{n='AD Synchronized';e={$_.IsDirSynced}},
                @{n='Shared Mailbox';e={$_.IsShared}},
                @{n='Forwarding SMTP Address';e={$_.ForwardingSmtpAddress}},
                @{n='Archive Status';e={$_.ArchiveStatus}},
                @{n='Archive Name';e={$_.ArchiveName}},
                @{n='Archive Database Name';e={$_.ArchiveDatabase}},
                @{n='Retention Policy Name';e={$_.RetentionPolicy}}

    ## REPORT ##
    $rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(0) -Tabheading ("$Mailboxes")
        $rpt += Get-HtmlContentOpen -HeaderText "Mailboxes"
            $rpt += Get-HtmlContentTable $Mailboxes -GroupBy ("Recipient Type Details")	
        $rpt += Get-HTMLTabContentClose
    $rpt += Get-HtmlContentClose


### Querying DLs

$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(1) -Tabheading (" ")

# $rpt += Get-HtmlContentOpen -HeaderText "Distribution Lists" # -IsHidden
$DLs = Get-DistributionGroup -ResultSize unlimited

foreach ($O365DL in $DLs)
{  

    $rpt += Get-HtmlContentOpen -HeaderText "Distribution List: $O365DL" # -IsHidden
        $rpt += Get-HtmlContentTable ($O365DL | Select -Property @{n='AD Synced';e={$_.IsDirSynced}},
            @{n='Display Name';e={$_.DisplayName}},
            @{n='Primary SMTP Address';e={$_.PrimarySmtpAddress}},
            @{n='Email Addresses';e={$_.EmailAddresses}},
            @{n='Owner';e={$_.ManagedBy}}) -Fixed
            
            $Members = Get-DistributionGroupMember -Identity $O365DL.Identity
            $rpt += Get-HtmlContentOpen -HeaderText "Members of: $O365DL"
                $rpt += Get-HtmlContentTable ($Members | Select DisplayName, Alias, PrimarySMTPAddress) -Fixed
            $rpt += Get-HtmlContentClose

    $rpt += Get-HtmlContentClose
}

$rpt += Get-HTMLTabContentClose
$rpt += Get-HtmlContentClose

                                
##### Getting all the Office 365 Groups in the tenant     

$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(2) -Tabheading (" ")

$O365Groups = Get-UnifiedGroup -ResultSize unlimited
# $rpt += Get-HtmlContentOpen -HeaderText "Office 365 Groups" # -IsHidden

foreach ($O365Group in $O365Groups)  
{
    $Members = Get-UnifiedGroupLinks –Identity $O365Group.Identity –LinkType Members
    $rpt += Get-HtmlContentOpen -HeaderText "Group: $O365Group" # -IsHidden
        $rpt += Get-HtmlContentTable ($O365Group | Select Owner, DisplayName, PrimarySMTPAddress, EmailAddresses) -Fixed    
            $rpt += Get-HtmlContentOpen -HeaderText "Members of: $O365Group"
                $rpt += Get-HtmlContentTable ($Members | Select Name, PrimarySMTPAddress) -Fixed
            $rpt += Get-HtmlContentClose
    $rpt += Get-HtmlContentClose
}                

# $rpt += Get-HtmlContentClose // Container
$rpt += Get-HTMLTabContentClose # // Closing TAB


### Querying Mail Contacts

$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(3) -Tabheading (" ")

$MailContacts = Get-Recipient * -ResultSize unlimited |
         Sort-Object RecipientType, DisplayName |
         Where-Object {$_.RecipientType -eq "MailContact"} |
                Select -Property @{n='Display Name';e={$_.DisplayName}},
                @{n='Primary SMTP Address';e={$_.PrimarySmtpAddress}},
                @{n='E-mail Addresses';e={$_.EmailAddresses}}
            
            $rpt += Get-HtmlContentOpen -HeaderText "Mail Contacts" # -IsHidden
                $rpt += Get-HtmlContentTable $MailContacts -Fixed
            $rpt += Get-HtmlContentClose                    

$rpt += Get-HTMLTabContentClose


### Querying Extended Permissions

$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(4) -Tabheading (" ")

$ExtendedPermissions = Get-RecipientPermission | Where-Object {$_.Trustee -ne "NT AUTHORITY\SELF"} |
    Sort Identity |
    Select -Property @{n='Source Identity';e={$_.Identity}},
        @{n='Trusted Identity';e={$_.Trustee}},
        @{n='Access Rights';e={$_.AccessRights}},
        @{n='Inherited';e={$_.IsInherited}}

        $rpt += Get-HtmlContentOpen -HeaderText "Extended Permissions" # -IsHidden
            $rpt += Get-HtmlContentTable $ExtendedPermissions -Fixed -GroupBy ("Source Identity")
        $rpt += Get-HtmlContentClose

$rpt += Get-HTMLTabContentClose


### Querying other Recipient Types

$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(5) -Tabheading (" ")

$OtherIdentities = Get-Recipient * -ResultSize unlimited |
         Sort-Object RecipientType |
         Where-Object {$_.RecipientType -ne "MailUniversalDistributionGroup" -and $_.RecipientType -ne "MailContact" -and $_.RecipientType -ne "UserMailbox"} |
         Select -Property @{n='Display Name';e={$_.DisplayName}},
                @{n='Recipient Type';e={$_.RecipientType}},
                @{n='Recipient Type Details';e={$_.RecipientTypeDetails}},
                @{n='Primary SMTP Address';e={$_.PrimarySmtpAddress}},
                @{n='E-mail Addresses';e={$_.EmailAddresses}}

                ### REPORT
                $rpt += Get-HtmlContentOpen -HeaderText "Other Identities" # -IsHidden
                    $rpt += Get-HtmlContentTable $OtherIdentities -Fixed
                $rpt += Get-HtmlContentClose

$rpt += Get-HTMLTabContentClose


#  Close HTML Report
$rpt += Get-HtmlClosePage
  

Function Create-Report
{
    $rptFile = $OutputFolder + "\" + "SMTP-Report-" + "$TenantDefaultDomain" + ".htm"
    $rpt | Set-Content -Path $rptFile -Force
    Invoke-Item $rptFile
    sleep 1
}


$rpt += Get-HTMLClosePage

Create-Report

# Get-PSSession | Remove-PSSession