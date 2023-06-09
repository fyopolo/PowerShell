<#    .SYNOPSIS    Script to set Outlook 2010/2013 e-mail signature using Active Directory information    .DESCRIPTION    This script will set the Outlook 2010/2013 e-mail signature on the local client using Active Directory information.     The template is created with a Word document, where images can be inserted and AD values can be provided.    Author: Daniel Classon    Version 2.0    .DISCLAIMER    All scripts and other powershell references are offered AS IS with no warranty.    These script and functions are tested in my environment and it is recommended that you test these scripts in a test environment before using in your production environment.    #>

Set-Variable OfficeDetails -Option AllScope
Set-Variable OfficeVersion -Option AllScope
Set-Variable DetailsMSG -Option AllScope

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

Gather-LocalInfo


#Custom variables
$SignatureName = 'Corp Signature' #insert the company name (no spaces) - could be signature name if more than one sig needed
$SigSource = "D:\Scripts\PowerShell\Set-Outlook-Signature-Template.docx" #Path to the *.docx file, i.e "c:\temp\template.docx"
$SignatureVersion = "1" #Change this if you have updated the signature. If you do not change it, the script will quit after checking for the version already on the machine
$ForceSignature = '0' #Set to 1 if you don't want the users to be able to change signature in Outlook
 
#Environment variables
$SigPath = ((Get-Item env:APPDATA).value) + "\Microsoft\Signatures\"
$VersionPath = $SigPath + $SignatureVersion

IF (-NOT($SigPath)){ New-Item -Path $SigPath -ItemType Directory -Force | Out-Null }
IF (-NOT($VersionPath)){ New-Item -Path $VersionPath -ItemType Directory -Force | Out-Null }

#Get Active Directory information for current user
$UserName = $env:USERNAME
$Filter = "(&(objectCategory=User)(samAccountName=$UserName))"
$Searcher = New-Object System.DirectoryServices.DirectorySearcher
$Searcher.Filter = $Filter
$ADUserPath = $Searcher.FindOne()
$ADUser = $ADUserPath.GetDirectoryEntry()
$ADDisplayName = $ADUser.DisplayName
$ADEmailAddress = $ADUser.mail
$ADTitle = $ADUser.title
$ADDescription = $ADUser.description
$ADTelePhoneNumber = $ADUser.TelephoneNumber
$ADMobile = $ADUser.mobile
$ADStreetAddress = $ADUser.streetaddress
$ADCity = $ADUser.l
$ADCustomAttribute1 = $ADUser.extensionAttribute1
$ADModify = $ADUser.whenChanged

#Copy signature templates from source to local Signature-folder
Write-Output "Copying Signatures..."
Copy-Item "$Sigsource" $SigPath -Recurse -Force
$ReplaceAll = 2
$FindContinue = 1
$MatchCase = $False
$MatchWholeWord = $True
$MatchWildcards = $False
$MatchSoundsLike = $False
$MatchAllWordForms = $False
$Forward = $True
$Wrap = $FindContinue
$Format = $False

#Insert variables from Active Directory to rtf signature-file
$MSWord = New-Object -ComObject word.application
$fullPath = $LocalSignaturePath+'\'+$SignatureName+'.docx'
$MSWord.Documents.Open($fullPath)
	
#User Name $ Designation 
$FindText = "DisplayName" 
$Designation = $ADCustomAttribute1.ToString() #designations in Exchange custom attribute 1

IF ($Designation -ne '') { 
	$Name = $ADDisplayName.ToString()
	$ReplaceText = $Name+', '+$Designation
} ELSE {
	$ReplaceText = $ADDisplayName.ToString() 
}

$MSWord.Selection.Find.Execute($FindText, $MatchCase, $MatchWholeWord, $MatchWildcards, $MatchSoundsLike, $MatchAllWordForms, $Forward, $Wrap,	$Format, $ReplaceText, $ReplaceAll	)	

#Title		
$FindText = "Title"
$ReplaceText = $ADTitle.ToString()
$MSWord.Selection.Find.Execute($FindText, $MatchCase, $MatchWholeWord,	$MatchWildcards, $MatchSoundsLike, $MatchAllWordForms, $Forward, $Wrap,	$Format, $ReplaceText, $ReplaceAll	)
	
#Description
IF ($ADDescription -ne '') { 
   	$FindText = "Description"
   	$ReplaceText = $ADDescription.ToString()
} ELSE {
	$FindText = " | Description "
   	$ReplaceText = "".ToString()
}

