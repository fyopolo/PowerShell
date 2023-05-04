# This script will create a Chrome.bak folder
# and all the content in Chrome folder will be copied within.
# It will look into every local user profile.

$RootFolder = "C:\Users\"
$LocalUsers = Get-ChildItem -Path $RootFolder -ErrorAction SilentlyContinue

foreach ($Folder in $LocalUsers){

    $FolderFullName = $Folder.FullName
    $TestPath = $FolderFullName + "\AppData\Local\Google\Chrome"
    IF (Test-Path $TestPath){

        Write-Host "Found for user:" $Folder
        Copy-Item -Path $($FolderFullName + "\AppData\Local\Google\Chrome") -Destination $($FolderFullName + "\AppData\Local\Google\Chrome.bak")

    }

}
