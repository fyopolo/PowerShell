$Targets = Get-Content -Path C:\scripts\Patch-Server-List.txt

$Rpt = Invoke-Command ($Targets) {

    Get-HotFix
    
}

$Rpt | Select PSComputerName,HotFixID,InstalledOn,Description,InstalledBy,Caption | Export-Csv -Path C:\scripts\WU-Rpt.csv -NoTypeInformation