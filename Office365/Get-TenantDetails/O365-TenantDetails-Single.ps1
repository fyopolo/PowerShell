# -------------------------------------------------------------------------------
# Script: O365-TenantDetails-Single.ps1
# Author: Fernando Yopolo
# Date: 03/03/2016
# Keywords: Exchange, Email, SMTP, Office 365
# Comments: Gather Office 365 Tenant details and output to HTML
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
# 03/21/2020  Changed SKU list management.
#             A new function added will prompt for opening a XLSX file with the SKU List.
#             This change needs ImportExel module // Install-Module ImportExcel -Force
# 03/27/2020  SKU Names have been translated into a readable list for a human being.
# 04/04/2020  Feature Added: Function to limit the amount of results for each query.
#             This helps reduce script execution time for very large environments.
# -------------------------------------------------------------------------------

Clear-Host

# Functions

Function Load-XLSFile($initialDirectory) {  
    [System.Reflection.Assembly]::LoadWithPartialName(“System.windows.forms”) | Out-Null

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.Title = "Select SKU File"
    $OpenFileDialog.Filter = “Excel Files (*.xlsx)| *.xlsx”
    $Button = $OpenFileDialog.ShowDialog()
    $OpenFileDialog.FileName | Out-Null
    IF ($Button -eq "OK") { Return $OpenFileDialog.FileName }
    ELSE { Write-Error "Operation cancelled by user. Aborting script execution."; Break }
}

Function Select-Folder { 
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $OpenFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog

    $Topmost = New-Object System.Windows.Forms.Form
    $Topmost.TopMost = $True
    $Topmost.MinimizeBox = $True

    $OpenFolderDialog.ShowNewFolderButton = $True
    $OpenFolderDialog.Rootfolder = "Desktop"
    $OpenFolderDialog.Description = "Select Folder in where to store HTML result file"
    $Button = $OpenFolderDialog.ShowDialog($Topmost)
    IF ($Button -eq "OK") { Return $OpenFolderDialog.SelectedPath }
    ELSE { Write-Error "Operation cancelled by user. Aborting script execution"; Break }
}

Function Set-ResultSize {

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Result Size Input'
    $form.Size = New-Object System.Drawing.Size(300,220)
    $form.StartPosition = 'CenterScreen'
    $form.MaximizeBox = $false

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(75,140)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'OK'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(150,140)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,20)
    $label.Size = New-Object System.Drawing.Size(280,20)
    $label.Text = 'Results to return from each query:'
    $form.Controls.Add($label)

    $listBox = New-Object System.Windows.Forms.ListBox
    $listBox.Location = New-Object System.Drawing.Point(10,40)
    $listBox.Size = New-Object System.Drawing.Size(260,20)
    $listBox.Height = 100

    [void] $listBox.Items.Add('10')
    [void] $listBox.Items.Add('20')
    [void] $listBox.Items.Add('50')
    [void] $listBox.Items.Add('100')
    [void] $listBox.Items.Add('500')
    [void] $listBox.Items.Add('Unlimited')

    $form.Controls.Add($listBox)

    $form.Topmost = $true

    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK)
    {
        $x = $listBox.SelectedItem
        $x
    }
}

Function Create-Report {
    $OutputFolder = Select-Folder
    $rptFile = $OutputFolder + "\" + "SMTP-Report-" + "$TenantDefaultDomain" + ".htm"
    $rpt | Set-Content -Path $rptFile -Force
    Invoke-Item $rptFile
    Start-Sleep 1
}

$LogFile = "C:\TEMP\O365-Tenant-Report.log"
# Start-Transcript -IncludeInvocationHeader -LiteralPath $LogFile -Verbose

#############################
### PROGRESS BAR SETTINGS ###
#############################

# Progress Bar General Settings
$Task        = "Overal Progress..."
$Step        = 1
$TotalSteps  = 10

###############
###  BEGIN  ###
###############

#    Limit Result Size (for very large environments)
$ResultSize = Set-ResultSize

#<#   Creating remote PowerShell session to Exchange Online

# $credential = Get-Credential -Message "Enter Global Admin credentials"
# Import-Module MsOnline
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -ShowProgress $true
# Connect-MsolService


#>

#    Import: SkuID List file
$SkuList = Import-Excel -Path $(Load-XLSFile)

