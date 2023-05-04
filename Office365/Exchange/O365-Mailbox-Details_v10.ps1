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
#             List of SKU names https://blogs.technet.microsoft.com/treycarlee/2014/12/09/powershell-licensing-skus-in-office-365/
# -------------------------------------------------------------------------------


# Cleaning up Variables

$OutputFolder = $null
$credential = $null
$exchangeSession = $null
$Query = $null
$TenantDefaultDomain = $null
$a = $null

# Get-PSSession | Remove-PSSession
Clear-Host


# Function: Prompt the user where to store HTML result file

Function Select-FolderDialog { 
    param(
        [string]$Description="Select Folder in where to store HTML result file",
        [string]$RootFolder="Desktop"
        )

 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null     

   $objForm = New-Object System.Windows.Forms.FolderBrowserDialog
        $objForm.Rootfolder = $RootFolder
        $objForm.Description = $Description
        $Show = $objForm.ShowDialog()
        IF ($Show -eq "OK") { Return $objForm.SelectedPath }
        ELSE { Write-Error "Operation cancelled by user." }
}

$OutputFolder = Select-FolderDialog

#   Logging Everything
$LogFile = $OutputFolder + "\" + "SMTP-Report" + ".log"

# Start-Transcript -IncludeInvocationHeader -LiteralPath $LogFile -Verbose

#   Creating remote PowerShell session to Exchange Online

$credential = Get-Credential
Import-Module MsOnline
Connect-MsolService -Credential $credential
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
Import-PSSession $exchangeSession -DisableNameChecking
#>

#   Gathering Default Domain
$TenantDefaultDomain = (Get-MsolDomain | Where-Object {$_.IsDefault -eq 'True'}).Name

#############################
### PROGRESS BAR SETTINGS ###
#############################

 
# Progress Bar General Settings
$Task                 = "Overall Progress"
$Step                 = 1 # Set this at the beginning of each step
$TotalSteps           = 9

Write-Progress -Id 0 -Activity $Task -Status "Step $Step of $TotalSteps" -CurrentOperation "Gathering required information. Please stand by . . " -PercentComplete ($Step / $TotalSteps * 100)

#    Query: Licensed Info
$AllLicenses = Get-MsolAccountSku | Where-Object {$_.SkuPartNumber -notlike "*FLOW_FREE*" -and $_.SkuPartNumber -notlike "*WINDOWS_STORE*" -and $_.SkuPartNumber -notlike "*POWER_BI*"}
$AccountName = (Get-MsolAccountSku).AccountName.Item(0).ToString()
$UserLicense = Get-MSOLUser -All | Where-Object {$_.isLicensed -eq "True"}
$UserCount   = $UserLicense.Count

#    Query: Mailboxes
$UserMailboxes = Get-Mailbox -ResultSize unlimited | Where-Object {$_.RecipientTypeDetails -eq "UserMailbox"}

#    Query: Distribution Groups
$DLs = Get-DistributionGroup -ResultSize unlimited

#################
### LICENSING ###
#################

### Progress Bar
$Step++
Write-Progress -Id 0 -Activity $Task -Status "Step $Step of $TotalSteps" -CurrentOperation "Getting Licensing Information . . " -PercentComplete ($Step / $TotalSteps * 100)

$Counter = 0

foreach ($item in $AllLicenses){
    $Counter++
    Write-Progress -Id 1 -ParentId 0 -Activity "Looping through all Licenses in tenant" -Status "Processing $($Counter) of $($AllLicenses.Count)" -CurrentOperation $Item.AccountSkuId -PercentComplete (($Counter/$AllLicenses.Count) * 100)
}

$Purchased = ($AllLicenses.ActiveUnits | Measure-Object -Sum).Sum
$Consumed = ($AllLicenses.ConsumedUnits | Measure-Object -Sum).Sum
$Remaining = ($Purchased - $Consumed)

Write-Host "Total Purchased:" $Purchased -ForegroundColor Green
Write-Host "Total Used:" $Consumed -ForegroundColor Yellow
Write-Host "Remaining:" $Remaining


#################
### MAILBOXES ###
#################

$UserIndex = -1 # Initialize counter with a negative value due this variable represents the object index and it'll grow within the foreach loop
$MBXTable = @() # Hash Table Result
$MBXRPT = @() # Used for HTML Report
$MBBar = 0

$Step++
Write-Progress -Id 0 -Activity $Task -Status "Step $Step of $TotalSteps" -CurrentOperation "Working on Mailboxes" -PercentComplete ($Step / $TotalSteps * 100)

