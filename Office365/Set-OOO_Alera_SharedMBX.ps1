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

Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -ShowProgress $true

# Below is only valid for Exchange Online
Get-Mailbox -Identity Alerapayroll-HRIS@aleragroup.com | Set-MailboxAutoReplyConfiguration -AutoReplyState Enabled -InternalMessage $MSG -ExternalMessage $MSG -Verbose