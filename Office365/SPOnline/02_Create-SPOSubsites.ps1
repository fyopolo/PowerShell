Function Load-XLSFile($initialDirectory) {  
    [System.Reflection.Assembly]::LoadWithPartialName(“System.windows.forms”) | Out-Null

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.Title = "Select SKU File"
    $OpenFileDialog.Filter = “Excel Files (*.xlsx)| *.xlsx”
    $Button = $OpenFileDialog.ShowDialog()
    $OpenFileDialog.FileName | Out-Null
    IF ($Button -eq "OK") { Return $OpenFileDialog.FileName }
    ELSE { Write-Error "Operation cancelled by user. Aborting script execution."; Break }
}

Connect-PnPOnline -Url https://aleragroup.sharepoint.com/sites/RelphMigrated/LIB/Clients -Interactive

$SubSites = Import-Excel -Path $(Load-XLSFile)
$SubSitesAll = Get-PnPSubWeb -IncludeRootWeb

foreach ($Site in $SubSites){

    New-PnPWeb -Title $Site.SiteName -Url $Site.URLShort -Template "STS#3" -InheritNavigation -Verbose -ErrorAction Continue

}


<#
foreach($Item in $SubSitesAll){


}


Get-PnPNavigationNode
Get-PnPSite

$SubSitesAll = Get-PnPSubWeb -IncludeRootWeb | Select Title, Url, ServerRelativeUrl, Id, Created, QuickLaunchEnabled, HorizontalQuickLaunch, IsHomePageModernized, SiteLogoUrl, MasterUrl, Navigation, NavAudienceTargetingEnabled, ParentWeb, Path, RootFolder, ServerRelativeUrl, ServerRelativePath, ThemeInfo, Webs, WebTemplate, WebTemplateConfiguration, WelcomePage

$SubSitesAll = Get-PnPSubWeb -IncludeRootWeb -Recurse

$SubSitesAll | Export-Excel -Show

$SubSitesAll | Select Title, Url, ServerRelativeUrl, Id, Created, QuickLaunchEnabled, HorizontalQuickLaunch, IsHomePageModernized, SiteLogoUrl, MasterUrl, Navigation, NavAudienceTargetingEnabled, ParentWeb, Path, RootFolder, ServerRelativeUrl, ServerRelativePath, ThemeInfo, Webs, WebTemplate, WebTemplateConfiguration, WelcomePage | Out-GridView

Get-PnPTenantDeletedSite | ft -AutoSize

#>