Function Load-File($initialDirectory) {  
    [System.Reflection.Assembly]::LoadWithPartialName(“System.windows.forms”) | Out-Null

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.Title = "Select file"
    $OpenFileDialog.Filter = “Text Files (*.txt)| *.txt”
    $Button = $OpenFileDialog.ShowDialog()
    $OpenFileDialog.FileName | Out-Null
    IF ($Button -eq "OK") { Return $OpenFileDialog.FileName }
    ELSE { Write-Error "Operation cancelled by user. Aborting script execution."; Break }
}

Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -ShowProgress $true

$TargetMBX = Get-Content -Path $(Load-File)
$Trustee = Get-Content -Path $(Load-File)
$LogFile = "$env:USERPROFILE\Documents\SendAsPermissions.txt"

Start-Transcript -Path $LogFile

foreach ($Target in $TargetMBX){

    foreach ($Trust in $Trustee){

        IF (-NOT(Get-EXORecipientPermission -Identity $Target -AccessRights SendAs -Trustee $Trust)){
        
            Write-Host "SendAs permissions not found for $Trust in $Target. Applying permissions..." -ForegroundColor Cyan
            Add-RecipientPermission -Identity $Target -AccessRights SendAs -Trustee $Trust -Confirm:$false -Verbose -WarningAction SilentlyContinue
        } ELSE { Write-Host "Permissions already set for $Target" }

    }

}

Stop-Transcript
Start $LogFile