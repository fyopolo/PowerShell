#region: Prevent Teams from auto-start
# If Teams auto-start entry exists, delete it
$entry = $null -eq (Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Run)."com.squirrel.Teams.Teams"
if ( !$entry ) {
Remove-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Run -Name "com.squirrel.Teams.Teams"
}
# Define Teams configuratin file path
$Teams_config_file = "$env:APPDATA\Microsoft\Teams\desktop-config.json"
$configs = Get-Content $Teams_config_file -Raw
# If Teams already doesn't auto-start, break out the script.
if ( $configs -match "openAtLogin`":false") {
break
}
# If Teams already ran, and set to auto-start, change it to disable auto-start
elseif ( $configs -match "openAtLogin`":true" ) {
$configs = $configs -replace "`"openAtLogin`":true","`"openAtLogin`":false"
}
# If it's a fresh file, add configuration to the end
else {
$disable_auto_start = ",`"appPreferenceSettings`":{`"openAtLogin`":false}}"
$configs = $configs -replace "}$",$disable_auto_start
}
# Overwritten the configuration with new values.
$configs | Set-Content $Teams_config_file
#endregion