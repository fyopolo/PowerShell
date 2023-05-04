$credential = Get-Credential
Connect-MsolService -Credential $credential
Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking

Import-Module ReportHTML

$InitialDomain = Get-MsolDomain | Where-Object {$_.IsInitial -eq $true}
$SharePointAdminURL = "https://$($InitialDomain.Name.Split(".")[0])-admin.sharepoint.com"

Connect-SPOService -Url $SharePointAdminURL -credential $credential

$OneDriveSites = Get-SPOSite -IncludePersonalSite $true -Limit all -Filter "Url -like '-my.sharepoint.com/personal/"
$ODFiles = @()

foreach ($MySite in $OneDriveSites) {

    Write-Host "Granting Admin rights over" $MySite.Url "for Global Admin" -ForegroundColor Green
    Set-SPOUser -Site $MySite.Url -LoginName $credential.UserName -IsSiteCollectionAdmin $true | Out-Null
    Connect-PnPOnline -Url $MySite.Url -Credentials $credential | Out-Null

    Write-Host "Getting files for OneDrive user" $($MySite.Owner) -ForegroundColor Cyan
    $OneDriveFiles = Get-PnPListItem -List Documents -PageSize 1000

    IF ($OneDriveFiles.Count -gt 0) {
        foreach ($File in $OneDriveFiles) {
            $UserFiles = ($File.FieldValues.FileRef)
            Write-Host "File Name:" $UserFiles

            $Hash = [ordered]@{
                User        =   $MySite.Owner
                MySiteTitle =   $MySite.Title
                MySiteURL   =   $MySite.Url
                File        =   $UserFiles
            }

            $NewObject = New-Object psobject -Property $Hash
            $ODFiles += $NewObject

        }

    } ELSE { Write-Host "No files found in OneDrive for user" $($MySite.Owner) -ForegroundColor Yellow }

    Write-Host ""
    Write-Host "Removing Admin rights from OneDrive Site Collection" -ForegroundColor Yellow
    Set-SPOUser -Site $MySite.Url -LoginName $credential.UserName -IsSiteCollectionAdmin $false | Out-Null
    Write-Host ""

}

Get-PSSession | Remove-PSSession

$ODFiles | Sort-Object MySiteURL, File | ConvertTo-Csv -NoTypeInformation | % {$_.Replace('"','')} | Out-File C:\temp\ODfiles.csv -Force

Write-Host "Building report..." -ForegroundColor Green

# Create an empty array for HTML string
$rpt = @()

### OPEN HTML REPORT
$rpt += Get-HtmlOpenPage -TitleText "OneDrive Report" -HideLogos

$rpt+= Get-HtmlContentOpen -HeaderText "Scanner Details"
    $rpt+= Get-HTMLContentDataTable -ArrayOfObjects ($ODFiles | Sort-Object MySiteURL, File) -HideFooter -PagingOptions "100,200,"
$rpt+= Get-HtmlContentClose

###  CLOSING HTML REPORT
$rpt += Get-HtmlClosePage

Save-HTMLReport -ReportPath "C:\TEMP\" -ReportName "ODReport.html" -ReportContent $rpt -ShowReport | Out-Host