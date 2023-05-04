# Connect-VIServer vcenter -Force

$VMList = Get-VM | Select VMHost, Name, GuestId | Sort VMHost

$VMList | Group-Object VMHost