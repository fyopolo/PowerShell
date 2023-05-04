$DOC = Get-ChildItem -Path D: -Recurse *.xlsx | % {$_.FullName}

write-host "File Count:" $DOC.Count -ForegroundColor Cyan

foreach ($File in $DOC){

    $File.FullName
    
}

##### A cleaner approach #####
Get-ChildItem -Path D: -Recurse *.xlsx | ForEach-Object {Write-Host "File:" $_.FullName $_.Length}

Get-ChildItem -Path D: -Recurse *.xlsx | Select Directory, Name, Length | Sort-Object Length -Descending | ft -AutoSize -Wrap
