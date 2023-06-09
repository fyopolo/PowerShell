<#    .SYNOPSIS    Script to set Outlook 2010/2013 e-mail signature using Active Directory information    .DESCRIPTION    This script will set the Outlook 2010/2013 e-mail signature on the local client using Active Directory information.     The template is created with a Word document, where images can be inserted and AD values can be provided.    Author: Daniel Classon    Version 2.0    .DISCLAIMER    All scripts and other powershell references are offered AS IS with no warranty.    These script and functions are tested in my environment and it is recommended that you test these scripts in a test environment before using in your production environment.    #>

Set-Variable OfficeDetails -Option AllScope
Set-Variable OfficeVersion -Option AllScope
Set-Variable DetailsMSG -Option AllScope
Set-Variable SigType -Option AllScope

Function Gather-LocalInfo (){

    $RegistryPath = "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration"

    Write-Host ""
    Write-Host "Attempting to find a local installation of Microsoft Office..." -ForegroundColor Yellow    
    $WORD = @()
    $WORD += Get-ChildItem -Path ${env:ProgramFiles(x86)} -Recurse -Filter "WINWORD.EXE" -ErrorAction Ignore
    $WORD += Get-ChildItem -Path $env:ProgramFiles -Recurse -Filter "WINWORD.EXE" -ErrorAction Ignore

    IF ($WORD){
       Write-Host "Local installation detected. Getting details..."
       Write-Host ""
       SWITCH -Wildcard ($WORD.DirectoryName){
            "*(x86)*" { $OfficeArch = "32 Bits" }
            Default { $OfficeArch = "64 Bits" }
            }

    SWITCH -Wildcard ($WORD.VersionInfo.ProductVersion){

        "12.0.*" { $OfficeVersion = "2007"}
        "14.0.*" { $OfficeVersion = "2010"}
        "15.0.*" { $OfficeVersion = "2013"}
        "16.0.*" {
            IF (Test-Path $RegistryPath) {
                $Property = (Get-ItemProperty -Path $RegistryPath).ProductReleaseIds
                SWITCH -Wildcard ($Property) {
                    "*O365BusinessRetail*" { $OfficeVersion = "Office365 Business Premium" }
                    "*O365ProPlusRetail*" { $OfficeVersion = "Office365 ProPlus" }
                    "*2016*" { $OfficeVersion = "2016" }
                    "*2019*" { $OfficeVersion = "2019"}
                    }
                }
            
    $DetailsMSG = ("======================================

    Version      : $OfficeVersion
    Architecture : $OfficeArch

======================================
")

            } # End of "16.0.*" SWITCH

}
    $Hash =  [ordered]@{
        Version       = $OfficeVersion
        Architecture  = $OfficeArch
    }

    $Table = New-Object psobject -Property $Hash
    $OfficeDetails += $Table

    }

    Return $DetailsMSG
}

Function Get-SignatureType (){

    $Filter = "(&(objectCategory=User)(samAccountName=$UserName))"
    $Searcher = New-Object System.DirectoryServices.DirectorySearcher
    $ADUserPath = $Searcher.FindOne()
    $ADUser = $ADUserPath.GetDirectoryEntry()
    $SigType = $ADUser.extensionAttribute1

}

Function Install-Fonts(){
    
    $fonts = Get-ChildItem -Path "\\pma-law.local\NETLOGON\SignatureFiles\Raleway-Font\static"
    foreach ($font in $fonts){
        If (!(Test-Path "c:\windows\fonts\$($font.name)")) {
            switch (($font.name -split "\.")[-1]) {
                "TTF" {
                    $fn = "$(($font.name -split "\.")[0]) (TrueType)"
                    break
                }
                "OTF" {
                    $fn = "$(($font.name -split "\.")[0]) (OpenType)"
                    break
                }
            }
            Copy-Item -Path $($font.DirectoryName + "\" + $font.Name) -Destination "C:\Windows\Fonts\" -Force
            New-ItemProperty -Name $fn -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $font.Name
            } ELSE { Write-Host "Font $font already exist" -ForegroundColor Cyan
        }
    }
}


#Custom variables
$SignatureName = 'Pluymert'
$SigRootPath = ((Get-Item env:APPDATA).value) + "\Microsoft\Signatures\"
$SigBasePath = $SigRootPath + $SignatureName + "_files\"
$NetworkFilesPath = "\\pma-law.local\NETLOGON\SignatureFiles\BaseStructure\"
$SourcePath = $NetworkFilesPath + "Pluymert_Files"
$TemplateNetPath = $NetworkFilesPath + "Template.htm"
$TemplateLocalPath = $SigRootPath + "Template.htm"
# $ForceSignature = '0' #Set to 1 if you don't want the users to be able to change signature in Outlook

Install-Fonts

IF (-NOT(Test-Path $SigRootPath)){
    New-Item -Path $SigRootPath -ItemType Directory
}

IF (Test-Path $TemplateLocalPath){
    Write-Host "Template file already exist" -ForegroundColor Green
    Exit
} ELSE {
 
 Gather-LocalInfo

# IF (-NOT($SigRootPath)){ New-Item -Path $SigRootPath -ItemType Directory -Force | Out-Null }
# IF (-NOT($SigBasePath)){ New-Item -Path $SigBasePath -ItemType Directory -Force | Out-Null }

#Get Active Directory information for current user
$UserName = $env:USERNAME
$Filter = "(&(objectCategory=User)(samAccountName=$UserName))"
$Searcher = New-Object System.DirectoryServices.DirectorySearcher
$Searcher.Filter = $Filter
$ADUserPath = $Searcher.FindOne()
$ADUser = $ADUserPath.GetDirectoryEntry()
$ADDisplayName = $ADUser.DisplayName
$ADTitle = $ADUser.title
$ADEmailAddress = $ADUser.mail
$ADPhoneNumber = $ADUser.homePhone
# $OfficeAddress = $ADUser.streetAddress
$OfficeAddLine1 = $ADUser.extensionAttribute1
$OfficeAddLine2 = $ADUser.extensionAttribute2
$OfficeAddLine3 = $ADUser.extensionAttribute3
$DirectPhone = $ADUser.homePhone


#Copy signature templates from source to local Signature-folder
Write-Host "Copying Signature files..." -ForegroundColor Cyan

Copy-Item $SourcePath $SigRootPath -Recurse -Force

Copy-Item $($NetworkFilesPath + "\Template.htm") $SigRootPath
Copy-Item $($NetworkFilesPath + "\Template.txt") $SigRootPath

(Get-Content $($SigRootPath + "\Template.txt")) | ForEach-Object {$_.Replace("PROP-USERNAME",$ADDisplayName).Replace("PROP-TITLE",$ADTitle).Replace("PROP-EMAILADDRESS",$ADEmailAddress).Replace("PROP-PHONE",$ADPhoneNumber).Replace("PROP-STREET-LINE1",$OfficeAddLine1).Replace("PROP-STREET-LINE2",$OfficeAddLine2).Replace("PROP-STREET-LINE3",$OfficeAddLine3) } | Set-Content -Path $($SigRootPath + "Pluymert.txt")
(Get-Content $($SigRootPath + "\Template.htm")) | ForEach-Object {$_.Replace("PROP-USERNAME",$ADDisplayName).Replace("PROP-TITLE",$ADTitle).Replace("PROP-EMAILADDRESS",$ADEmailAddress).Replace("PROP-PHONE",$ADPhoneNumber).Replace("PROP-STREET-LINE1",$OfficeAddLine1).Replace("PROP-STREET-LINE2",$OfficeAddLine2).Replace("PROP-STREET-LINE3",$OfficeAddLine3) } | Set-Content -Path $($SigRootPath + "Pluymert.htm")

<# Setting registry properties for applying default signature values

SWITCH ($OfficeVersion){
        "2007" { $OfficeVersion = "2007"}
        "2010" {
            New-ItemProperty HKCU:'\Software\Microsoft\Office\14.0\Common\MailSettings' -Name 'ReplySignature' -Value $SignatureName -PropertyType 'String' -Force
            New-ItemProperty HKCU:'\Software\Microsoft\Office\14.0\Common\MailSettings' -Name 'NewSignature' -Value $SignatureName -PropertyType 'String' -Force
            }
        "2013" {
            New-ItemProperty HKCU:'\Software\Microsoft\Office\15.0\Common\MailSettings' -Name 'NewSignature' -Value $SignatureName -PropertyType 'String' -Force
            New-ItemProperty HKCU:'\Software\Microsoft\Office\15.0\Common\MailSettings' -Name 'ReplySignature' -Value $SignatureName -PropertyType 'String' -Force
            }
        default {
            New-ItemProperty HKCU:'\Software\Microsoft\Office\16.0\Common\MailSettings' -Name 'NewSignature' -Value $SignatureName -PropertyType 'String' -Force
            New-ItemProperty HKCU:'\Software\Microsoft\Office\16.0\Common\MailSettings' -Name 'ReplySignature' -Value $SignatureName -PropertyType 'String' -Force
            } # This includes Office 2016, 2019 and Office 365
}

#>

<#

IF (Test-Path HKCU:Software\Microsoft\Office\15.0) {
    Write-Output "Setting signature for Office 2013"

    IF ($ForceSignature -eq '0') {
        Write-Output "Setting Office 2013 as available"
        $MSWord = New-Object -ComObject word.application
        $EmailOptions = $MSWord.EmailOptions
        $EmailSignature = $EmailOptions.EmailSignature
        $EmailSignatureEntries = $EmailSignature.EmailSignatureEntries

    }

    IF ($ForceSignature -eq '1') {
        Write-Output "Setting signature for Office 2013 as forced"
        
        IF (-NOT(Get-ItemProperty -Name 'NewSignature' -Path HKCU:'\Software\Microsoft\Office\15.0\Common\MailSettings')) {
            New-ItemProperty HKCU:'\Software\Microsoft\Office\15.0\Common\MailSettings' -Name 'NewSignature' -Value $SignatureName -PropertyType 'String' -Force }
        IF (-NOT(Get-ItemProperty -Name 'ReplySignature' -Path HKCU:'\Software\Microsoft\Office\15.0\Common\MailSettings')) {
            New-ItemProperty HKCU:'\Software\Microsoft\Office\15.0\Common\MailSettings' -Name 'ReplySignature' -Value $SignatureName -PropertyType 'String' -Force }
    }
}

#>

}