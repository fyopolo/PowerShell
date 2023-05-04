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
#             Feature Added: Group members listed by pertenence group.
# 04/16/2018  Feature Added: Charting capabilities and table color styles.
# 04/17/2018  Feature Added: Progress bar to show script progress.
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


<# Creating remote PowerShell session to Exchange Online

$credential = Get-Credential
Import-Module MsOnline
Connect-MsolService -Credential $credential
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
Import-PSSession $exchangeSession -DisableNameChecking
#>

# Gathering Default Domain and removing unwanted characters

$TenantDefaultDomain = Get-MsolDomain | Where-Object {$_.IsDefault -eq 'True'} | Select Name
$TenantDefaultDomain = $TenantDefaultDomain -replace "@{Name="
$TenantDefaultDomain = $TenantDefaultDomain -replace "}"


#############################
### PROGRESS BAR SETTINGS ###
#############################

# Progress Bar Pause Variables
$ProgressBarWait      = 50 # Set the pause length for operations in the main script
$AddPauses            = $false # Set to $true to add pauses that help highlight progress bar functionality
 
<# Simple Progress Bar
$Task                 = "Setting Initial Variables"
Write-Progress -Id $Id -Activity $Activity -Status $Task
if ($AddPauses) { Start-Sleep -Milliseconds $ProgressBarWait }
#>
 
# Complex Progress Bar
$Task                 = "Overall Progress"
$Step                 = 1 # Set this at the beginning of each step
$TotalSteps           = 6 # Manually count the total number of steps in the script
$StepText             = "Setting Initial Variables" # Set this at the beginning of each step

Write-Progress -Id 1 -Activity $Task -Status "Initial processing..." -CurrentOperation "Step $Step of $TotalSteps" -PercentComplete ($Step / $TotalSteps * 100)
if ($AddPauses) { Start-Sleep -Milliseconds $ProgressBarWait }


############################
### STARTING HTML REPORT ###
############################

Import-Module ReportHTML

# Create an empty array for HTML strings
$rpt = @()


# NOTE: From here on we always append to the $rpt array variable.

### OPEN HTML REPORT
$rpt += Get-HtmlOpenPage -TitleText "Office 365 Identities Report for: $TenantDefaultDomain" -LeftLogoString "https://d2oc0ihd6a5bt.cloudfront.net/wp-content/uploads/sites/1064/2015/06/logo.png"

#  Report: Summary Section
$ReportName = "Office 365 Identities"

### TABS DEFINITIONS

$TABarray = @('Mailboxes','Distribution Lists','Office 365 Groups','Mail Contacts','Extended Permissions','Other Identities')
$rpt += Get-HTMLTabHeader -TabNames $TABarray 

#################
### MAILBOXES ###
#################



#// Set progress bar variables
$MBXCounter = 0
$Step = 2

# Write-Progress -Id $Id -Activity $Task -Status "Step $Step of $TotalSteps" -PercentComplete ($Step / $TotalSteps * 100)
# if ($AddPauses) { Start-Sleep -Milliseconds $ProgressBarWait }

$Mailboxes = Get-Mailbox * -ResultSize unlimited | Where-Object {$_.RecipientTypeDetails -ne "DiscoveryMailbox" -and $_.RecipientTypeDetails -ne "SystemMailbox" -and $_.RecipientTypeDetails -ne "$_.SchedulingMailbox"} | Sort-Object DisplayName
$MBXTotal = $Mailboxes.count
$MBX = @()
$MailboxSize = @()

## OPENING TAB
$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(0) -Tabheading ("$Mailboxes")

