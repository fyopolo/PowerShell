#Disable SMB1 on DCs
[System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().domains.DomainControllers.Name | Out-File "C:\Scripts\DCs.txt" 
Invoke-Command -ComputerName (Get-Content C:\Scripts\DCs.txt -ReadCount 0) -ScriptBlock -UseSSL {Set-SmbServerConfiguration -EnableSMB1Protocol $false -Confirm:$false -Verbose}