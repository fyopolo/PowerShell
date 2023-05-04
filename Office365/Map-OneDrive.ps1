
Function Get-NextAvailableDriveLetter(){

    $Taken = Get-WmiObject Win32_LogicalDisk | Select-Object -expand DeviceID
    $Letter = 70..90 | ForEach-Object{ [char]$_ + ":" }
    (Compare-Object -ReferenceObject $Taken -DifferenceObject $Letter)[1].InputObject
    Return

}


$RegODConnections = [Microsoft.Win32.RegistryKey]::OpenBaseKey("CurrentUser","default")
$SPConnections = $RegODConnections.OpenSubKey("SOFTWARE\Microsoft\OneDrive\Accounts\Business1\Tenants\Alera Group").GetValueNames()

foreach ($Connection in $SPConnections){

    $UNCPath = "\\$env:COMPUTERNAME\" + ($Connection).Replace(":","$")
    $Label = Split-Path -Path $UNCPath -Leaf

   IF (-NOT($UNCPath -in $(Get-PSDrive -PSProvider FileSystem).DisplayRoot)){

        Write-Host "Creating Map drive and setting Label: $UNCPath" -ForegroundColor Cyan
        net use $(Get-NextAvailableDriveLetter) $UNCPath | Out-Null
        Start-Sleep 500
        $MountPoint = Get-ChildItem HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2 | Where-Object {$_.Name -like "*$Label*"}
        [Microsoft.Win32.Registry]::SetValue($MountPoint.Name, "_LabelFromReg", $Label, [Microsoft.Win32.RegistryValueKind]::STRING)

    } ELSE { Write-Warning "Mapdrive already found: $UNCPath" }
}