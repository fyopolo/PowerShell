<#
    Requirements:
        - There must be an OU named DisabledAccounts.
        - 
#>

$Date = (Get-Date).ToString('dd-MM-yyyy')
$TranscriptFileName = "C:\TEMP\" + "DisabledUserAccounts" + "_" + $Date + ".txt"

$SearchOU = "OU=ActiveUsers,OU=TFSNetwork,DC=totaloffice,DC=local"
$TargetOU = "OU=DisabledAccounts,OU=TFSNetwork,DC=totaloffice,DC=local"

Start-Transcript -LiteralPath $TranscriptFileName | Out-Null

$DisabledUsers = Get-ADUser -SearchBase $SearchOU -Filter { Enabled -eq $False }
$UserDN = $DisabledUsers.DistinguishedName

IF ($DisabledUsers.Count -ge 1){

    Write-Host "Disabled User Accounts found in ActiveUsers OU"  -ForegroundColor Cyan
    $DisabledUsers | Select Name, Enabled | ft -AutoSize

    foreach ($Item in $UserDN){
        IF ($Item -notcontains "*DisabledAccounts*"){
            Move-ADObject -Identity "$($Item)" -TargetPath "$($TargetOU)"
        }
    }

    Write-Host "Listed User Accounts have been moved to $($TargetOU)" -ForegroundColor Cyan

} ELSE {
    Write-Host ""
    Write-Host "No disabled user account found in $($SearchOU)"
    Write-Host "Nothing to move" -ForegroundColor Green
}

Write-Host ""
Stop-Transcript