$CSVInfo = Import-Csv -Path C:\TEMP\OneDrive-Map-SylviaInsurance.csv

$RegODConnections = [Microsoft.Win32.RegistryKey]::OpenBaseKey("CurrentUser","default")
$SPConnections = $RegODConnections.OpenSubKey("SOFTWARE\Microsoft\OneDrive\Accounts\Business1\Tenants\Alera Group").GetValueNames()

foreach ($Connection in $SPConnections){

    foreach ($Item in $CSVInfo){

        $LocalFolderPath = ($Item.ServerLocalPath).Substring(2)
        $UNCPath = "\\$env:COMPUTERNAME\"  + ($Connection).Replace(":","$") + $LocalFolderPath
        $Label = $LocalFolderPath | Split-Path -Leaf
        $SourceUsr = $UPN.Substring(0, $UPN.IndexOf("@"))
        $TargetUsr = $Item.UserPrincipalName.Substring(0, $Item.UserPrincipalName.IndexOf("@"))

        IF (-NOT($UNCPath -in $(Get-PSDrive -PSProvider FileSystem).DisplayRoot)){
            IF ($SourceUsr -eq $TargetUsr) {
                Write-Host "Creating Map drive and setting Label: $UNCPath" -ForegroundColor Cyan
                net use $($Item.DriveLetter) $UNCPath | Out-Null
                Start-Sleep -Milliseconds 500
                $MountPoint = Get-ChildItem HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2 | Where-Object {$_.Name -like "*$Label*"}
                [Microsoft.Win32.Registry]::SetValue($MountPoint.Name, "_LabelFromReg", $Label, [Microsoft.Win32.RegistryValueKind]::STRING)
            }
        } ELSE { Write-Warning "Mapdrive already found: $($Item.DriveLetter)" }
    }
}