Foreach ($Mailbox in $Mailboxes)
{

    $MBXName = $Mailbox.Name

    #// Set up progress bar 
    $MBXCounter++
    $GroupPercent = $MBXCounter / $MBXTotal * 100
    Write-Progress -Id 1 -ParentId 0 -Activity "Gathering Mailboxes" -status "Processing item $MBXCounter of $MBXTotal // $($MBXName.ToUpper())" -PercentComplete $GroupPercent
    Start-Sleep -Milliseconds 200

    $Mailbox |
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

    $MBX += $Mailbox
    $MailboxSize += Get-MailboxStatistics -Identity $MBXName

}

    #$MailboxSize | Select -Property @{name="Name";expression={$_.DisplayName}}, @{name="Count";expression={[math]::Round((($_.TotalItemSize.Value.ToString()).Split("(")[1].Split(" ")[0].Replace(",","")/1MB),2)}} -First 5 | Sort Count -Descending
        ## DETAILS SECTION
        
        $rpt += Get-HtmlContentOpen -HeaderText "Mailboxes"
            $SampleListColour = Set-TableRowColor $MBX -Alternating
            $rpt+= Get-HtmlContentTable -ArrayOfObjects $SampleListColour -GroupBy ("Recipient Type Details")
        $rpt += Get-HTMLContentClose


    ## REPORT: CHART ELEMENTS // Chart needs a COUNT column (defined in the SELECT statement of $MailboxesRPT variable)

    $BarObject = Get-HTMLBarChartObject
    $BarObject.ChartStyle.ColorSchemeName = 'Random'


    ## BAR CHART
    $rpt += Get-HTMLHeading -headerSize 3 -headingText "Top 5 Mailboxes by Size (values expressed in MB)"
    $rpt += Get-HTMLBarChart -ChartObject $BarObject -DataSet ($MailboxSize | Select -Property @{name="Name";expression={$_.DisplayName}}, @{name="Count";expression={[math]::Round((($_.TotalItemSize.Value.ToString()).Split("(")[1].Split(" ")[0].Replace(",","")/1MB),2)}} -First 5 | Sort Count -Descending)


    ## CLOSING TAB
    $rpt += Get-HTMLTabContentClose
    

##########################
### DISTRIBUTION LISTS ###
##########################

#// Set progress bar variables 
$DLCounter = 0
$Step++

Write-Progress -Id $Id -Activity $Task -Status "Step $Step of $TotalSteps" -PercentComplete ($Step / $TotalSteps * 100)

$DLs = Get-DistributionGroup -ResultSize unlimited
$DLsTotal = $DLs.count


## OPENING TAB
$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(1) -Tabheading (" ")

## CONTAINER SECTION
# $rpt += Get-HtmlContentOpen -HeaderText "Distribution Lists" # -IsHidden

## LOOPING THROUGH EACH DISTRIBUTION LIST

foreach ($O365DL in $DLs)
        {  
        $DLName = $O365DL.DisplayName

        #// Set up progress bar
        $DLCounter++
        $GroupPercent = $DLCounter / $DLsTotal * 100

        Write-Progress -Activity "Getting Distribution Lists" -status "Processing item $DLCounter of $DLsTotal // $DLName" -PercentComplete $GroupPercent -ParentId $Id
        Start-Sleep -Milliseconds 200

            ## DETAILS SECTION: DISTRIBUTION LIST DETAILS
            $rpt += Get-HtmlContentOpen -HeaderText "Distribution List Name: $O365DL" # -IsHidden
                $rpt += Get-HtmlContentTable ($O365DL | Select -Property @{n='AD Synced';e={$_.IsDirSynced}},
                    @{n='Display Name';e={$_.DisplayName}},
                    @{n='Primary SMTP Address';e={$_.PrimarySmtpAddress}},
                    @{n='Email Addresses';e={$_.EmailAddresses}},
                    @{n='Owner';e={$_.ManagedBy}}) -Fixed
            
            $Members = Get-DistributionGroupMember -Identity $O365DL.Identity
            
                ## DETAILS SECTION: DISTRIBUTION LIST MEMBERS
                $rpt += Get-HtmlContentOpen -HeaderText "Members of: $O365DL"
                    $rpt += Get-HtmlContentTable ($Members | Select DisplayName, Alias, PrimarySMTPAddress | Sort-Object DisplayName) -Fixed
                $rpt += Get-HtmlContentClose
            
            ## CLOSING "DISTRIBUTION LIST DETAILS" SECTION
            $rpt += Get-HtmlContentClose
        }

