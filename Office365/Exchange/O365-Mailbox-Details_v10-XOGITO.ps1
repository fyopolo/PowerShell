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
# 04/19/2018  Feature Added: Licensing information (the 1st Tab).
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

$credential = Get-Credential
Import-Module MsOnline
Connect-MsolService -Credential $credential
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
Import-PSSession $exchangeSession -DisableNameChecking

#>

# Gathering Default Domain and removing unwanted characters

$TenantDefaultDomain = (Get-MsolDomain | Where-Object {$_.IsDefault -eq 'True'}).Name


#############################
### PROGRESS BAR SETTINGS ###
#############################

 
<# Simple Progress Bar
$Task                 = "Setting Initial Variables"
Write-Progress -Id $Id -Activity $Activity -Status $Task
if ($AddPauses) { Start-Sleep -Milliseconds $ProgressBarWait }
#>
 
# Complex Progress Bar
$Task                 = "Overall Progress"
$Step                 = 1 # Set this at the beginning of each step
$TotalSteps           = 7

Write-Progress -Id 1 -Activity $Task -Status "Step $Step of $TotalSteps" -CurrentOperation "Importing Modules" -PercentComplete ($Step / 6 * 100)


############################
### STARTING HTML REPORT ###
############################



Import-Module ReportHTML

# Create an empty array for HTML strings
$rpt = @()

# NOTE: From here on we always append to the $rpt array variable.


### OPEN HTML REPORT
$rpt += Get-HtmlOpenPage -TitleText "Office 365 Identities Report for: $TenantDefaultDomain" -LeftLogoString "https://media.licdn.com/dms/image/C510BAQHxfEbEziGgMA/company-logo_200_200/0?e=2159024400&v=beta&t=uk9oFB6BCELIOwK7YWxLGZ9e0G_OOexmtv8upYmNFr8"

#  Report: Summary Section
$ReportName = "Office 365 Identities"

### TABS DEFINITIONS

$TABarray = @('Licensing','Mailboxes','Distribution Lists','Office 365 Groups','Mail Contacts','Extended Permissions','Other Identities')
$rpt += Get-HTMLTabHeader -TabNames $TABarray 



#################
### LICENSING ###
#################

### Progress Bar
$Step++
Write-Progress -Id 1 -Activity $Task -Status "Step $Step of $TotalSteps" -CurrentOperation "Working on Mailboxes" -PercentComplete ($Step / $TotalSteps * 100)

## OPENING TAB
$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(0) -Tabheading (" ")

## GET LICENSES


$AllLicenses = Get-MsolAccountSku | Where-Object {$_.SkuPartNumber -notlike "*FLOW_FREE*" -and $_.SkuPartNumber -notlike "*WINDOWS_STORE*" -and $_.SkuPartNumber -notlike "*POWER_BI*" -and $_.SkuPartNumber -notlike "*MS_TEAMS_IW*"}

$PurchasedTOT = ($AllLicenses.ActiveUnits | Measure-Object -Sum).Sum
$ConsumedTOT = ($AllLicenses.ConsumedUnits | Measure-Object -Sum).Sum
$Remaining = ($PurchasedTOT - $ConsumedTOT)

Write-Host "Total Purchased:" $PurchasedTOT -ForegroundColor Green
Write-Host "Total Used:" $ConsumedTOT -ForegroundColor Yellow
Write-Host "Remaining:" $Remaining


## CHARTS

$PurchasedChart = Get-HTMLPieChartObject
$UsedChart = Get-HTMLPieChartObject

$DataSetPurchased = $AllLicenses | Select-Object @{n="Name";e={$_.AccountSkuId}}, @{n="Count";e={$_.ActiveUnits}}
$DataSetConsumed = $AllLicenses | Select-Object @{n="Name";e={$_.AccountSkuId}}, @{n="Count";e={$_.ConsumedUnits}}


$rpt+= Get-HtmlContentOpen -HeaderText "Licenses Info"
    $rpt+= Get-HtmlContentOpen  -HeaderText "Summary"
        $rpt += Get-HtmlContenttext -Heading "Purchased Licenses" -Detail $PurchasedTOT
        $rpt += Get-HtmlContenttext -Heading "Used Licenses" -Detail $ConsumedTOT
        $rpt += Get-HtmlContenttext -Heading "Remaining Licenses (Unnasigned)" -Detail $Remaining
    $rpt+= Get-HtmlContentClose

    $rpt+= Get-HtmlContentOpen -HeaderText "Charts"
	    $rpt+= get-HtmlColumn1of2
		    $rpt+= Get-HtmlContentOpen -HeaderText "Purchased Licenses"
			    $rpt += Get-HTMLPieChart -ChartObject $PurchasedChart -DataSet $DataSetPurchased
		    $rpt+= Get-HtmlContentClose
	    $rpt+= get-htmlColumnClose

	    $rpt+= get-htmlColumn2of2
		    $rpt+= Get-HtmlContentOpen -HeaderText "Used Licenses"
			    $rpt += Get-HTMLPieChart -ChartObject $UsedChart -DataSet $DataSetConsumed
		    $rpt+= Get-HtmlContentClose
	    $rpt+= get-htmlColumnClose
    $rpt+= Get-HtmlContentClose