#    Query: Default Domain
$TenantDomains = Get-MsolDomain
$TenantDefaultDomain = ($TenantDomains | Where-Object {$_.IsDefault -eq 'True'}).Name

Write-Progress -Id 0 -Activity $Task -Status "Step $Step of $TotalSteps" -CurrentOperation "Querying the Tenant. Please stand by..." -PercentComplete ($Step / $TotalSteps * 100)

#################
### MAILBOXES ###
#################

$UserMailboxes = Get-Mailbox -ResultSize $ResultSize | Where-Object {$_.RecipientTypeDetails -eq "UserMailbox" -or $_.RecipientTypeDetails -eq "SharedMailbox"} # Where-Object {$_.SKUAssigned -eq "True"}
$Step++
Write-Progress -Id 0 -Activity $Task -Status "Step $Step of $TotalSteps" -CurrentOperation "Working on Mailboxes" -PercentComplete ($Step / $TotalSteps * 100)

$Mailboxes = @()
$MailboxA = @()
$MBXSizeRPT = @()
$Counter = 0

foreach ($MBX in $UserMailboxes) {
    $Counter++
    Write-Progress -Id 1 -ParentId 0 -Activity $MBX.RecipientTypeDetails -Status "Processing $($Counter) of $($UserMailboxes.Count)" -CurrentOperation $MBX.DisplayName -PercentComplete (($Counter/$UserMailboxes.Count) * 100)

    $Size = Get-MailboxStatistics -Identity $($MBX.PrimarySmtpAddress) | Select-Object @{name="Size";expression={[math]::Round((($_.TotalItemSize.Value.ToString()).Split("(")[1].Split(" ")[0].Replace(",","")/1GB),2)}}, @{name="Name";expression={$_.DisplayName}}, @{name="Count";expression={[math]::Round((($_.TotalItemSize.Value.ToString()).Split("(")[1].Split(" ")[0].Replace(",","")/1GB),2)}}
    $MBXSizeRPT += $Size | Select-Object Name, Count
    $Percent = (($Size.Size * 100 / ($($MBXQuota = $MBX.ProhibitSendReceiveQuota.Split(" ");[string]$MBXQuota[0..($MBXQuota.count-4)]))))/100

    IF (-NOT([string]::IsNullOrWhiteSpace($MBX.ForwardingSmtpAddress))) { $Case = 1 } ELSE { $Case = 3 }
    IF (-NOT([string]::IsNullOrWhiteSpace($MBX.ForwardingAddress))) { $Case = 2 } ELSE { $Case = 3 }
    IF ([string]::IsNullOrWhiteSpace($MBX.ForwardingAddress) -and ([string]::IsNullOrWhiteSpace($MBX.ForwardingSmtpAddress))) { $Case = 3 }

    SWITCH ($Case){
        1 { $Forward = ($MBX.ForwardingSmtpAddress).TrimStart("smtp:");Break }
        2 { $Forward = $MBX.ForwardingAddress + " [Mail Contact]";Break }
        3 { $Forward = $null;Break }
    }

    $MailboxA = $null
    [array]$MBXAlias = $($MBX.EmailAddresses | Where-Object {$_ -cmatch "smtp:"})
    IF (-NOT([string]::IsNullOrWhiteSpace($MBXAlias))) {
        foreach($MAS in $MBXAlias) {
            $MailboxA += "$($MAS.TrimStart("smtp:"))`r`n"
        }
    } ELSE { $MailboxA = $null }

    $Hash =  [ordered]@{
        'Display Name'             =    $MBX.DisplayName
        'Recipient Type Details'   =    $MBX.RecipientTypeDetails
        'Mailbox Enabled'          =    $MBX.IsMailboxEnabled
        'Mailbox Created On'       =    $MBX.WhenMailboxCreated
        'Primary SMTP Address'     =    $MBX.PrimarySMTPAddress
         Aliases                   =    $MailboxA
        'Mailbox Size'             =    "$($Size.Size) GB"
        'Mailbox Quota'            =    $($MBXQuota = $MBX.ProhibitSendReceiveQuota.Split("(");[string]$MBXQuota[0..($MBXQuota.count-2)])
        'Percent Used'             =    "{0:P0}" -f $Percent
        'Forwarding Address'       =    $Forward
        'Archive Status'           =    $MBX.ArchiveStatus
        'Archive Name'             =    $MBX.ArchiveName
        'Retention Policy Name'    =    $MBX.RetentionPolicy
    }
    
    $MBXObject = New-Object psobject -Property $Hash
    $Mailboxes += $MBXObject
    
}
# $Mailboxes | Out-GridView

