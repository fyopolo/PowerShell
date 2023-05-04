<#
$credential = Get-Credential
Connect-MsolService -Credential $credential
Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking

# Import-Module ReportHTML

#>

# Import-Module SharePointPnPPowerShellOnline

$InitialDomain = Get-MsolDomain | Where-Object {$_.IsInitial -eq $true}
$SharePointAdminURL = "https://$($InitialDomain.Name.Split(".")[0])-admin.sharepoint.com"

Connect-SPOService -Url $SharePointAdminURL -credential $credential

$OneDriveSites = Get-SPOSite -IncludePersonalSite $true -Limit all -Filter "Url -like '-my.sharepoint.com/personal/"
$ODFiles = @()

foreach ($MySite in $OneDriveSites) {

    Write-Host "Granting Admin rights over" $MySite.Url "for Global Admin" -ForegroundColor Green
    # Set-SPOUser -Site $MySite.Url -LoginName $credential.UserName -IsSiteCollectionAdmin $true | Out-Null
    Connect-PnPOnline -Url $MySite.Url -Credentials $credential | Out-Null

    Write-Host "Getting files for OneDrive user" $($MySite.Owner) -ForegroundColor Cyan
    $OneDriveFiles = Get-PnPListItem -List Documents -PageSize 1000

    IF ($OneDriveFiles.Count -gt 0) {
        foreach ($File in $OneDriveFiles) {
            $UserFiles = ($File.FieldValues.FileRef)
            $ModDate = ($File.FieldValues.Modified)
            $FileSize = [math]::Round(($File.FieldValues.SMTotalFileStreamSize / 1KB),2)
            Write-Host "File Name:" $UserFiles

            $Hash = [ordered]@{
                User         =   $MySite.Owner
                MySiteTitle  =   $MySite.Title
                MySiteURL    =   $MySite.Url
                FileName     =   $UserFiles
                ItemType     =   $File.FileSystemObjectType
                FileSize     =   -join($FileSize," (KB)")
                ModifiedDate =   $ModDate
            }

            $NewObject = New-Object psobject -Property $Hash
            $ODFiles += $NewObject

        }

    } ELSE { Write-Host "No files found in OneDrive for user" $($MySite.Owner) -ForegroundColor Yellow }

    Write-Host ""
    # Write-Host "Removing Admin rights from OneDrive Site Collection" -ForegroundColor Yellow
    # Set-SPOUser -Site $MySite.Url -LoginName $credential.UserName -IsSiteCollectionAdmin $false -ErrorAction SilentlyContinue | Out-Null
    Write-Host ""

}

$ODFiles | select -last 3 | fl

# Get-PSSession | Remove-PSSession

# $ODFiles | Where-Object {$_.User -like "*rudy*"} 

# $ODFiles | Sort-Object MySiteURL, File | ConvertTo-Csv -NoTypeInformation | Out-File C:\temp\ODfiles.csv -Force
# $ODFiles | Sort-Object MySiteURL, File | ConvertTo-Csv -NoTypeInformation | % {$_.Replace('"','')} | Out-File C:\temp\ODfiles.csv -Force

# Get-PnPList