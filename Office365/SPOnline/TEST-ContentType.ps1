$SiteURL = "https://aleragroup.sharepoint.com/sites/JAC/benefit-services/Group%20Clients/Groups%20Y-Z"
$Col1 = "Insurance - Coverage Type"
$Col2 = "Insurance - Document Type"
$ListName = "TEST_METADATA"
  
#Connect to PnP Online
Connect-PnPOnline -Url $SiteURL -Interactive
$ContentTypeName = Get-PnPContentType -List $ListName
#   $ContentTypeName = (Get-PnPContentType -List $ListName | Where-Object { $_.Group -eq "Custom Content Types" }).Name
  
#Get the List content type
$ContentType = Get-PnPContentType -Identity $ContentTypeName -List $ListName
  
#Load the "Fields" collection to retrieve All Fields from the Content Type
$ContentTypeFields = Get-PnPProperty -ClientObject $ContentType -Property Fields
 
#Get Field Title, Internal Name and ID
$ContentTypeFields | Select Title, InternalName, ID
# $ContentTypeFields | gm

# Add-PnPField -InternalName "Coverage_x0020_TypeTaxHTField0" -List $ListName