#################
### LICENSING ###
#################

$LicInit = Get-MsolAccountSku
$AllLicenses = $LicInit | Where-Object {$_.TargetClass -eq "User" -and $_.ActiveUnits -lt 9000 -and $_.AccountSkuId -notlike "*TEAMS_EXPLORATORY*"} | Select-Object AccountSkuId, SkuPartNumber, TargetClass, ActiveUnits, WarningUnits, ConsumedUnits

$Step++
Write-Progress -Id 0 -Activity $Task -Status "Step $Step of $TotalSteps" -CurrentOperation "Getting Licensing Information . . " -PercentComplete ($Step / $TotalSteps * 100)
$Counter = 0

foreach ($Item in $AllLicenses){
    $Counter++
    $CO = "$(($SkuList | Where-Object {$_.SkuId -eq $Item.SkuPartNumber}).Name) `r"
    Write-Progress -Id 1 -ParentId 0 -Activity "Looping through all Licenses in tenant" -Status "Processing $($Counter) of $($AllLicenses.Count)" -CurrentOperation $CO -PercentComplete (($Counter/$AllLicenses.Count) * 100)
}

$Counter = 0
$LicensedUsers = Get-MsolUser -All | Where-Object {$_.isLicensed -eq "True"}
foreach ($Item in $LicensedUsers){
    $Counter++
    Write-Progress -Id 1 -ParentId 0 -Activity "Getting Users with Licenses" -Status "Processing $($Counter) of $($LicensedUsers.Count)" -CurrentOperation $Item.DisplayName -PercentComplete (($Counter/$LicensedUsers.Count) * 100)
}

# $UserCount   = $LicensedUsers.Count

$LicensedUsersDetails = @()
$Counter = 0
$Licenses = @()

$Step++
Write-Progress -Id 0 -Activity $Task -Status "Step $Step of $TotalSteps" -CurrentOperation "Looping throughout Tenant licensed users" -PercentComplete ($Step / $TotalSteps * 100)

foreach ($Item in $LicensedUsers) {
    $Counter++
    $Licenses = $null
    $Li = $null
    
    Write-Progress -Id 1 -ParentId 0 -Activity "Getting details for users" -Status "Processing $($Counter) of $($LicensedUsers.Count)" -CurrentOperation $Item.DisplayName -PercentComplete (($Counter/$LicensedUsers.Count) * 100)

    $Sku = $Item.LicenseAssignmentDetails.AccountSku.SkuPartNumber

    #    IF A USER HAS MORE THAN ONE LICENSE ASSIGNED, LOOP THROUGH EACH AND ONE OF THEM
    #    AND PRESENT IT ONE PER LINE USING REGEX  (`r)

    foreach ($Li in $Sku){ $Licenses += "$(($SkuList | Where-Object {$_.SkuId -eq $Li}).Name) `r" }
        
    IF ($Item.LastDirSyncTime -eq $null) {$IsSynced = $False} ELSE {$IsSynced = $True}

    $Hash =  [ordered]@{
            'Display Name'                   = $Item.DisplayName
            'User Principal Name'            = $Item.UserPrincipalName
            'Assigned Licenses'              = $Licenses
            'License Reconciliation Needed'  = $Item.LicenseReconciliationNeeded
            'Indirect License Errors'        = $Item.IndirectLicenseErrors.Error
            'AD Synced'                      = $IsSynced
            'Last Dir Sync Time'             = $Item.LastDirSyncTime.DateTime
            'Time Zone'                      = "$($Item.LastDirSyncTime.Kind)".ToUpper()
            'Password Changed On'            = $Item.LastPasswordChangeTimestamp
            'Password Never Expires'         = $Item.PasswordNeverExpires
        
    }

    $LicObject = New-Object psobject -Property $Hash
    $LicensedUsersDetails += $LicObject
}

