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

<# Below is only valid for Exchange Online.
#>

Get-Mailbox | Set-MailboxAutoReplyConfiguration -AutoReplyState Scheduled -StartTime "9/7/2020 00:00:00" -EndTime "9/8/2020 00:00:00" -InternalMessage $MSG -ExternalMessage $MSG -Verbose