foreach ($MBX in $Mailboxes){
    Write-Progress -Id 1 -Activity "User Mailboxes" -Status "Working on" -CurrentOperation $($MBX.'Display Name') -PercentComplete (($MBBar / $Mailboxes.Count) * 100) -ParentId 0
    $MBBar++
    $Size = Get-MailboxStatistics -Identity $($MBX.PrimarySmtpAddress) | Select-Object @{name="Size";expression={[math]::Round((($_.TotalItemSize.Value.ToString()).Split("(")[1].Split(" ")[0].Replace(",","")/1GB),2)}}
    $MBXRPT = $MBXRPT + $Size
    $Percent = (($Size.Size * 100 / ($MBX.ProhibitSendReceiveQuota.Substring(0,3)).Trim()))/100
    $UserIndex++

    $Hash =  [ordered]@{
        Identity           = $MBX.Identity
        PrimarySMTPAddress = $MBX.PrimarySMTPAddress
        LicenseAssigned    = ($UserLicense.Licenses.AccountSkuId.Item($UserIndex) -replace ("$AccountName" + ":")," ").Trim()
        MailboxSize        = "$($Size.Size) GB"
        MailboxQuota       = "$(($MBX.ProhibitSendReceiveQuota.Substring(0,3)).Trim()) GB"
        PercentUsed        = "{0:P0}" -f $Percent
                }

    $MBXObject = New-Object psobject -Property $Hash
    $MBXTable += $MBXObject

}

$MailboxesProps = $MBXTable | Sort-Object DisplayName |
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


## REPORT: CHART ELEMENTS // Chart needs both a NAME column and COUNT column (defined in the SELECT statement).
##         COUNT column can be manually defined or being part of the result of a Group-Object filter.


##########################
### DISTRIBUTION LISTS ###
##########################

$Step++
Write-Progress -Id 0 -Activity $Task -Status "Step $Step of $TotalSteps" -CurrentOperation "Working on Distribution Lists" -PercentComplete ($Step / $TotalSteps * 100)
# Start-Sleep -Milliseconds 50

$Counter = 0

