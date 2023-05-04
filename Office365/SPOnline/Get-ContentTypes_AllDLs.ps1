$SiteURL = "https://aleragroup.sharepoint.com/sites/JAC/benefit-services/Group%20Clients"
Connect-PnPOnline -Url $SiteURL -Interactive

#   $Col1 = "Insurance - Coverage Type"
#   $Col2 = "Insurance - Document Type"

$Subsites = Get-PnPSubWeb

Write-Host "Subsites discovered"
$Subsites
Write-Host ""

$DLDetail = @()

foreach ($Subsite in $Subsites){

    Write-Host ""
    Connect-PnPOnline $Subsite.Url -Interactive
    
    $SubsiteDocLibs = Get-PnPList | Where-Object { $_.BaseTemplate -eq "101" -and $_.Title -ne "Site Assets" }
    Write-Host "Document Libraries discovered in subsite $($Subsite.Title) // Count: $($SubsiteDocLibs.Count)"
    $SubsiteDocLibs | Select Title, Id | ft -AutoSize
    Write-Host ""

    foreach ($DL in $SubsiteDocLibs){

        Write-Host "Processing $($DL.Title) in site $($Subsite.Title) ..." -ForegroundColor Cyan

        $Context = Get-PnPContext
        $ListView = Get-PnPView -List $DL | Where-Object { $_.DefaultView -eq "True" }
        $CTList = Get-PnPContentType -List $DL | Where-Object { $_.Name -ne "Document" -and $_.Name -ne "Folder" }

        $Hash =  [ordered]@{
            SubSite                 =    $Subsite.Title
            LibraryName             =    $DL.Title
            DefaultView             =    $ListView.Title
            CTLinked                =    $CTList.Name
            CTGroup                 =    $CTList.Group
        }
    
        $Object = New-Object psobject -Property $Hash
        $DLDetail += $Object


    }

}

$DLDetail | Out-GridView
$DLDetail | Export-Excel -Path C:\TEMP\JAC_DLs_ContentTypes.xlsx -AutoSize -FreezeTopRow -AutoFilter -BoldTopRow