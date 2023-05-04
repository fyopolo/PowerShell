$15YearsOldFiles = Get-ChildItem -Path H: -Recurse | Where-Object {$_.LastWriteTime -lt (Get-Date).AddYears(-15)}
$10YearsOldFiles = Get-ChildItem -Path H: -Recurse | Where-Object {$_.LastWriteTime -lt (Get-Date).AddYears(-10)}

$Files10 =@()
$Size10 = 0

foreach ($item in $10YearsOldFiles){

    $Hash =  [ordered]@{
        Name             = $item.Name
        Length           = $item.Length
        Path             = $item.DirectoryName
        LastWriteTime    = $item.LastWriteTime
        LastAccessTime   = $item.LastAccessTime
    }

    $Size10 = $Size10 + $item.Length
    $NewObject = New-Object psobject -Property $Hash
    $Files10 += $NewObject

}


$Files15 =@()
$Size15 = 0

foreach ($item in $15YearsOldFiles){

    $Hash =  [ordered]@{
        Name             = $item.Name
        Length           = $item.Length
        Path             = $item.DirectoryName
        LastWriteTime    = $item.LastWriteTime
        LastAccessTime   = $item.LastAccessTime
    }

    $Size15 = $Size15 + $item.Length
    $NewObject = New-Object psobject -Property $Hash
    $Files15 += $NewObject

}

#>

[math]::round($Size10/1GB, 2)
[math]::round($Size15/1GB, 2)
($10YearsOldFiles).Count
($15YearsOldFiles).Count
