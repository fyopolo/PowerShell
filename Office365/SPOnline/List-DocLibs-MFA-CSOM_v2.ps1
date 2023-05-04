#Add required references to OfficeDevPnP.Core and SharePoint client assembly
[System.Reflection.Assembly]::LoadFrom("C:\Program Files\WindowsPowerShell\Modules\SharePointPnPPowerShellOnline\3.29.2101.0\OfficeDevPnP.Core.dll") 
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client")
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Field")
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Runtime")
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Taxonomy")

$SiteURL = "https://aleragroup.sharepoint.com/sites/JAC/benefit-services/Group%20Clients"

$Ctx = $AuthenticationManager.GetWebLoginClientContext($SiteURL)
$Web = $Ctx.web
$Ctx.Load($Web)
$Ctx.Load($Web.Lists)
$Ctx.Load($web.Webs)
$Ctx.executeQuery()

Write-Host "Title: " $ctx.Web.Title -ForegroundColor Green
Write-Host "Description: " $ctx.Web.Description -ForegroundColor Green
  
Write-host -f Yellow "Processing Site: $SiteURL"
  
#sharepoint online powershell list all document libraries
$Lists = $Web.Lists | Where {$_.BaseType -eq "DocumentLibrary" -and $_.Hidden -eq $False}
 
#   Loop through each document library and Get the Title
Foreach ($List in $Lists) {

    Write-host $List.Title
    $List.item

}

#   Iterate through each subsite of the current web and call the function recursively
ForEach ($Subweb in $Web.Webs) {
    #Call the function recursively to process all subsites
    Get-SPODocumentLibrary($Subweb.url)
}
