$A = get-wmiobject -class win32_quickfixengineering

IF ($A.HotFixID -eq "KB4565349" -or $A.HotFixID -eq "KB4571694" -or $A.HotFixID -eq "KB4571703" -or $A.HotFixID -eq "KB4571736" -or $A.HotFixID -eq "KB4571729") {
    Write-Host "Server is protected from CVE-2020-1472 exploit" -ForegroundColor Green}
ELSE {Write-Host "Server is protected from CVE-2020-1472 exploit" -ForegroundColor Red}