$ProductKey = (Get-WmiObject -Class SoftwareLicensingService).OA3xOriginalProductKey | Out-Host
iex "cscript /b C:\Windows\System32\slmgr.vbs -ipk $Productkey" | Out-Host
Start-Sleep 5
iex "cscript /b C:\Windows\System32\slmgr.vbs -ato" | Out-Host