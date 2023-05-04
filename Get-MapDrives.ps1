# Get-PSDrive | Where-Object {$_.DisplayRoot -like "\\*"} | Select Name, @{Name="UNCPath"; Expression = {$_.DisplayRoot}} # | Export-Csv -Path C:\TEMP\MapDrives_$env:COMPUTERNAME.csv -NoTypeInformation

$MapDrives = Get-PSDrive | Where-Object {$_.DisplayRoot -like "\\*"}# | Select Name, @{Name="UNCPath"; Expression = {$_.DisplayRoot}} # | Export-Csv -Path C:\TEMP\MapDrives_$env:COMPUTERNAME.csv -NoTypeInformation
$Info = @()

foreach ($item in $MapDrives){

    $Hash =  [ordered]@{
        UserName     = $env:USERNAME
        ComputerName = $env:COMPUTERNAME
        DriveLetter  = $item.Name
        UNCPath      = $item.DisplayRoot
    }
        
    $NewObject = New-Object psobject -Property $Hash
    $Info += $NewObject

}

$Info | Export-Csv -Path C:\TEMP\MapDrives_$env:COMPUTERNAME.csv -NoTypeInformation