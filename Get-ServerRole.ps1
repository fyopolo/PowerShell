Start-Transcript -LiteralPath C:\Temp\Transcript.txt

$Servers = Get-ADComputer -Filter { OperatingSystem -Like "Windows Server*" -and Enabled -eq "True" } -Properties * | Select Name, OperatingSystem, WhenCreated | sort Name
Write-Host "The following objects were found in ActiveDirectory" -ForegroundColor Cyan
$Servers | ft -AutoSize

Write-Host ""
Write-Host "Trying to gather installed server roles..." -ForegroundColor Yellow
Write-Host ""

foreach ($Computer in $Servers){

    IF (Test-Connection -ComputerName $($Computer.Name) -Quiet) {
        Write-Host "Hostname" $($Computer.Name) -ForegroundColor Cyan
        Invoke-Command -ComputerName $($Computer.Name) {Get-WindowsFeature | Where-Object {$_.InstallState -eq 'Installed' -and $_.FeatureType -eq 'Role'} | Select DisplayName, InstallState, PSComputerName | ft -AutoSize }
        Write-Host ""
        Write-Host "Getting installed software..." -ForegroundColor Cyan
        Invoke-Command -ComputerName $($Computer.Name) {Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table –AutoSize }
        Write-Host ""
    } ELSE {
        Write-Warning "Host $($Computer.Name) is not responding to ICMP"
        Write-Host ""
        }
}

Stop-Transcript