# $LicensedUsersDetails | Sort 'Display Name' | Out-GridView

$TenantLic = @()
foreach($Item in $AllLicenses){
    IF ($Item.AccountSkuId.Count -lt 9999){

        $Hash =  [ordered]@{
            'Account Sku Name'  = ($SkuList | Where-Object {$_.SkuID -contains $Item.SkuPartNumber}).Name
            'Active Units'      = $Item.ActiveUnits
            'Purchased Units'   = IF ($Item.ActiveUnits -lt 10000){$Item.ActiveUnits} ELSE {"Unlimited"}
            'Warning Units'     = $Item.WarningUnits
            'Consumed Units'    = $Item.ConsumedUnits
        }

        $NewObject = New-Object psobject -Property $Hash
        $TenantLic += $NewObject
    }
}

[int]$LicTenantTOT = ($TenantLic.'Active Units' | Measure-Object -Sum).Sum
[int]$LicPurchasedTOT = (($TenantLic | Where-Object {$_.'Purchased Units' -ne "Unlimited"}).'Active Units' | Measure-Object -Sum).Sum
[int]$LicConsumedTOT = ($TenantLic.'Consumed Units' | Measure-Object -Sum).Sum
[int]$LicWarningTOT = ($TenantLic.'Warning Units' | Measure-Object -Sum).Sum
[int]$UnlimitedTOT = $LicPurchasedTOT - $LicConsumedTOT
IF ($UnlimitedTOT -le 0) { [string]$LicUnlimitedTOT = "All purchased licenses are assigned" }
ELSE { [int]$LicUnlimitedTOT = $UnlimitedTOT }


##########################
### DISTRIBUTION LISTS ###
##########################

$DLs = Get-DistributionGroup -ResultSize $ResultSize
$Step++
Write-Progress -Id 0 -Activity $Task -Status "Step $Step of $TotalSteps" -CurrentOperation "Working on Distribution Lists" -PercentComplete ($Step / $TotalSteps * 100)
$Counter = 0

foreach ($O365DL in $DLs) {
    $Counter++
    Write-Progress -Id 1 -ParentId 0 -Activity "Working on" -Status "Processing $($Counter) of $(($DLs | Measure-Object -Sum -ErrorAction SilentlyContinue).Count)" -CurrentOperation $($O365DL.Name) -PercentComplete ($Counter / (($DLs | Measure-Object -Sum -ErrorAction SilentlyContinue).Count) * 100)
}

#########################                               
### OFFICE 365 GROUPS ###
#########################

$O365Groups = Get-UnifiedGroup -ResultSize $ResultSize
$Step++
Write-Progress -Id 0 -Activity $Task -Status "Step $Step of $TotalSteps" -CurrentOperation "Working on Office 365 Groups" -PercentComplete ($Step / $TotalSteps * 100)

$Counter = 0

foreach ($Item in $O365Groups) {
    $Counter++
    Write-Progress -Id 1 -ParentId 0 -Activity "Office 365 Groups" -Status "Processing $($Counter) of $($O365Groups.Count)" -CurrentOperation $($Item.DisplayName) -PercentComplete ($Counter / $O365Groups.Count * 100)
}


#####################
### MAIL CONTACTS ###
#####################

# $MailContacts2 = Get-AzureADContact -All $True | Select DisplayName, Mail, MailNickName, DirSyncEnabled, LastDirSyncTime, ProvisioningErrors, SipProxyAddress, ProxyAddresses

$MailContacts = Get-MailContact -ResultSize $ResultSize

$Step++
Write-Progress -Id 0 -Activity $Task -Status "Step $Step of $TotalSteps" -CurrentOperation "Working on Mail Contacts" -PercentComplete ($Step / $TotalSteps * 100)

$MC = @()
$Counter = 0
foreach ($Contact in $MailContacts) {
    $Counter++
    Write-Progress -Id 1 -ParentId 0 -Activity "Working on Mail Contacts" -Status "Processing $($Counter) of $($MailContacts.Count)" -CurrentOperation $($Contact.DisplayName) -PercentComplete ($Counter / $MailContacts.Count * 100)
    
    foreach ($X in $Contact) {
        $Hash =  [ordered]@{
            'Display Name'           = $X.DisplayName
            'External Email Address' = [string]($X.ExternalEmailAddress).Substring(5)
        }
        
        $MCObject = New-Object psobject -Property $Hash
        $MC += $MCObject
    }
}

