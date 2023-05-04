# -------------------------------------------------------------------------------
# Script: ActiveUserAccounts.ps1
# Author: Fernando Yopolo
# Date: 04/13/2018
# Keywords: Active Directory, User Account, Active Users
# Comments: Gather AD active user account details and output it to HTML.
#
# Versioning
# 04/13/2018  Initial Script
# 04/17/2018  Added HTML reporting capabilities by using ReportHTML module.
#             This requires PowerShell v4+ and having installed the following:
#             Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
#             Install-Module -Name ReportHTML -Force
# -------------------------------------------------------------------------------

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

### IMPORTING MODULES
Import-Module ActiveDirectory
Import-Module ReportHTML

### VARIABLES DEFINITION
$DomainFQDN = (Get-ADDomain).DNSRoot
$ActiveUsers = Get-ADUser -Filter {Enabled -eq $True}
$rpt = @()

$rpt += Get-HtmlOpenPage -TitleText "Active Directory Active User Accounts for domain: $DomainFQDN" -LeftLogoString "https://d2oc0ihd6a5bt.cloudfront.net/wp-content/uploads/sites/1064/2015/06/logo.png"
$ReportName = "Active Directory: Active User Accounts"

Write-Host "Statistics for domain: $($DomainFQDN.ToUpper())" -ForegroundColor Green
$ActiveUsers | Select Name, SamAccountName, UserPrincipalName | Sort-Object Name
$TotalUsers = $ActiveUsers.Count

### FILLING REPORT
$rpt += Get-HtmlContentOpen -HeaderText "Total Accounts: $TotalUsers"
$SampleListColour = Set-TableRowColor $ActiveUsers -Alternating


$rpt+= Get-HtmlContentTable -ArrayOfObjects ($SampleListColour |
Select -Property @{n='Display Name';e={$_.Name}},
                @{n='SAM Account Name';e={$_.SamAccountName}},
                @{n='User Principal Name';e={$_.UserPrincipalName}} |
                Sort-Object ("Display Name")) -Fixed

$rpt += Get-HTMLContentClose

###  CLOSING HTML REPORT
$rpt += Get-HtmlClosePage
  

Function Create-Report
{
    $rptFile = $OutputFolder + "\" + "AD-ActiveUser-" + "$DomainFQDN" + ".htm"
    $rpt | Set-Content -Path $rptFile -Force
    Invoke-Item $rptFile
    sleep 1
}

Create-Report