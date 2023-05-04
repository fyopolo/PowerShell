#Add required references to OfficeDevPnP.Core and SharePoint client assembly
[System.Reflection.Assembly]::LoadFrom("C:\Program Files\WindowsPowerShell\Modules\SharePointPnPPowerShellOnline\3.29.2101.0\OfficeDevPnP.Core.dll") 
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client")
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Runtime")
 
$siteURL = "https://aleragroup.sharepoint.com/sites/JAC/"
  
$AuthenticationManager = new-object OfficeDevPnP.Core.AuthenticationManager
$ctx = $AuthenticationManager.GetWebLoginClientContext($siteURL)

$Web = $ctx.Web
$Lists = $ctx.Load($Web.Lists)

$ctx.Load($Lists)
$ctx.ExecuteQuery()
  
Write-Host "Title: " $ctx.Web.Title -ForegroundColor Green
Write-Host "Description: " $ctx.Web.Description -ForegroundColor Green

Try {
    #sharepoint online get a document library powershell
    
    $ctx.Web.Lists
    
    $DocLibrary = $Ctx.Web.Lists.GetByTitle($DocLibraryName)
    $Ctx.Load($DocLibrary)
    $Ctx.ExecuteQuery()
 
    Write-host "Total Number of Items in the Document Library:"$DocLibrary.ItemCount
}
Catch {
    write-host -f Red "Error:" $_.Exception.Message
}