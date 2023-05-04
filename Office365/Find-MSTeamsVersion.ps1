$Teams = @()
$Teams += Get-ChildItem -Path C:\Users\ -Recurse -Filter "Teams.exe" -Force -ErrorAction SilentlyContinue
$Teams.DirectoryName
$Teams.VersionInfo.FileVersion