<#

$credential = Get-Credential
Import-Module MsOnline
Connect-MsolService -Credential $credential
Connect-AzureAD -Credential $credential
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
Import-PSSession $exchangeSession -DisableNameChecking

#>


$A = Import-Excel -Path C:\Fer\Scripts\PowerShell\Freeport\GroupInfo.xlsx
$A | ft -AutoSize -Wrap | select -First 10

Connect-AzureAD -Credential $credential

foreach ($Item in $A){
    Write-Host $Item.ObjectId
    Get-AzureADUserExtension -ObjectId $($Item.ObjectId) | Where-Object {$_.Keys -icontains "*extensionAttribute9"}
}

Import-Module ActiveDirectory

$Users = Get-Content -Path C:\Temp\StreamGRP.txt

$Test = @()

foreach ($User in $Users){

    $Item = Get-ADUser -Filter ("UserPrincipalName -eq '$User'") -Properties *
        
        $Hash =  [ordered]@{
        UserName       = $Item.DisplayName
        extensionAttribute9 = $Item.extensionAttribute9        
        }

    $NewObject = New-Object psobject -Property $Hash
    $Test += $NewObject

}

$Test | Export-Csv -Path C:\Temp\Stream.csv -NoTypeInformation



#>

$Users = Import-Excel -Path C:\Fer\Scripts\PowerShell\Freeport\GroupInfo.xlsx 

foreach ($A in $Users){
    $I = Get-ADUser -Filter ("UserPrincipalName -eq '$A.PrimarySmtpAddress'") -Properties *
    Set-ADUser -Identity $I.SamAccountName -Add @{extensionAttribute9 = "STREAMGRP-MEMBER-YES"} -Verbose
}
#>