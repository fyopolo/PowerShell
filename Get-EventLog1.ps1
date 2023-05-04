$SID = 'S-1-5-21-3169774748-1730408886-2329524604-1016'

# Get-WinEvent -Path C:\TEMP\Security.evtx

# $Date = (Get-Date).AddDays(-2)
$filter = @{
  Path = 'C:\TEMP\Security.evtx'
  ProviderName = 'Microsoft-Windows-Security-Auditing'
  ID = 4624
  TargetUserSid = 'S-1-5-21-3169774748-1730408886-2329524604-1016'
  #<named-data> = 'LogonType'
}
Get-WinEvent -FilterHashtable $filter | Out-GridView


Get-EventLog -LogName Security -InstanceId 4624 -Message | Select -First 1 -ExpandProperty Message


Get-EventLog –log Security | Where {$_.message –match "Security ID:\s*S-1-5-21-3169774748-1730408886-2329524604-1016”}

Get-EventLog -EntryType Information 


Get-EventLog -LogName Security -Message "S-1-5-21-3169774748-1730408886-2329524604-1016"