foreach ($O365DL in $DLs) {
    $Counter++
    Write-Progress -Id 1 -ParentId 0 -Activity "Working on Distribution Lists" -Status "Working on" -CurrentOperation $($O365DL.Name) -PercentComplete ($Counter / $DLs.Count * 100)
    # Start-Sleep -Milliseconds 50

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
Write-Progress -Id 0 -Activity $Task -Status "Step $Step of $TotalSteps" -CurrentOperation "Working on Office 365 Groups" -PercentComplete ($Step / $TotalSteps * 100)
Start-Sleep -Milliseconds 50

$O365Groups = Get-UnifiedGroup -ResultSize unlimited

## OPENING TAB
$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(3) -Tabheading (" ")

## OPENING CONTAINER SECTION
# $rpt += Get-HtmlContentOpen -HeaderText "Office 365 Groups" # -IsHidden

## LOOPING THROUGH EACH OFFICE 365 GROUP DETAILS

$O365GroupsCounter = 0

foreach ($O365Group in $O365Groups)  
        {  
            $O365GroupsCounter++
            Write-Progress -Id 1 -ParentId 0 -Activity "Working on Office 365 Groups" -Status "Working on" -CurrentOperation $($O365Group.DisplayName) -PercentComplete ($O365GroupsCounter / $O365Groups.Count * 100)
            Start-Sleep -Milliseconds 50

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
Write-Progress -Id 0 -Activity $Task -Status "Step $Step of $TotalSteps" -CurrentOperation "Working on Mail Contacts" -PercentComplete ($Step / $TotalSteps * 100)
Start-Sleep -Milliseconds 50

## OPENING TAB
$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(4) -Tabheading (" ")

$ContactsCounter = 0

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

foreach ($Contact in $MailContacts) #   Progress Bar
{
    $ContactsCounter++
    Write-Progress -Id 1 -ParentId 0 -Activity "Working on Mail Contacts" -Status "Working on" -CurrentOperation $($Contact.DisplayName) -PercentComplete ($ContactsCounter / $MailContacts.Count * 100)
    Start-Sleep -Milliseconds 50
}

## CLOSING TAB
$rpt += Get-HTMLTabContentClose

############################
### EXTENDED PERMISSIONS ###
############################

$Step++
Write-Progress -Id 0 -Activity $Task -Status "Step $Step of $TotalSteps" -CurrentOperation "Working on Extended Permissions" -PercentComplete ($Step / $TotalSteps * 100)
Start-Sleep -Milliseconds 50

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

$EP_Counter = 0

foreach ($EP in $ExtendedPermissions) #   Progress Bar
{
    $EP_Counter++
    Write-Progress -Id 1 -ParentId 0 -Activity "Extended Permissions" -Status "Working on" -CurrentOperation $($EP.'Source Identity') -PercentComplete ($EP_Counter / $ExtendedPermissions.Count * 100)
    Start-Sleep -Milliseconds 50
}

#############################
### OTHER RECIPIENT TYPES ###
#############################

$Step++
Write-Progress -Id 0 -Activity $Task -Status "Step $Step of $TotalSteps" -CurrentOperation "Looking for other recipient types" -PercentComplete ($Step / $TotalSteps * 100)
Start-Sleep -Milliseconds 50

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

$OtherCounter = 0

foreach ($Other in $OtherIdentities) #   Progress Bar
{
    $OtherCounter++
    Write-Progress -Id 1 -ParentId 0 -Activity "Looking for other recipient types" -Status "Working on" -CurrentOperation $($Other.'Display Name') -PercentComplete ($OtherCounter / $OtherIdentities.Count * 100)
    Start-Sleep -Milliseconds 50

}

#############################
### CREATING HTML REPORT  ###
#############################

$Step++
Write-Progress -Id 0 -Activity $Task -Status "Step $Step of $TotalSteps" -CurrentOperation "Building HTML Report" -PercentComplete ($Step / $TotalSteps * 100)

Import-Module ReportHTML

# Create an empty array for HTML strings
$rpt = @()

# NOTE: From here on we always append to the $rpt array variable.

### OPEN HTML REPORT
$rpt += Get-HtmlOpenPage -TitleText "Office 365 Identities Report for: $TenantDefaultDomain" -LeftLogoString "https://ownakoa.com/wp-content/uploads/2016/09/TeamLogic-IT-Logo.png"

#  Report: Summary Section
$ReportName = "Office 365 Identities"

### TABS DEFINITIONS

$TABarray = @('Licensing','Mailboxes','Distribution Lists','Office 365 Groups','Mail Contacts','Extended Permissions','Other Identities')
$rpt += Get-HTMLTabHeader -TabNames $TABarray 


## OPENING TAB: LICENSING
$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(0) -Tabheading (" ") # LICENSING TAB

$PurchasedChart = Get-HTMLPieChartObject
$UsedChart = Get-HTMLPieChartObject

$DataSetPurchased = $AllLicenses | Select-Object @{n="Name";e={$_.AccountSkuId}}, @{n="Count";e={$_.ActiveUnits}}
$DataSetConsumed = $AllLicenses | Select-Object @{n="Name";e={$_.AccountSkuId}}, @{n="Count";e={$_.ConsumedUnits}}

#    Overall Summary
$rpt+= Get-HtmlContentOpen -HeaderText "Licenses Info"
    $rpt+= Get-HtmlContentOpen  -HeaderText "Summary"
        $rpt += Get-HtmlContenttext -Heading "Purchased Licenses" -Detail $PurchasedTOT
        $rpt += Get-HtmlContenttext -Heading "Used Licenses" -Detail $ConsumedTOT
        $rpt += Get-HtmlContenttext -Heading "Remaining Licenses (Unnasigned)" -Detail $Remaining
    $rpt+= Get-HtmlContentClose

#    Licensed Users Summary
    $rpt+= Get-HtmlContentOpen -HeaderText "Licensed Users"
        $rpt+= Get-HtmlContentTable ($MBXTable | Sort-Object Identity) -Fixed
    $rpt+= Get-HtmlContentClose

#    Charts
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


$rpt += Get-HTMLTabContentClose # Closing LICENSING TAB

## OPENING TAB: MAILBOXES
$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(1) -Tabheading ("$Mailboxes")

    $PieObject = Get-HTMLBarChartObject
    $PieObject.ChartStyle.ColorSchemeName = 'Random'

    ## DETAILS SECTION
        
    $rpt += Get-HtmlContentOpen -HeaderText "Mailboxes"
        $SampleListColour = Set-TableRowColor $MailboxesProps -Alternating
        $rpt+= Get-HtmlContentTable -ArrayOfObjects $SampleListColour -GroupBy ("Recipient Type Details")
    $rpt += Get-HTMLContentClose

    ## BAR CHART
    $rpt += Get-HTMLHeading -headerSize 3 -headingText "Top 5 Mailboxes by Size (values expressed in GB)"
    $rpt += Get-HTMLBarChart -ChartObject $PieObject -DataSet ($MBXRPT | Sort-Object Count -Descending | Select -First 5)

$rpt += Get-HTMLTabContentClose # CLOSING MAILBOXES TAB

## OPENING TAB: Distribution Lists
$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(2) -Tabheading (" ")

$rpt += Get-HtmlClosePage # Closing HTML Report

Write-Progress -Id 0 -Activity $Task -Completed
Write-Progress -Id 1 -Activity $Task -Completed



Function Create-Report{
    $rptFile = $OutputFolder + "\" + "SMTP-Report-" + "$TenantDefaultDomain" + ".htm"
    $rpt | Set-Content -Path $rptFile -Force
    Invoke-Item $rptFile
    sleep 1
}

Create-Report

Get-PSSession | Remove-PSSession

Stop-Transcript