$rpt+= Get-HtmlContentClose 



$rpt += Get-HTMLTabContentClose



#################
### MAILBOXES ###
#################

### Progress Bar
$Step++
Write-Progress -Id 1 -Activity $Task -Status "Step $Step of $TotalSteps" -CurrentOperation "Working on Mailboxes" -PercentComplete ($Step / $TotalSteps * 100)

### Query

    $Mailboxes = Get-Mailbox * -ResultSize unlimited |
    Where-Object {$_.RecipientTypeDetails -ne "DiscoveryMailbox" -and $_.RecipientTypeDetails -ne "SystemMailbox" -and $_.RecipientTypeDetails -ne "SchedulingMailbox"} |
    Sort-Object DisplayName |
    Select -Property @{n='Recipient Type Details';e={$_.RecipientTypeDetails}},
                @{n='Display Name';e={$_.DisplayName}},
                @{n='Recipient Type';e={$_.RecipientType}},
                @{n='Mailbox Enabled';e={$_.IsMailboxEnabled}},
                @{n='Mailbox Created On';e={$_.WhenMailboxCreated}},
                @{n='Primary SMTP Address';e={$_.PrimarySmtpAddress}},
                @{n='E-mail Addresses';e={($_.EmailAddresses).Split()}},
                @{n='Mailbox Size';e={Get-MailboxStatistics -Identity ($Mailbox.'Primary SMTP Address') | Select-Object @{name="Name";expression={$_.DisplayName}}, @{name="Count";expression={[math]::Round((($_.TotalItemSize.Value.ToString()).Split("(")[1].Split(" ")[0].Replace(",","")/1GB),2)}}}},
                @{n='AD Synchronized';e={$_.IsDirSynced}},
                @{n='Shared Mailbox';e={$_.IsShared}},
                @{n='Forwarding SMTP Address';e={$_.ForwardingSmtpAddress}},
                @{n='Archive Status';e={$_.ArchiveStatus}},
                @{n='Archive Name';e={$_.ArchiveName}},
                @{n='Archive Database Name';e={$_.ArchiveDatabase}},
                @{n='Retention Policy Name';e={$_.RetentionPolicy}}


    ## REPORT: CHART ELEMENTS // Chart needs both a NAME column and COUNT column (defined in the SELECT statement).
    ##         COUNT column can be manually defined or being part of the result of a Group-Object filter.
    
    $MailboxesRPT = @()

    Foreach ($Mailbox in $Mailboxes)
    {
        $MailboxesRPT += Get-MailboxStatistics -Identity ($Mailbox.'Primary SMTP Address') | Select-Object @{name="Name";expression={$_.DisplayName}}, @{name="Count";expression={[math]::Round((($_.TotalItemSize.Value.ToString()).Split("(")[1].Split(" ")[0].Replace(",","")/1GB),2)}}
    }
   

    $PieObject = Get-HTMLBarChartObject
    $PieObject.ChartStyle.ColorSchemeName = 'Random'

    ## OPENING TAB
    $rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(1) -Tabheading ("$Mailboxes")
    
        ## DETAILS SECTION
        
        $rpt += Get-HtmlContentOpen -HeaderText "Mailboxes"
            $SampleListColour = Set-TableRowColor $Mailboxes -Alternating
            $rpt+= Get-HtmlContentTable -ArrayOfObjects $SampleListColour -GroupBy ("Recipient Type Details")
        $rpt += Get-HTMLContentClose

        ## BAR CHART
        $rpt += Get-HTMLHeading -headerSize 3 -headingText "Top 5 Mailboxes by Size (values expressed in GB)"
        $rpt += Get-HTMLBarChart -ChartObject $PieObject -DataSet ($MailboxesRPT | Sort-Object Count -Descending | Select -First 5)

    ## CLOSING TAB
    $rpt += Get-HTMLTabContentClose

  


##########################
### DISTRIBUTION LISTS ###
##########################

$Step++
Write-Progress -Id 1 -Activity $Task -Status "Step $Step of $TotalSteps" -CurrentOperation "Working on Distribution Lists" -PercentComplete ($Step / $TotalSteps * 100)

$DLs = Get-DistributionGroup -ResultSize unlimited

## OPENING TAB
$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(2) -Tabheading (" ")

## CONTAINER SECTION
# $rpt += Get-HtmlContentOpen -HeaderText "Distribution Lists" # -IsHidden

## LOOPING THROUGH EACH DISTRIBUTION LIST

