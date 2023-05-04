#Add required references to OfficeDevPnP.Core and SharePoint client assembly
[System.Reflection.Assembly]::LoadFrom("C:\Program Files\WindowsPowerShell\Modules\SharePointPnPPowerShellOnline\3.29.2101.0\OfficeDevPnP.Core.dll") 
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client")
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Field")
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Runtime")
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Taxonomy")

Clear

# $siteURL = "https://aleragroup.sharepoint.com/sites/JAC/"
$siteURL = "https://aleragroup.sharepoint.com/sites/JAC/benefit-services/Group%20Clients"
  
$AuthenticationManager = New-Object OfficeDevPnP.Core.AuthenticationManager
$Ctx = $AuthenticationManager.GetWebLoginClientContext($siteURL)
$Web = $Ctx.web
$Ctx.Load($Web)
$Ctx.Load($Web.Webs)
$Ctx.ExecuteQuery()



Write-Host "Connected to: $($Ctx.Web.Title)" -ForegroundColor Cyan
Write-Host "Title: $WebDesc" -ForegroundColor Green
Write-Host "Description: $($Ctx.Web.Description)" -ForegroundColor Green
Write-Host "Site URL: $siteURL" -ForegroundColor Green
Write-Host ""

$SubSites = $Web.Webs

IF ($SubSites.Count -ge 1) {
    Write-Host "Subsites List" -ForegroundColor Yellow
    $SubSites | Select Title, ServerRelativeUrl, Url | Sort Title | ft -AutoSize
} ELSE { Write-Host "No subsites were found" }

foreach ($SubSite in $SubSites){
    
    $Ctx = $AuthenticationManager.GetWebLoginClientContext($SubSite.Url)
    $Ctx.Load($Ctx.Web.Lists)
    $Ctx.executeQuery()

    #Filter Document Libraries from Lists collection
    $DocLibraries = $Ctx.Web.Lists | Where {$_.BaseType -eq "DocumentLibrary" -and $_.Hidden -eq $False -and $_.Title -ne "Site Assets" -and $_.Title -ne "Site Pages"} -ErrorAction SilentlyContinue

    IF ($DocLibraries.Count -ge 1){

        Write-Host ""
        Write-Host "Document Libraries found in subsite: $($SubSite.Title) / Count: $($DocLibraries.Count)"
        Write-Host ""
        $DocLibraries | Select Title, ItemCount, ParentWebUrl | Sort Title | ft -AutoSize
        Write-Host ""

    } ELSE { Write-Host "No Document Libraries were found in subSite $($SubSite.Title)" }
    
    foreach ($siteLib in $DocLibraries){

        Write-Host "Processing Document Library: $($siteLib.Title) ..." -ForegroundColor Cyan

        #Load List Fields collection
        $Ctx.Load($siteLib.Fields)
        $Ctx.ExecuteQuery()


        # load the List
$mainList = $ctx.Web.Lists.GetByTitle($siteLib.Title)
$ctx.Load($mainList)
$ctx.Load($mainList.Fields)
$ctx.Load($mainList.ContentTypes)
$ctx.ExecuteQuery()

# load the Taxonomy Field
$TaxonomyKategorieFld = $mainList.Fields.GetByInternalNameOrTitle($mainList.Title)
$ctx.Load($TaxonomyKategorieFld)
$ctx.ExecuteQuery()


$Content = ‘<Field Type=”Note” DisplayName=”Content” Group=”Test”></Field>’
$List.Fields.AddFieldAsXml($Content, $true, [Microsoft.SharePoint.Client.AddFieldOptions]::AddFieldToDefaultView)



$mainList.Fields | sort internalname
$mainList.Fields.Add("Enterprise Keywords")

        $siteLib.Fields.Add("Enterprise Keywords")

        IF (-NOT($siteLib.Fields.InternalName -contains "TaxKeyword")){
        
            Write-Host "Enterprise Keywords not enabled in Document Library:" $siteLib.Title
            $siteLib.Fields.Add($siteLib.ParentWeb.AvailableFields["TaxKeyword"])

            
        } ELSE { Write-Host "Enterprise Keywords is set for this Document Library" -ForegroundColor Green }
        
    }
    
}

