Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -ShowProgress $true

$UserMailboxes = Get-Mailbox -ResultSize Unlimited | Where-Object {$_.RecipientTypeDetails -eq "UserMailbox" -or $_.RecipientTypeDetails -eq "SharedMailbox"}
# $Step++
# Write-Progress -Id 0 -Activity $Task -Status "Step $Step of $TotalSteps" -CurrentOperation "Working on Mailboxes" -PercentComplete ($Step / $TotalSteps * 100)

$Mailboxes = @()
$MailboxA = @()
$MBXSizeRPT = @()
$Counter = 0

foreach ($MBX in $UserMailboxes) {
    $Counter++
    Write-Progress -Id 0 -Activity $MBX.RecipientTypeDetails -Status "Processing $($Counter) of $($UserMailboxes.Count)" -CurrentOperation $MBX.DisplayName -PercentComplete (($Counter/$UserMailboxes.Count) * 100)

    $Size = Get-MailboxStatistics -Identity $($MBX.PrimarySmtpAddress) | Select-Object @{name="Size";expression={[math]::Round((($_.TotalItemSize.Value.ToString()).Split("(")[1].Split(" ")[0].Replace(",","")/1GB),2)}}, @{name="Name";expression={$_.DisplayName}}, @{name="Count";expression={[math]::Round((($_.TotalItemSize.Value.ToString()).Split("(")[1].Split(" ")[0].Replace(",","")/1GB),2)}}
    $MBXSizeRPT += $Size | Select-Object Name, Count
    $Percent = (($Size.Size * 100 / ($($MBXQuota = $MBX.ProhibitSendReceiveQuota.Split(" ");[string]$MBXQuota[0..($MBXQuota.count-4)]))))/100

    IF (-NOT([string]::IsNullOrWhiteSpace($MBX.ForwardingSmtpAddress))) { $Case = 1 } ELSE { $Case = 3 }
    IF (-NOT([string]::IsNullOrWhiteSpace($MBX.ForwardingAddress))) { $Case = 2 } ELSE { $Case = 3 }
    IF ([string]::IsNullOrWhiteSpace($MBX.ForwardingAddress) -and ([string]::IsNullOrWhiteSpace($MBX.ForwardingSmtpAddress))) { $Case = 3 }

    SWITCH ($Case){
        1 { $Forward = ($MBX.ForwardingSmtpAddress).TrimStart("smtp:");Break }
        2 { $Forward = $MBX.ForwardingAddress + " [Mail Contact]";Break }
        3 { $Forward = $null;Break }
    }

    $MailboxA = $null
    [array]$MBXAlias = $($MBX.EmailAddresses | Where-Object {$_ -cmatch "smtp:"})
    IF (-NOT([string]::IsNullOrWhiteSpace($MBXAlias))) {
        foreach($MAS in $MBXAlias) {
            $MailboxA += "$($MAS.TrimStart("smtp:"))`r`n"
        }
    } ELSE { $MailboxA = $null }

    $Hash =  [ordered]@{
        'Display Name'             =    $MBX.DisplayName
        'Recipient Type Details'   =    $MBX.RecipientTypeDetails
        'Mailbox Enabled'          =    $MBX.IsMailboxEnabled
        'Mailbox Created On'       =    $MBX.WhenMailboxCreated
        'Primary SMTP Address'     =    $MBX.PrimarySMTPAddress
         Aliases                   =    $MailboxA
        'Mailbox Size'             =    "$($Size.Size) GB"
        'Mailbox Quota'            =    $($MBXQuota = $MBX.ProhibitSendReceiveQuota.Split("(");[string]$MBXQuota[0..($MBXQuota.count-2)])
        'Percent Used'             =    "{0:P0}" -f $Percent
        'Forwarding Address'       =    $Forward
        'Archive Status'           =    $MBX.ArchiveStatus
        'Archive Name'             =    $MBX.ArchiveName
        'Retention Policy Name'    =    $MBX.RetentionPolicy
    }
    
    $MBXObject = New-Object psobject -Property $Hash
    $Mailboxes += $MBXObject
    
}

# $Mailboxes | Out-GridView
$Mailboxes | Export-Excel -Path C:\TEMP\Alera-RPT.xlsx