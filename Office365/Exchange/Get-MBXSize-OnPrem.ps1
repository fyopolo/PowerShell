Add-PSSnapin *Exchange*
$MBX = Get-Mailbox -ResultSize Unlimited
$MBXTable = @()

foreach ($Mailbox in $MBX) {

    IF (-NOT([string]::IsNullOrWhiteSpace($Mailbox.ArchiveName))) { $ArchiveName = $Mailbox.ArchiveName } ELSE { $ArchiveName = "" }        

        $Hash =  [ordered]@{
            Name                   = $Mailbox.Name
            UPN                    = $Mailbox.UserPrincipalName
            PrimarySMTPAddress     = $Mailbox.PrimarySmtpAddress
            MailboxSizeGB          = (($Mailbox | Get-MailboxStatistics).TotalItemSize.Value.ToGB())
            MailboxSizeMB          = (($Mailbox | Get-MailboxStatistics).TotalItemSize.Value.ToMB())
            MailboxSizeKB          = (($Mailbox | Get-MailboxStatistics).TotalItemSize.Value.ToKB())
            RecipientTypeDetails   = $Mailbox.RecipientTypeDetails
            MailboxQuota           = $Mailbox.ProhibitSendQuota
            Server                 = ($Mailbox.ServerName).ToUpper()
            MBXDatabase            = $Mailbox.Database.Name
            ArchiveName            = [string]$ArchiveName
            ArchiveDB              = $Mailbox.ArchiveDatabase
                    }

        $MBXObject = New-Object psobject -Property $Hash
        $MBXTable += $MBXObject
}

$MBXTable | sort MailboxSizeGB -Descending | Out-GridView
$MBXTable | Export-Excel -Path C:\TEMP\MBX-Size_v3.xlsx -AutoSize -AutoFilter -ShowPercent