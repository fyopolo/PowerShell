# -------------------------------------------------------------------------------
# Script: Create_ScanFolders.ps1
# Author: Fernando Yopolo
# Date: 09/15/2017
# Keywords: NTFS, Access
# Comments: Gather user ID and create home folders used in DRMC for scans.
# Comments: Script must run as Administrator.
# Comments: PowerShell module "NTFSSecurity" must be installed.
# Comments: You can get NTFSSecurity module from https://gallery.technet.microsoft.com/scriptcenter/1abd77a5-9c0b-4a2b-acef-90dbb2b84e85
#
# Versioning
# 09/15/2017  Initial Script
# 09/18/2017  Added reporting capabilities: Export to CSV with filtered values
# -------------------------------------------------------------------------------

Import-Module NTFSSecurity, ActiveDirectory

$RootFolder="D:\Scans"

foreach ($Account in Get-ADGroupMember -Identity "GSG_Level_3") {

    # Write-Host $Account.SamAccountName | Uncomment this if you need to see/troubleshoot variable values
    New-Item $($RootFolder + "\" + $($Account.SamAccountName)) -ItemType Directory -Force
    $Subfolder = ($Account.SamAccountName)
    $NTDOM = "CIO\" + $Subfolder
    # Get-NTFSAccess -Path D:\Scans\$Subfolder | Remove-NTFSAccess
    Add-NTFSAccess -Path $($RootFolder + "\" + $Subfolder) -Account $NTDOM -AccessRights FullControl
    
}

# Get a list of subfolder's security with explicit NTFS permissions and export results to CSV
Get-ChildItem -Path D:\Scans | Get-NTFSAccess | Where-Object IsInherited -EQ $False  | Select Account, AccessRights, FullName | Export-Csv D:\Scripts\ScanFodlers.csv -Encoding UTF8 -NoTypeInformation