## CLOSING "CONTAINER" SECTION
# $rpt += Get-HtmlContentClose

## CLOSING TAB
$rpt += Get-HTMLTabContentClose


#########################                               
### OFFICE 365 GROUPS ###
#########################

#// Set progress bar variables 
$GroupsCounter = 0
$Step++
$O365Groups = Get-UnifiedGroup -ResultSize unlimited
$TotalGroups = $O365Groups.Count

Write-Progress -Id $Id -Activity $Task -Status "Step $Step of $TotalSteps" -PercentComplete ($Step / $TotalSteps * 100)

## OPENING TAB
$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(2) -Tabheading (" ")

## OPENING CONTAINER SECTION
# $rpt += Get-HtmlContentOpen -HeaderText "Office 365 Groups" # -IsHidden

## LOOPING THROUGH EACH OFFICE 365 GROUP DETAILS
foreach ($O365Group in $O365Groups)  
        {  

        $GroupName = $O365Group.DisplayName

        #// Set up progress bar
        $GroupsCounter++
        $GroupPercent = $GroupsCounter / $TotalGroups * 100

        Write-Progress -Activity "Getting Office 365 Groups" -status "Processing item $GroupsCounter of $TotalGroups // $GroupName" -PercentComplete $GroupPercent -ParentId $Id
        Start-Sleep -Milliseconds 200

            $Members = Get-UnifiedGroupLinks –Identity $O365Group.Identity –LinkType Members
            
            ## GROUPS
            $rpt += Get-HtmlContentOpen -HeaderText "Group Name: $O365Group" # -IsHidden
                $rpt += Get-HtmlContentTable ($O365Group | Select Owner, DisplayName, PrimarySMTPAddress, EmailAddresses) -Fixed
                
                ## MEMBERS
                $rpt += Get-HtmlContentOpen -HeaderText "Members of: $O365Group"
                    $rpt += Get-HtmlContentTable ($Members | Select Name, PrimarySMTPAddress | Sort-Object Name) -Fixed
                $rpt += Get-HtmlContentClose
            
            ## CLOSING "GROUPS" SECTION
            $rpt += Get-HtmlContentClose
        }

## CLOSING CONTAINER SECTION
# $rpt += Get-HtmlContentClose

## CLOSING TAB
$rpt += Get-HTMLTabContentClose


#####################
### MAIL CONTACTS ###
#####################

#// Set progress bar variables
$ContactsCounter = 0
$Step = 5
$MailContacts = Get-Recipient * -ResultSize unlimited | Where-Object {$_.RecipientType -eq "MailContact"} | Sort-Object DisplayName
$TotalContacts = ($MailContacts.ToString()).Count

Write-Progress -Id $Id -Activity $Task -Status "Step $Step of $TotalSteps" -PercentComplete ($Step / $TotalSteps * 100)

## OPENING TAB
$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(3) -Tabheading (" ")

foreach ($Contact in $MailContacts)
{
    $ContactName = $Contact.DisplayName

    #// Set up progress bar 
    $ContactsCounter = $ContactsCounter + 1
    $GroupPercent = $ContactsCounter / $TotalContacts * 100
    Write-Progress -Activity "Getting Mail Contacts" -status "Processing item $ContactsCounter of $TotalContacts // $ContactName" -PercentComplete $GroupPercent -ParentId $Id
    Start-Sleep -Milliseconds 200
}

    $MailContacts | Select -Property @{n='Display Name';e={$_.DisplayName}},
                @{n='Primary SMTP Address';e={$_.PrimarySmtpAddress}},
                @{n='E-mail Addresses';e={$_.EmailAddresses}}
            
            ## SECTION DETAILS
            # $rpt += Get-HtmlContentOpen -HeaderText "Mail Contacts" # -IsHidden
            $SampleListColour = Set-TableRowColor $MailContacts -Alternating
            $rpt += Get-HtmlContentTable $SampleListColour -Fixed
            # $rpt += Get-HtmlContentClose



## CLOSING TAB
$rpt += Get-HTMLTabContentClose

