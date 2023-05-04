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


Import-Module NTFSSecurity, ActiveDirectory

$RootFolder="E:\HomeDir"
$Accounts = Get-ADUser -Filter * -SearchBase "OU=UserAccunts,OU=JOURNEYS,DC=journeys,DC=local" -Properties *
$DefaultSecID = @("CREATOR OWNER", "NT AUTHORITY\SYSTEM", "BUILTIN\Administrators")

foreach ($Account in $Accounts){

    $HomeFolderPath = $($RootFolder + "\" + $($Account.SamAccountName))
    New-Item $HomeFolderPath -ItemType Directory -Force
    $SubFolders = Get-ChildItem -Path $HomeFolderPath -Recurse | Out-Null

    $HomeFolderPath | Disable-NTFSAccessInheritance
    Get-NTFSAccess -Path $HomeFolderPath | Remove-NTFSAccess -Account BUILTIN\Users -ErrorAction SilentlyContinue
    Add-NTFSAccess -Path $HomeFolderPath -Account $($Account.SamAccountName) -AccessRights FullControl # -InheritanceFlags ObjectInherit -PropagationFlags InheritOnly
 
     IF (-not(([string]::IsNullOrWhitespace($SubFolders)))){
        $SubFolders | Clear-NTFSAccess
        $SubFolders | Enable-NTFSAccessInheritance -RemoveExplicitAccessRules
    }
 
}

Get-ChildItem -Path $RootFolder | Get-NTFSAccess | Where-Object { $DefaultSecID -notcontains $_.Account }  | Select Account, AccessRights, FullName | ft -AutoSize