<#

############################
###   SHARED CALENDARS   ###
############################

$SharedCalendars = Get-MailboxFolderPermission -Identity $(($UserMailboxes.Identity)+":\Calendar")
$Step++
Write-Progress -Id 0 -Activity $Task -Status "Step $Step of $TotalSteps" -CurrentOperation "Checking Shared Calendars" -PercentComplete ($Step / $TotalSteps * 100)

$Results = @()
$Counter = 0
foreach ($SC in $Mailboxes) {
    $Counter++
    #Write-Progress -Id 1 -ParentId 0 -Activity "Working on Shared Calendars" -Status "Processing $($Counter) of $($SharedCalendars.Count)" -CurrentOperation $($Contact.DisplayName) -PercentComplete ($Counter / $MailContacts.Count * 100)
    
    $Query = Get-MailboxFolderPermission -Identity $(($SC.'Display Name')+":\Calendar")
    # $Filter = $Query | Where-Object {$_.User -notlike "Default" -and $_.User -notlike "Anonymous"}
    
    foreach ($Item in $Query) {
    IF (-NOT([string]::IsNullOrWhiteSpace($Item.User.DisplayName))) {
        $User = $null
        $Access = $null
        $Flags = $null

        #foreach ($G in $Filter.User.DisplayName){ [string]$User += "$($G)`r`n" }

        $Item | ForEach-Object {[string]$User += "$($Item.User.DisplayName)`r"}
        $Item | ForEach-Object {[string]$Access += "$($Item.AccessRights)`r"}
        $Item | ForEach-Object {[string]$Flags += "$($Item.SharingPermissionFlags)`r"}

    $Hash =  [ordered]@{
         Identity                  = $SC.'Display Name'
        'Folder Name'              = "Calendar"
        'User With Access'         = $User   # "$($Filter.User.DisplayName)`n"
        'Access Rights'            = $Access # "$($Filter.AccessRights)`n"
        'Sharing Permission Flags' = $Flags  # "$($Filter.SharingPermissionFlags)`n"
    }
        
    $SCObject = New-Object psobject -Property $Hash
    $Results += $SCObject
    }
    }
}
$Results | Group-Object Identity | Out-GridView

$Query = $null
[array]$Query = @()
$Query.GetType()
$Results.GetType()
$Results = $null

$CAL.Identity.SubString(0,9)

$SharedCalendars
#>

############################
### EXTENDED PERMISSIONS ###
############################

$QueryEP = Get-RecipientPermission -ResultSize $ResultSize
$ExtendedPermissions = $QueryEP | Where-Object {$_.Trustee -ne "NT AUTHORITY\SELF" -and $_.Trustee -ne "NULL SID"}

$Step++
Write-Progress -Id 0 -Activity $Task -Status "Step $Step of $TotalSteps" -CurrentOperation "Working on Extended Permissions" -PercentComplete ($Step/$TotalSteps * 100)

$Counter = 0
$EPCount = ($ExtendedPermissions | Measure-Object -Sum -ErrorAction SilentlyContinue).Count
foreach ($EP in $ExtendedPermissions) {
    $Counter++
    Write-Progress -Id 1 -ParentId 0 -Activity "Extended Permissions" -Status "Working on" -CurrentOperation $($EP.Identity) -PercentComplete ($Counter/$EPCount * 100)
}


#############################
### OTHER RECIPIENT TYPES ###
#############################

$OtherIdentities = Get-Recipient -ResultSize $ResultSize | Sort-Object RecipientType | Where-Object {$_.RecipientType -ne "MailUniversalDistributionGroup" -and $_.RecipientType -ne "MailContact" -and $_.RecipientType -ne "UserMailbox"}
$Step++
Write-Progress -Id 0 -Activity $Task -Status "Step $Step of $TotalSteps" -CurrentOperation "Looking for other recipient types" -PercentComplete ($Step / $TotalSteps * 100)

