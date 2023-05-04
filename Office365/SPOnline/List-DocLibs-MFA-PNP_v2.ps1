$SiteURL = "https://aleragroup.sharepoint.com/sites/JAC/benefit-services/Group%20Clients"
$Col1 = "Insurance - Coverage Type"
$Col2 = "Insurance - Document Type"
Connect-PnPOnline -Url $SiteURL -Interactive

$Subsites = Get-PnPSubWeb

Write-Host "Subsites discovered"
$Subsites
Write-Host ""

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
        Add-PnPField -Field $Col1 -List $DL
        Add-PnPField -Field $Col2 -List $DL
        Write-Host ""

        # Check if view doesn't have the column already.
        # Add column to view if missing.

        IF(-NOT($ListView.ViewFields -contains "Coverage_x0020_Type")) {
            
            $ListView.ViewFields.Add($Col1)
            $ListView.Update()
            $Context.ExecuteQuery()
        
        } ELSEIF (-NOT($ListView.ViewFields -contains "Document_x0020_Type")) {

            $ListView.ViewFields.Add($Col2)
            $ListView.Update()
            $Context.ExecuteQuery()
        }

    }

}