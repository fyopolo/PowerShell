$SiteURL = "https://aleragroup.sharepoint.com/sites/RelphMigrated/LIB/Clients"

Connect-PnPOnline -Url $SiteURL -Interactive

$SubSites = Get-PnPSubWeb #-IncludeRootWeb
$Array = @()

foreach($Item in $SubSites){

    $Hash =  [ordered]@{

        Title                 = $Item.Title
        ServerRelativeUrl     = $Item.ServerRelativeUrl
        URL                   = $Item.Url
        Id                    = $Item.Id
        Created               = $Item.Created
        QuickLaunchEnabled    = $Item.QuickLaunchEnabled
        HorizontalQuickLaunch = $Item.HorizontalQuickLaunch
        IsHomepageModernized  = $Item.IsHomepageModernized
        LogoURL               = $Item.SiteLogoUrl
        Theme                 = $Item.ThemeInfo
        WebTemplate           = $Item.WebTemplate
        WelcomePage           = $Item.WelcomePage
        ParentWebId           = $Item.ParentWeb.Id
        ParentWebTitle        = $Item.ParentWeb.Title

    }
    
    $Object = New-Object psobject -Property $Hash
    $Array += $Object

}

$Array.Count
$Array | Export-Excel -Path 'D:\DOCS\Companies\Alera Group\Firms\Relph\SP-SubSites-List.xlsx' -AutoSize -FreezeTopRow -AutoFilter
$Array | Out-GridView