$OI = @()
$OIAliases = @()
$Counter = 0
foreach ($Other in $OtherIdentities) {
    $Counter++
    Write-Progress -Id 1 -ParentId 0 -Activity "Looking for other recipient types" -Status "Working on" -CurrentOperation $($Other.'Display Name') -PercentComplete ($Counter / $OtherIdentities.Count * 100)
    $OIAliases = $null
    foreach($O in $Other){ $OIAliases += "$(($O.EmailAddresses).Substring(5)),`r`n" }

        $Hash =  [ordered]@{
            'Display Name'            = $Other.DisplayName
            'Recipient Type'          = $Other.RecipientType
            'Recipient Type Details'  = $Other.RecipientTypeDetails
            'Primary SMTP Address'    = $Other.PrimarySmtpAddress
            'Email Addresses'         = $OIAliases
        }

        $OIObject = New-Object psobject -Property $Hash
        $OI += $OIObject
}

Write-Progress -Id 1 -Activity $Task -Completed

#############################
### CREATING HTML REPORT  ###
#############################

$Step++
Write-Progress -Id 0 -Activity $Task -Status "Step $Step of $TotalSteps" -CurrentOperation "Creating HTML Report. Please stand by..." -PercentComplete ($Step / $TotalSteps * 100)

$rpt += Get-HtmlOpenPage -TitleText "Office 365 Tenant Report: $TenantDefaultDomain" -LeftLogoString "https://pittsburgh.aleragroup.com/wp-content/uploads/sites/183/2020/01/aleragroup.png"
# $ReportName = "Office 365 Identities"

##    TABS DEFINITIONS

$TABarray = @('Licensing','Mailboxes','Distribution Lists','Office 365 Groups','Mail Contacts','Extended Permissions','Other Identities')
$rpt += Get-HTMLTabHeader -TabNames $TABarray


## =======   OPENING TAB: LICENSING  ======= ##


$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(0) -Tabheading (" ")
    $rpt+= Get-HtmlContentOpen -HeaderText "Licenses Info"

        #    Overall Summary
        $rpt+= Get-HtmlContentOpen  -HeaderText "Summary"
            $rpt += Get-HtmlContenttext -Heading "Total Licenses in Tenant" -Detail $LicTenantTOT
            $rpt += Get-HtmlContenttext -Heading "Purchased Licenses" -Detail $LicPurchasedTOT
            $rpt += Get-HtmlContenttext -Heading "Consumed Licenses" -Detail $LicConsumedTOT
            $rpt += Get-HtmlContenttext -Heading "Warning Units" -Detail $LicWarningTOT
            $rpt += Get-HtmlContenttext -Heading "Unassigned Licenses" -Detail $LicUnlimitedTOT
        $rpt+= Get-HtmlContentClose

        #    Tenant Domains
        $rpt+= Get-HtmlContentOpen -HeaderText "Domains in Tenant"
            $rpt+= Get-HtmlContentTable ($TenantDomains | Select-Object Name, Status, IsDefault, IsInitial, Capabilities | Sort-Object Name) -Fixed
        $rpt+= Get-HtmlContentClose

        #    Licensed Users Summary
        $rpt+= Get-HtmlContentOpen -HeaderText "Licensed Users"
            $rpt+= Get-HTMLContentDataTable -ArrayOfObjects ($LicensedUsersDetails | Sort-Object 'Display Name') -PagingOptions '25,50,100,200,500,' -HideFooter
            #$rpt+= Get-HtmlContentTable ($LicensedUsersDetails | Sort-Object 'Display Name') -Fixed
        $rpt+= Get-HtmlContentClose

        #    Charts
        $PurchasedtLicChart = Get-HTMLPieChartObject
        $PurchasedtLicChart.Title = "Purchased Licenses"
        $PurchasedtLicChart.ChartStyle.ChartType = 'doughnut'
        $PurchasedtLicChart.ChartStyle.ColorSchemeName = "ColorScheme4"
        $PurchasedtLicChart.DataDefinition.DataNameColumnName = "Name"
        $PurchasedtLicChart.DataDefinition.DataValueColumnName = "Count"
        $PurchasedtLicChart.ChartStyle.Showlabels = "True"

        $ConsumedLicChart = Get-HTMLPieChartObject
        $ConsumedLicChart.Title = "Consumed Licenses"
        $ConsumedLicChart.ChartStyle.ChartType = 'doughnut'
        $ConsumedLicChart.ChartStyle.ColorSchemeName = "ColorScheme4"
        $ConsumedLicChart.ChartStyle.Showlabels = "True"

        $D1 = $($TenantLic | Where-Object {$_.'Purchased Units' -ne "Unlimited"} | Select-Object @{n="Name";e={$_.'Account Sku Name'}}, @{n="Count";e={$_.'Purchased Units'}})
        $D2 = $($TenantLic | Where-Object {$_.'Purchased Units' -ne "Unlimited"} | Select-Object @{n="Name";e={$_.'Account Sku Name'}}, @{n="Count";e={$_.'Consumed Units'}})

        #    Column1
        $rpt+= Get-HtmlContentOpen -HeaderText "Charts"
            $rpt+= Get-HTMLColumn1of2
                $rpt+= Get-HtmlContentOpen -HeaderText "Purchased Licenses"
                    $rpt += Get-HTMLPieChart -ChartObject $PurchasedtLicChart -DataSet $D1
                $rpt+= Get-HtmlContentClose
            $rpt+= Get-HTMLColumnClose

        #    Column2
            $rpt+= Get-HTMLColumn2of2
                $rpt+= Get-HtmlContentOpen -HeaderText "Consumed Licenses"
                    $rpt += Get-HTMLPieChart -ChartObject $ConsumedLicChart -DataSet $D2
                $rpt+= Get-HtmlContentClose
            $rpt+= Get-HTMLColumnClose

        $rpt+= Get-HtmlContentClose ## Close CHARTS Content
    $rpt+= Get-HtmlContentClose ## Close LICENSING Content

