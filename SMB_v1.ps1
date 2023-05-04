[System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().domains.DomainControllers.Name | Out-File "C:\temp\DCs.txt" 
$Servers = Get-Content c:\temp\DCs.txt
$strResults01 = "SMB1"
$strResultsYES = " FOUND Enabled in "
$strResultsNO = " is NOT Enabled in "
foreach ($server in $Servers)
   {
   $Protocol = Get-WindowsOptionalFeature –Online –FeatureName SMB1Protocol
   
    if ($Protocol.State -eq "Enabled")
        {
            Write-Output "$($strResults01)$($strResultsYES)$($server)" | Out-File C:\temp\SMB1Stats.txt -Append
            Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol

            # Set-SmbServerConfiguration -EnableSMB1Protocol $false  | Out-File C:\temp\SMB1Stats.txt -Append
        }
        Else
        {
            Write-Output "$($strResults01)$($strResultsNO)$($server)" | Out-File C:\temp\SMB1Stats.txt -Append
        }
   } 
