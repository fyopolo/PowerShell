$ErrorActionPreference = 'SilentlyContinue'

$RP = $null

IF (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending) {$RP += "Key1"}
IF (Get-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootInProgress) {$RP += "Key2"}
IF (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired) {$RP += "Key3"}
IF (Get-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\PackagesPending) {$RP += "Key4"}
IF (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\PostRebootReporting) {$RP += "Key5"}
IF (Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager -Name 'PendingFileRenameOperations') {$RP += "Key6"}
IF (Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager -Name 'PendingFileRenameOperations2') {$RP += "Key7"}
IF (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Updates -Name 'UpdateExeVolatile') {$RP += "Key8"}
IF (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce -Name 'DVDRebootSignal') {$RP += "Key9"}
IF (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\ServerManager\CurrentRebootAttemps) {$RP += "Key10"}
IF (Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon -Name 'JoinDomain') {$RP += "Key11"}
IF (Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon -Name 'AvoidSpnSet') {$RP += "Key12"}
IF (Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName -Name ComputerName) {$RP += "Key13"}
IF (Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName -Name ComputerName) {$RP += "Key14"}
IF (Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Services\Pending) {$RP += "Key15"}


Write-Host $RP -ForegroundColor Yellow