$rpt += Get-HTMLTabContentClose ## CLOSING TAB



## =======  OPENING TAB: MAILBOXES  ======= ##


$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(1) -Tabheading (" ")

    ## DETAILS SECTION
        
    $rpt += Get-HtmlContentOpen -HeaderText "Mailboxes"
        $rpt+= Get-HTMLContentDataTable -ArrayOfObjects ($Mailboxes | Sort-Object 'Recipient Type Details','Display Name') -PagingOptions '25,50,100,200,500,' -HideFooter
        #$rpt+= Get-HtmlContentTable $($Mailboxes | Sort 'Recipient Type Details','Display Name') #-GroupBy $('Recipient Type Details')
        # $SampleListColour = Set-TableRowColor $Mailboxes -Alternating
        # $rpt+= Get-HtmlContentTable -ArrayOfObjects $SampleListColour #-GroupBy ('Recipient Type Details')
    $rpt += Get-HTMLContentClose

    ## BAR CHART
    $PieObject = Get-HTMLBarChartObject
    $PieObject.ChartStyle.ColorSchemeName = "ColorScheme4"
    $rpt += Get-HTMLHeading -headerSize 3 -headingText "Top 5 Mailboxes by Size (Size in GB)"
    $rpt += Get-HTMLBarChart -ChartObject $PieObject -DataSet ($MBXSizeRPT | Sort-Object Count -Descending | Select-Object -First 5)

$rpt += Get-HTMLTabContentClose ## CLOSING TAB


## =======  OPENING TAB: DISTRIBUTION LISTS  ======= ##


$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(2) -Tabheading (" ")

foreach ($Item in $DLs) {

    ## DETAILS SECTION: DISTRIBUTION LIST DETAILS
    $rpt += Get-HtmlContentOpen -HeaderText "Distribution List Name: $Item" # -IsHidden
    $rpt+= Get-HTMLContentTable ($Item | Select-Object -Property @{n='AD Synced';e={$_.IsDirSynced}},
        @{n='Display Name';e={$_.DisplayName}},
        @{n='Primary SMTP Address';e={$_.PrimarySmtpAddress}},
        @{n='Aliases';e={$(($_.EmailAddresses -cmatch "smtp:")).SubString(5)}},
        @{n='Owner';e={$_.ManagedBy}})

    $Aliases = $null
    foreach ($X in $Item){ [string]$Aliases += "$(($X.EmailAddresses).SubString(5))`r`n" }

    $Members = Get-DistributionGroupMember -Identity $Item.Identity | Select-Object DisplayName, Alias, PrimarySMTPAddress, RecipientTypeDetails | Sort-Object DisplayName
            
    ## DETAILS SECTION: DISTRIBUTION LIST MEMBERS
    $rpt += Get-HtmlContentOpen -HeaderText "Members of: $Item"
        $rpt+= Get-HTMLContentDataTable -HideFooter -ArrayOfObjects $Members -PagingOptions '50,100,200,500,'
    $rpt += Get-HtmlContentClose
$rpt += Get-HtmlContentClose
}

