# -------------------------------------------------------------------------------
# Script: Create_HomeFolders.ps1
# Author: Fernando Yopolo
# Date: 01/21/2020
# Keywords: NTFS, Access
# Comments: Gather user SamAccountName and create home folders.
#           Inheritance will be disabled for user folder. However, all child items (if exist) will have it enabled.
#           Script must run as Administrator.
#           PowerShell module "NTFSSecurity" must be installed.
#           You can get NTFSSecurity module from https://gallery.technet.microsoft.com/scriptcenter/1abd77a5-9c0b-4a2b-acef-90dbb2b84e85
#
# Versioning
# 01/21/2020  Initial Script
# -------------------------------------------------------------------------------

Import-Module NTFSSecurity

$RootFolder = "D:\Scripts"
$DefaultSecID = @("CREATOR OWNER", "NT AUTHORITY\SYSTEM", "BUILTIN\Administrators")

foreach ($SubFolder in Get-ChildItem -Path $RootFolder -Directory -Recurse){
    Write-Host "Permissions for $($SubFolder.FullName)" -ForegroundColor Cyan
    Get-NTFSAccess -Path $SubFolder.FullName | Where-Object { $_.Account -notcontains $DefaultSecID } | Select Account, AccessRights, IsInherited, InheritedFrom
    Write-Host ""
}