$MSWord.Selection.Find.Execute($FindText, $MatchCase, $MatchWholeWord,	$MatchWildcards, $MatchSoundsLike, $MatchAllWordForms, $Forward, $Wrap,	$Format, $ReplaceText, $ReplaceAll	)

#$LogInfo += $NL+'Description: '+$ReplaceText
   	
#Street Address
IF ($ADStreetAddress -ne '') { 
       $FindText = "StreetAddress"
    $ReplaceText = $ADStreetAddress.ToString()
} ELSE {
    $FindText = "StreetAddress"
    $ReplaceText = $DefaultAddress
}

$MSWord.Selection.Find.Execute($FindText, $MatchCase, $MatchWholeWord,	$MatchWildcards, $MatchSoundsLike, $MatchAllWordForms, $Forward, $Wrap,	$Format, $ReplaceText, $ReplaceAll	)

#City
IF ($ADCity -ne '') { 
    $FindText = "City"
       $ReplaceText = $ADCity.ToString()
} ELSE {
    $FindText = "City"
    $ReplaceText = $DefaultCity 
}

$MSWord.Selection.Find.Execute($FindText, $MatchCase, $MatchWholeWord,	$MatchWildcards, $MatchSoundsLike, $MatchAllWordForms, $Forward, $Wrap,	$Format, $ReplaceText, $ReplaceAll	)
	
#Telephone
IF ($ADTelephoneNumber -ne "") { 
	$FindText = "TelephoneNumber"
	$ReplaceText = $ADTelephoneNumber.ToString()
} ELSE {
	$FindText = "TelephoneNumber"
    $ReplaceText = $DefaultTelephone
}

$MSWord.Selection.Find.Execute($FindText, $MatchCase, $MatchWholeWord,	$MatchWildcards, $MatchSoundsLike, $MatchAllWordForms, $Forward, $Wrap,	$Format, $ReplaceText, $ReplaceAll	)
	
#Mobile
IF ($ADMobile -ne "") { 
	$FindText = "MobileNumber"
	$ReplaceText = $ADMobile.ToString()
} ELSE {
	$FindText = "| Mob MobileNumber "
    $ReplaceText = "".ToString()
}

$MSWord.Selection.Find.Execute($FindText, $MatchCase, $MatchWholeWord,	$MatchWildcards, $MatchSoundsLike, $MatchAllWordForms, $Forward, $Wrap,	$Format, $ReplaceText, $ReplaceAll	)

#Save new message signature 
Write-Output "Saving signatures..."
#Save HTML
$saveFormat = [Enum]::Parse([Microsoft.Office.Interop.Word.WdSaveFormat], "wdFormatHTML");
$path = $SigPath + $SignatureName + ".htm"
$MSWord.ActiveDocument.saveas([ref]$path, [ref]$saveFormat)
    
#Save RTF 
$saveFormat = [Enum]::Parse([Microsoft.Office.Interop.Word.WdSaveFormat], "wdFormatRTF");
$path = $SigPath + $SignatureName + ".rtf"
$MSWord.ActiveDocument.SaveAs([ref] $path, [ref]$saveFormat)
	
#Save TXT    
$saveFormat = [Enum]::Parse([Microsoft.Office.Interop.Word.WdSaveFormat], "wdFormatText");
$path = $SigPath + $SignatureName + ".txt"
$MSWord.ActiveDocument.SaveAs([ref] $path, [ref]$SaveFormat)
$MSWord.ActiveDocument.Close()
$MSWord.Quit()
	

#Office 2010
If (Test-Path HKCU:'\Software\Microsoft\Office\14.0')
{
If ($ForceSignature -eq '1')
    {
    Write-Output "Setting signature for Office 2010 as forced"
    New-ItemProperty HKCU:'\Software\Microsoft\Office\14.0\Common\MailSettings' -Name 'ReplySignature' -Value $SignatureName -PropertyType 'String' -Force
    New-ItemProperty HKCU:'\Software\Microsoft\Office\14.0\Common\MailSettings' -Name 'NewSignature' -Value $SignatureName -PropertyType 'String' -Force
} ELSE {
    Write-Output "Setting Office 2010 signature as available"
    $MSWord = New-Object -comobject word.application
    $EmailOptions = $MSWord.EmailOptions
    $EmailSignature = $EmailOptions.EmailSignature
    $EmailSignatureEntries = $EmailSignature.EmailSignatureEntries

    }
}

#Office 2013 signature

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