$rpt += Get-HTMLTabContentClose ## CLOSING TAB


## =======  OPENING TAB: OFFICE 365 GROUPS  ======= ##


$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(3) -Tabheading (" ")

$Counter = 0
foreach ($Item in $O365Groups) {
$Counter++
$Members = Get-UnifiedGroupLinks –Identity $Item.Identity –LinkType Members | Select-Object Name, PrimarySMTPAddress, RecipientTypeDetails | Sort-Object Name

## GROUPS
$rpt += Get-HtmlContentOpen -HeaderText "Group Name: $($Item.DisplayName)" # -IsHidden
    $rpt+= Get-HTMLContentTable ($Item | Select-Object Owner, DisplayName, PrimarySMTPAddress, RecipientTypeDetails)
    ## MEMBERS
    $rpt += Get-HtmlContentOpen -HeaderText "Members of: $($Item.DisplayName)"
        $rpt+= Get-HTMLContentDataTable -HideFooter -ArrayOfObjects $Members -PagingOptions '50,100,200,500,'
    $rpt += Get-HtmlContentClose

$rpt += Get-HtmlContentClose
}

$rpt += Get-HTMLTabContentClose ## CLOSING TAB


## =======  OPENING TAB: MAIL CONTACTS  ======= ##


$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(4) -Tabheading (" ")
            
    ## SECTION DETAILS
    $SampleListColour = Set-TableRowColor $MC -Alternating
    $rpt += Get-HtmlContentTable $SampleListColour -Fixed
    # $rpt += Get-HtmlContentClose

$rpt += Get-HTMLTabContentClose ## CLOSING TAB


## =======  OPENING TAB: EXTENDED PERMISSIONS  ======= ##


$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(5) -Tabheading (" ")

$EP = $ExtendedPermissions | Sort-Object Trustee | Select-Object -Property @{n='Who';e={$_.Trustee}},
        @{n='Action';e={$_.AccessControlType}},
        @{n='Permission';e={$_.AccessRights}},
        @{n='Over (Mailbox)';e={$_.Identity}},
        @{n='Inherited';e={$_.IsInherited}}

        ## SECTION DETAILS
        # $rpt += Get-HtmlContentOpen -HeaderText "Extended Permissions" # -IsHidden
        $SampleListColour = Set-TableRowColor $EP -Alternating
        $rpt += Get-HtmlContentTable $SampleListColour -Fixed -GroupBy ("Who")
        # $rpt += Get-HtmlContentClose

$rpt += Get-HTMLTabContentClose ## CLOSING TAB


## =======  OPENING TAB: OTHER RECIPIENTS  ======= ##


$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(6) -Tabheading (" ")
                                
    ## SECTION DETAILS
    $rpt+= Get-HTMLContentDataTable -ArrayOfObjects ($OI | Sort-Object 'Recipient Type Details') -PagingOptions '25,50,100,200,500,' -HideFooter
    # $rpt += Get-HtmlContentOpen -HeaderText "Other Identities" # -IsHidde
    # $SampleListColour = Set-TableRowColor $OI -Alternating
    # $rpt += Get-HtmlContentTable $SampleListColour -Fixed -GroupBy ("Recipient Type Details")
    # $rpt += Get-HtmlContentClose

$rpt += Get-HTMLTabContentClose ## CLOSING TAB
$rpt += Get-HTMLClosePage # -FooterText "Fernando Yopolo // fyopolo@homail.com // Year $((Get-Date).Year)" ##    CLOSING HTML REPORT

Write-Progress -Id 0 -Activity $Task -Completed

Get-PSSession | Remove-PSSession
# Create-Report
# Stop-Transcript

$Mailboxes | Sort-Object ('Recipient Type Details','Display Name') | Export-Excel -Path C:\TEMP\Aaron.xlsx -AutoSize -AutoFilter -FreezeTopRow