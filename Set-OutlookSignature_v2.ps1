<#    .SYNOPSIS    Script to set Outlook 2010/2013 e-mail signature using Active Directory information    .DESCRIPTION    This script will set the Outlook 2010/2013 e-mail signature on the local client using Active Directory information.     The template is created with a Word document, where images can be inserted and AD values can be provided.    Author: Daniel Classon    Version 2.0    .DISCLAIMER    All scripts and other powershell references are offered AS IS with no warranty.    These script and functions are tested in my environment and it is recommended that you test these scripts in a test environment before using in your production environment.    #>


#Custom variables
$SignatureName = 'Test2' #insert the company name (no spaces) - could be signature name if more than one sig needed
$SigSource = "c:\scripts\Test2.docx" #Path to the *.docx file, i.e "c:\temp\template.docx"
$SignatureVersion = "7" #Change this if you have updated the signature. If you do not change it, the script will quit after checking for the version already on the machine
$ForceSignature = '0' #Set to 1 if you don't want the users to be able to change signature in Outlook
 
#Environment variables
$BasePath = ((Get-Item env:appdata).value)+"\Microsoft\"

<#

En la versión 3 suprimí renglones del SWITCH para que sea más compacto
Lo que suprimí fue el write-host y por tanto quedó todo en 1 sóla línea

#>

switch ( $BasePath  | Get-ChildItem )
    {
        "Firmas" { 
                    Write-Host "Microsof Office Version detected" -ForegroundColor Green
                    $SigPath = $BasePath + "Firmas\"
                    break
                  }
        "Signatures" {
                        Write-Host "Office 365 Version detected" -ForegroundColor Green
                        $SigPath = $BasePath + "Signatures\"
                        break
                     }
    }

Write-Host "Path Found: $SigPath"

#Copy version file
New-Item -Path $SigPath\$SignatureVersion -ItemType Directory

#Get Active Directory information for current user
$UserName = $env:username
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
Write-Output "Copying Signatures"
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
$fullPath = $SigPath + $SignatureName + '.docx'
$MSWord.Documents.Open($fullPath)
	
#User Name $ Designation 
$FindText = "DisplayName" 
$Designation = $ADCustomAttribute1.ToString() #designations in Exchange custom attribute 1
If ($Designation -ne '') { 
	$Name = $ADDisplayName.ToString()
	$ReplaceText = $Name+', '+$Designation
}
Else {
	$ReplaceText = $ADDisplayName.ToString() 
}
$MSWord.Selection.Find.Execute($FindText, $MatchCase, $MatchWholeWord,	$MatchWildcards, $MatchSoundsLike, $MatchAllWordForms, $Forward, $Wrap,	$Format, $ReplaceText, $ReplaceAll	)	

#Title		
$FindText = "Title"
$ReplaceText = $ADTitle.ToString()
$MSWord.Selection.Find.Execute($FindText, $MatchCase, $MatchWholeWord,	$MatchWildcards, $MatchSoundsLike, $MatchAllWordForms, $Forward, $Wrap,	$Format, $ReplaceText, $ReplaceAll	)
	
#Description
   If ($ADDescription -ne '') { 
   	$FindText = "Description"
   	$ReplaceText = $ADDescription.ToString()
}
Else {
	$FindText = " | Description "
   	$ReplaceText = "".ToString()
}
$MSWord.Selection.Find.Execute($FindText, $MatchCase, $MatchWholeWord,	$MatchWildcards, $MatchSoundsLike, $MatchAllWordForms, $Forward, $Wrap,	$Format, $ReplaceText, $ReplaceAll	)
#$LogInfo += $NL+'Description: '+$ReplaceText
   	
#Street Address
If ($ADStreetAddress -ne '') { 
       $FindText = "StreetAddress"
    $ReplaceText = $ADStreetAddress.ToString()
   }
   Else {
    $FindText = "StreetAddress"
    $ReplaceText = $DefaultAddress
    }
	$MSWord.Selection.Find.Execute($FindText, $MatchCase, $MatchWholeWord,	$MatchWildcards, $MatchSoundsLike, $MatchAllWordForms, $Forward, $Wrap,	$Format, $ReplaceText, $ReplaceAll	)

#City
If ($ADCity -ne '') { 
    $FindText = "City"
       $ReplaceText = $ADCity.ToString()
   }
   Else {
    $FindText = "City"
    $ReplaceText = $DefaultCity 
   }
$MSWord.Selection.Find.Execute($FindText, $MatchCase, $MatchWholeWord,	$MatchWildcards, $MatchSoundsLike, $MatchAllWordForms, $Forward, $Wrap,	$Format, $ReplaceText, $ReplaceAll	)
	
#Telephone
If ($ADTelephoneNumber -ne "") { 
	$FindText = "TelephoneNumber"
	$ReplaceText = $ADTelephoneNumber.ToString()
   }
Else {
	$FindText = "TelephoneNumber"
    $ReplaceText = $DefaultTelephone
	}
$MSWord.Selection.Find.Execute($FindText, $MatchCase, $MatchWholeWord,	$MatchWildcards, $MatchSoundsLike, $MatchAllWordForms, $Forward, $Wrap,	$Format, $ReplaceText, $ReplaceAll	)
	
#Mobile
If ($ADMobile -ne "") { 
	$FindText = "MobileNumber"
	$ReplaceText = $ADMobile.ToString()
   }
Else {
	$FindText = "| Mob MobileNumber "
    $ReplaceText = "".ToString()
	}
$MSWord.Selection.Find.Execute($FindText, $MatchCase, $MatchWholeWord,	$MatchWildcards, $MatchSoundsLike, $MatchAllWordForms, $Forward, $Wrap,	$Format, $ReplaceText, $ReplaceAll	)

#Save new message signature 
Write-Output "Saving signatures"
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
    }
else
{
Write-Output "Setting Office 2010 signature as available"

$MSWord = New-Object -comobject word.application
$EmailOptions = $MSWord.EmailOptions
$EmailSignature = $EmailOptions.EmailSignature
$EmailSignatureEntries = $EmailSignature.EmailSignatureEntries

}
}



#Office 2013 signature

If (Test-Path HKCU:Software\Microsoft\Office\15.0)

{
Write-Output "Setting signature for Office 2013"

If ($ForceSignature -eq '0')

{
Write-Output "Setting Office 2013 as available"

$MSWord = New-Object -ComObject word.application
$EmailOptions = $MSWord.EmailOptions
$EmailSignature = $EmailOptions.EmailSignature
$EmailSignatureEntries = $EmailSignature.EmailSignatureEntries

}

If ($ForceSignature -eq '1')
{
Write-Output "Setting signature for Office 2013 as forced"
    If (Get-ItemProperty -Name 'NewSignature' -Path HKCU:'\Software\Microsoft\Office\15.0\Common\MailSettings') { } 
    Else { 
    New-ItemProperty HKCU:'\Software\Microsoft\Office\15.0\Common\MailSettings' -Name 'NewSignature' -Value $SignatureName -PropertyType 'String' -Force 
    } 
    If (Get-ItemProperty -Name 'ReplySignature' -Path HKCU:'\Software\Microsoft\Office\15.0\Common\MailSettings') { } 
    Else { 
    New-ItemProperty HKCU:'\Software\Microsoft\Office\15.0\Common\MailSettings' -Name 'ReplySignature' -Value $SignatureName -PropertyType 'String' -Force
    } 
}

}