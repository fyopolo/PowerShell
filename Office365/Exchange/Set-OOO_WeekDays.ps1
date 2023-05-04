Function Load-File($initialDirectory) {  
    [System.Reflection.Assembly]::LoadWithPartialName(“System.windows.forms”) | Out-Null

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.Title = "Select File"
    $OpenFileDialog.Filter = “Text Files (*.txt)| *.txt”
    $Button = $OpenFileDialog.ShowDialog()
    $OpenFileDialog.FileName | Out-Null
    IF ($Button -eq "OK") { Return $OpenFileDialog.FileName }
    ELSE { Write-Error "Operation cancelled by user. Aborting script execution."; Break }
}

$MSG = Get-Content -Path (Load-File)

$credential = Get-Credential
Import-Module MsOnline
Connect-MsolService -Credential $credential
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -ShowProgress $true -Credential $credential

$Date = Get-Date
$Today = $Date.GetDateTimeFormats().GetValue(0)
$Tomorrow = $((Get-Date).AddDays(1))
$Tomorrow = $Tomorrow.Date.GetDateTimeFormats().GetValue(0)

SWITCH ($Date.DayOfWeek){

    "Monday"    { Write-Host "Today is $($Date.DayOfWeek)" -ForegroundColor Green ; Get-Mailbox | Set-MailboxAutoReplyConfiguration -AutoReplyState Scheduled -StartTime $($Today + " 11:00:00 PM") -EndTime $($Tomorrow + " 03:00:00 PM") -InternalMessage $MSG -ExternalMessage $MSG -Verbose }
    "Tuesday"   { Write-Host "Today is $($Date.DayOfWeek)" -ForegroundColor Green ; Get-Mailbox | Set-MailboxAutoReplyConfiguration -AutoReplyState Scheduled -StartTime $($Today + " 11:00:00 PM") -EndTime $($Tomorrow + " 03:00:00 PM") -InternalMessage $MSG -ExternalMessage $MSG -Verbose }
    "Wednesday" { Write-Host "Today is $($Date.DayOfWeek)" -ForegroundColor Green ; Get-Mailbox | Set-MailboxAutoReplyConfiguration -AutoReplyState Scheduled -StartTime $($Today + " 11:00:00 PM") -EndTime $($Tomorrow + " 03:00:00 PM") -InternalMessage $MSG -ExternalMessage $MSG -Verbose }
    "Thursday"  { Write-Host "Today is $($Date.DayOfWeek)" -ForegroundColor Green ; Get-Mailbox | Set-MailboxAutoReplyConfiguration -AutoReplyState Scheduled -StartTime $($Today + " 11:00:00 PM") -EndTime $($Tomorrow + " 03:00:00 PM") -InternalMessage $MSG -ExternalMessage $MSG -Verbose }
    "Friday"    { Write-Host "Today is $($Date.DayOfWeek)" -ForegroundColor Green ; Get-Mailbox | Set-MailboxAutoReplyConfiguration -AutoReplyState Scheduled -StartTime $($Today + " 11:00:00 PM") -EndTime $($Date.AddDays(3) -join " 03:00:00 PM") -InternalMessage $MSG -ExternalMessage $MSG -Verbose }
    default     { Write-Host "IT'S WEEKEND" -BackgroundColor Cyan }
}

# Get-PSSession | Remove-PSSession

<# IMPORTANT NOTES REGARDING TIME ZONES!!
  I don't know what time zone O365 tenant is using but I had
  to add 6 hours to both StartTime and EndTime variables
  I was using
  ---- StartTime: 5 PM CST (my computer time zone)
  ----  EndtTime: 9 AM CST (my computer time zone)
#>

# THIS IS FOR "ULTIMATE RENTAL" CUSTOMER