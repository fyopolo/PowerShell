#Config Variables
$SiteURL = "https://aleragroup.sharepoint.com/sites/RelphMigrated/LIB/Clients"
$SubSites = Import-Excel -Path 'D:\DOCS\Companies\Alera Group\Firms\Relph\SP-SubSites-List.xlsx'

Try {
    #Connect to PnP Online
    Connect-PnPOnline -Url $SiteURL -Interactive

    #Get the Context
    $Context =  Get-PnPContext

    $ParentNode = Get-PnPNavigationNode -Location QuickLaunch | Where-Object {$_.Title -eq "Sites"}
    $ParentNodeID = Get-PnPNavigationNode -Id $ParentNode.Id
    
    $ChildNodes = $ParentNodeID.Children
    
    # Backup Child Nodes
    $ChildNodes | Sort Title | Select Id, Title, IsVisible, Url | Out-GridView
    $ChildNodes | Sort Title | Select Id, Title, IsVisible, Url | Export-Excel -Path 'D:\DOCS\Companies\Alera Group\Firms\Relph\Relph-SP-QuickLaunchIems_BACKUP.xlsx' -AutoSize -AutoFilter -FreezeTopRow

    Write-Host ""
    Write-Host "Found $($ChildNodes.Count) child nodes in SITES Root node" -ForegroundColor Cyan
    Write-Host ""

    # Get all Items within "Sites" Root Node and delete them.
    # Otherwise new ones will not be added alphabetically sorted but at the end of the list instead.
    
    Write-Host "Removing child nodes..." -ForegroundColor Yellow
    #   foreach ($ChildNode in $ChildNodes){ Remove-PnPNavigationNode $ChildNode.Id -Force | Out-Host }

    # Add a ROOT Link to Quick Launch Navigation
    # Add-PnPNavigationNode -Title "Sites" -Url "https://aleragroup.sharepoint.com/sites/RelphMigrated/LIB/Clients/_layouts/15/viewlsts.aspx?view=15" -Location "QuickLaunch"

    Write-Host ""
    Write-Host "Adding $($SubSites.Count) child nodes..." -ForegroundColor Yellow

    #   foreach ($SubSite in $SubSites){
        #Add child nodes link under "Sites" Root Node
    #    Add-PnPNavigationNode -Title $SubSite.Title -Url $SubSite.URL -Location QuickLaunch -Parent $ParentNode.Id -Verbose #-ErrorAction SilentlyContinue
    #}

    Write-Host ""
    Write-host "Quick Launch Links Added Successfully!" -f Green
    Write-Host ""

    # Export new Quick Launch Item Nodes

    $ParentNode = Get-PnPNavigationNode -Location QuickLaunch | Where-Object {$_.Title -eq "Sites"}
    $ParentNodeID = Get-PnPNavigationNode -Id $ParentNode.Id
    
    $ChildNodes = $ParentNodeID.Children

    $ChildNodes | Sort Title | Export-Excel -Path 'D:\DOCS\Companies\Alera Group\Firms\Relph\Relph-SP-QuickLaunchIems_POST.xlsx' -AutoSize -AutoFilter -FreezeTopRow
    $ChildNodes | Sort Title | Export-Csv -Path 'C:\TEMP\Relph-SP-QuickLaunchIems_POST.csv' -NoTypeInformation

}
catch {

    write-host "Error: $($_.Exception.Message)" -foregroundcolor Red

}


# Read more: https://www.sharepointdiary.com/2018/03/sharepoint-online-add-link-to-quick-launch-using-powershell.html#ixzz7TemxH4yw

# $ChildNodes | Export-Excel -Show