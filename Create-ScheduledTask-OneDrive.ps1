$Action = New-ScheduledTaskAction -Execute "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" -Argument "C:\TEMP\OneDrive-Maps-Sylvia.ps1 -ExecutionPolicy Bypass" -WorkingDirectory "C:\TEMP"
$Trigger = New-ScheduledTaskTrigger -AtLogOn

Register-ScheduledTask -TaskName "OneDrive Maps - Sylvia" -Action $Action -Trigger $Trigger -TaskPath "AleraMDM" -User $env:USERNAME