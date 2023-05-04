    $credential = Get-Credential -Message "Please supply Global Admin credentials"
    Import-Module MsOnline
    Connect-MsolService -Credential $credential
    $exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
    Import-PSSession $exchangeSession -DisableNameChecking

    $TenantDefaultDomain = (Get-MsolDomain | Where-Object {$_.IsDefault -eq 'True'}).Name
    $Mailboxes = Get-Mailbox -RecipientTypeDetails GroupMailbox, RoomMailbox, SchedulingMailbox, SharedMailbox, TeamMailbox, UserMailbox
    
    $Results = @()

    foreach ($MBX in $Mailboxes){

        $MBXSize = Get-MailboxStatistics -Identity $($MBX.PrimarySmtpAddress) | Select-Object @{name="Size";expression={[math]::Round((($_.TotalItemSize.Value.ToString()).Split("(")[1].Split(" ")[0].Replace(",","")/1MB),2)}}

        $Hash = [ordered]@{

            Domain               =   $TenantDefaultDomain
            RecipientType        =   $MBX.RecipientTypeDetails
            DisplayName          =   $MBX.DisplayName
            PrimarySmtpAddress   =   $MBX.PrimarySmtpAddress
            MailboxSize          =   "$($MBXSize.Size) MB"

        }

        $Object = New-Object psobject -Property $Hash
        $Results += $Object # Populating custom PS Object with Hash Table elements
    }

Get-PSSession | Remove-PSSession

$Results | Sort-Object Domain, RecipientType, DisplayName | ft -AutoSize

# $Results | ConvertTo-Csv -NoTypeInformation -Delimiter "," | % {$_ -replace '"',''} | Export-Csv -Path "C:\TEMP\CP.csv"

# $Results | Export-Csv -Delimiter "," -Path "C:\TEMP\CP.csv" -NoTypeInformation -NoClobber -Encoding Unicode

$Results | ConvertTo-Csv -NoTypeInformation | % {$_.Replace('"','')} | Out-File "C:\TEMP\CP.txt" -Append

# $Results | ConvertTo-Csv -NoTypeInformation | % { $_ -replace '","', ','} | % { $_ -replace "^`"",''} | % { $_ -replace "`"$",''} | out-file 'C:\TEMP\CP.txt' -fo -en utf8