foreach ($O365DL in $DLs)
        {  
            
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

$Step++
Write-Progress -Id 1 -Activity $Task -Status "Step $Step of $TotalSteps" -CurrentOperation "Working on Office 365 Groups" -PercentComplete ($Step / $TotalSteps * 100)

$O365Groups = Get-UnifiedGroup -ResultSize unlimited

## OPENING TAB
$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(3) -Tabheading (" ")

## OPENING CONTAINER SECTION
# $rpt += Get-HtmlContentOpen -HeaderText "Office 365 Groups" # -IsHidden

## LOOPING THROUGH EACH OFFICE 365 GROUP DETAILS
foreach ($O365Group in $O365Groups)  
        {  
            
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

$Step++
Write-Progress -Id 1 -Activity $Task -Status "Step $Step of $TotalSteps" -CurrentOperation "Working on Mail Contacts" -PercentComplete ($Step / $TotalSteps * 100)

## OPENING TAB
$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(4) -Tabheading (" ")

$MailContacts = Get-Recipient * -ResultSize unlimited |
         Sort-Object RecipientType, DisplayName |
         Where-Object {$_.RecipientType -eq "MailContact"} |
                Select -Property @{n='Display Name';e={$_.DisplayName}},
                @{n='Primary SMTP Address';e={$_.PrimarySmtpAddress}},
                @{n='E-mail Addresses';e={$_.EmailAddresses}}
            
            ## SECTION DETAILS
            $SampleListColour = Set-TableRowColor $MailContacts -Alternating
            $rpt += Get-HtmlContentTable $SampleListColour -Fixed
            # $rpt += Get-HtmlContentClose

## CLOSING TAB
$rpt += Get-HTMLTabContentClose

############################
### EXTENDED PERMISSIONS ###
############################

$Step++
Write-Progress -Id 1 -Activity $Task -Status "Step $Step of $TotalSteps" -CurrentOperation "Working on Extended Permissions" -PercentComplete ($Step / $TotalSteps * 100)

## OPENING TAB
$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(5) -Tabheading (" ")

$ExtendedPermissions = Get-RecipientPermission | Where-Object {$_.Trustee -ne "NT AUTHORITY\SELF"} |
           Sort Identity |
           Select -Property @{n='Source Identity';e={$_.Identity}},
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


### OTHER RECIPIENT TYPES

$Step++
Write-Progress -Id 1 -Activity $Task -Status "Step $Step of $TotalSteps" -CurrentOperation "Looking for other recipient types" -PercentComplete ($Step / $TotalSteps * 100)

## OPENING TAB
$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(6) -Tabheading (" ")

$OtherIdentities = Get-Recipient * -ResultSize unlimited |
         Sort-Object RecipientType |
         Where-Object {$_.RecipientType -ne "MailUniversalDistributionGroup" -and $_.RecipientType -ne "MailContact" -and $_.RecipientType -ne "UserMailbox"} |
         Select -Property @{n='Display Name';e={$_.DisplayName}},
                @{n='Recipient Type';e={$_.RecipientType}},
                @{n='Recipient Type Details';e={$_.RecipientTypeDetails}},
                @{n='Primary SMTP Address';e={$_.PrimarySmtpAddress}},
                @{n='E-mail Addresses';e={$_.EmailAddresses}}
                                
                ## SECTION DETAILS
                # $rpt += Get-HtmlContentOpen -HeaderText "Other Identities" # -IsHidde
                $SampleListColour = Set-TableRowColor $OtherIdentities -Alternating
                $rpt += Get-HtmlContentTable $SampleListColour -Fixed -GroupBy ("Recipient Type Details")
                # $rpt += Get-HtmlContentClose

## CLOSING TAB
$rpt += Get-HTMLTabContentClose


###  CLOSING HTML REPORT
$rpt += Get-HtmlClosePage

Write-Progress -Id 1 -Activity $Task -Completed

Function Create-Report
{
    $rptFile = $OutputFolder + "\" + "SMTP-Report-" + "$TenantDefaultDomain" + ".htm"
    $rpt | Set-Content -Path $rptFile -Force
    Invoke-Item $rptFile
    sleep 1
}

Create-Report

Get-PSSession | Remove-PSSession


<#
Get-Mailbox | Get-MailboxStatistics | Select DisplayName, TotalItemSize | sort totalitemsize

Get-Mailbox -ResultSize unlimited -Filter { RecipientTypeDetails -eq "UserMailbox" } | Sort DisplayName | Select DisplayName, UserPrincipalName, Alias, PrimarySmtpAddress

Get-Mailbox -Identity ben.navarro | fl

Get-Mailbox -Filter { RecipientTypeDetails -eq "SharedMailbox" }

Get-Mailbox -Identity hr@cpc-sb.com | Select PrimarySmtpAddress, EmailAddresses | fl

Get-Mailbox | Where-Object { $_.EmailAddresses -like "*zalexisemailforward*" }
#>