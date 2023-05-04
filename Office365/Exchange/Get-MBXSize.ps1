Add-PSsnapin *Exchange*

$Mailbox = Get-Mailbox | Where-Object { $_.RecipientTypeDetails -eq "UserMailbox"}

$Table = @()

foreach ($MBX in $Mailbox){

    $MBXInfo = $MBX | Get-MailboxStatistics

    IF ($MBX.ArchiveDatabase.Name -eq $Null){ $ArchiveEnabled = $false }
    ELSE {
        $ArchiveEnabled = $true
        $ArchiveInfo = $MBX | Get-MailboxStatistics -Archive
        $ArchiveSize = ($ArchiveInfo.TotalItemSize).Value
        $ArchiveDBName = $ArchiveInfo.DisplayName
    }

        $Hash = [ordered]@{
            Identity           = $MBX.DisplayName
            PrimarySMTPAddress = $MBX.PrimarySmtpAddress
            ArchiveEnabled     = $ArchiveEnabled
            ArchiveDataBase    = IF ($ArchiveEnabled -eq $true) {$ArchiveDBName} ELSE {"NoInfo"}
            ArchiveSize        = IF ($ArchiveEnabled -eq $true) {$ArchiveSize} ELSE {"NoInfo"}
            MailboxSize        = $MBXInfo.TotalItemSize
        }

        $NewObj = New-Object psobject -Property $Hash
        $Table += $NewObj
    
}

$Table | Out-GridView
$Table | Export-Csv -Path C:\Temp\archiveRPT.csv -NoTypeInformation