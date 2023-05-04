<#
$RootFolder = "C:\Users\"
$LocalUsers = Get-ChildItem -Path $RootFolder # -ErrorAction SilentlyContinue

foreach ($Folder in $LocalUsers){

    $FolderFullName = $Folder.FullName
    IF (Test-Path $($FolderFullName + "\AppData\Local\Google\Chrome")){

        Write-Host "Found for user:" $Folder
        Copy-Item -Path $($FolderFullName + "\AppData\Local\Google\Chrome") -Destination $($FolderFullName + "\AppData\Local\Google\Chrome.bak")

    }

}
#>


$RootFolder = "C:\Users\"
$LocalUsers = Get-ChildItem -Path $RootFolder # -ErrorAction SilentlyContinue

foreach ($Folder in $LocalUsers){

    $FolderFullName = $Folder.FullName
    IF (Test-Path $($FolderFullName + "\AppData\Local\Google\Chrome")){

        Write-Host "Found for user:" $Folder
        Copy-Item -Path $($FolderFullName + "\AppData\Local\Google\Chrome") -Destination $($FolderFullName + "\AppData\Local\Google\Chrome.bak") -ErrorAction SilentlyContinue

    }

}

$InstallerPath =  "c:\temp\chrome.exe"

if (!(test-path "c:\temp")) { mkdir "c:\temp" }
Invoke-WebRequest "https://ninite.com/chrome/ninite.exe" -outfile $InstallerPath 

Start-Process -FilePath $InstallerPath -Wait

foreach ($Folder in $LocalUsers){

    $FolderFullName = $Folder.FullName
    IF (Test-Path $($FolderFullName + "\AppData\Local\Google\Chrome.bak")){

        Write-Host "Found for user:" $Folder
        Remove-Item -Path $($FolderFullName + "\AppData\Local\Google\Chrome") -Recurse -Force
        Copy-Item -Path $($FolderFullName + "\AppData\Local\Google\Chrome.bak\Chrome") -Destination $($FolderFullName + "\AppData\Local\Google\")

    }

}


$App = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -like "*Chrome*"}