############################
### EXTENDED PERMISSIONS ###
############################

#// Set progress bar variables
$ExtCounter = 0
$Step++
$ExtendedPermissions = Get-RecipientPermission | Where-Object {$_.Trustee -ne "NT AUTHORITY\SELF"} | Sort Identity
$Totals = $ExtendedPermissions.Count

Write-Progress -Id $Id -Activity $Task -Status "Step $Step of $TotalSteps" -PercentComplete ($Step / $TotalSteps * 100)

## OPENING TAB
$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(4) -Tabheading (" ")

foreach ($Permission in $ExtendedPermissions)
{

     #// Set up progress bar 
    $ExtCounter++
    $GroupPercent = $ExtCounter / $Totals * 100
    Write-Progress -Activity "Getting Extended Permissions" -status "Processing item $ExtCounter of $Totals" -PercentComplete $GroupPercent -ParentId $Id
    Start-Sleep -Milliseconds 200
}

    $ExtendedPermissions | Select -Property @{n='Source Identity';e={$_.Identity}},
                @{n='Trusted Identity';e={$_.Trustee}},
                @{n='Access Rights';e={$_.AccessRights}},
                @{n='Inherited';e={$_.IsInherited}}

                ## SECTION DETAILS
                # $rpt += Get-HtmlContentOpen -HeaderText "Extended Permissions" # -IsHidden
                $SampleListColour = Set-TableRowColor $ExtendedPermissions -Alternating
                $rpt += Get-HtmlContentTable $SampleListColour -Fixed -GroupBy ("Source Identity")
                # $rpt += Get-HtmlContentClose


## CLOSING TAB
$rpt += Get-HTMLTabContentClose

#############################
### OTHER RECIPIENT TYPES ###
#############################

#// Set progress bar variables
$OtherCounter = 0
$Step++
$OtherIdentities = Get-Recipient * -ResultSize unlimited | Sort-Object RecipientType | Where-Object {$_.RecipientType -ne "MailUniversalDistributionGroup" -and $_.RecipientType -ne "MailContact" -and $_.RecipientType -ne "UserMailbox"}
$TotalOther = $OtherIdentities.Count

Write-Progress -Id $Id -Activity $Task -Status "Step $Step of $TotalSteps" -PercentComplete ($Step / $TotalSteps * 100)

## OPENING TAB
$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(5) -Tabheading (" ")

foreach ($Identity in $OtherIdentities)
{

    $OtherName = $Identity.DisplayName

     #// Set up progress bar 
    $OtherCounter++
    $GroupPercent = $OtherCounter / $TotalOther * 100
    Write-Progress -Activity "Getting Other Identities" -status "Processing item $OtherCounter of $Totals // $OtherName " -PercentComplete $GroupPercent -ParentId $Id
    Start-Sleep -Milliseconds 200
}

    $OtherIdentities | Select -Property @{n='Display Name';e={$_.DisplayName}},
                @{n='Recipient Type';e={$_.RecipientType}},
                @{n='Recipient Type Details';e={$_.RecipientTypeDetails}},
                @{n='Primary SMTP Address';e={$_.PrimarySmtpAddress}},
                @{n='E-mail Addresses';e={$_.EmailAddresses}}
                                
                ## SECTION DETAILS
                # $rpt += Get-HtmlContentOpen -HeaderText "Other Identities" # -IsHidde
                $SampleListColour = Set-TableRowColor $OtherIdentities -Alternating
                $rpt += Get-HtmlContentTable $SampleListColour -Fixed
                # $rpt += Get-HtmlContentClose


## CLOSING TAB
$rpt += Get-HTMLTabContentClose


###  CLOSING HTML REPORT
$rpt += Get-HtmlClosePage
  

Function Create-Report
{
    $rptFile = $OutputFolder + "\" + "SMTP-Report-" + "$TenantDefaultDomain" + ".htm"
    $rpt | Set-Content -Path $rptFile -Force
    Invoke-Item $rptFile
    sleep 1
}

Create-Report

# Get-PSSession | Remove-PSSession