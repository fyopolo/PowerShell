#   Add a new managed metadata column to document library
#   and add fields to default view

$SiteURL = "https://aleragroup.sharepoint.com/sites/JAC/benefit-services/Group%20Clients"
Connect-PnPOnline -Url $SiteURL -Interactive

$Subsites = Get-PnPSubWeb
$ContentTypeName ="Document"
$FieldDisplayName1 = "Insurance - Coverage Type"
$FieldDisplayName2 = "Insurance - Document Type"
$FieldInternalName1 = "Insurance_x0020__x002d__x0020_Coverage_x0020_Type"
$FieldInternalName2 = "Insurance_x0020__x002d__x0020_Document_x0020_Type"

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
        
        #Get-PnPContext
        #Set-PnPContext
        #Get-PnPContentType -List $DL

        #Get the List content type
        #              $ContentType = Get-PnPContentType -List $DL -Identity $ContentTypeName
        #   $ContentType = Get-PnPContentType -List $DL.Title
  
        #Load the "Fields" collection to retrieve All Fields from the Content Type
        #              $ContentTypeFields = Get-PnPProperty -ClientObject $ContentType -Property Fields


        #   $ContentType = Get-PnPContentType -Identity "Clients - Insurance" -List $DL.Title
        #   $ContentType = Get-PnPContentType -List $DL.Title
        #   $ContentTypeFields = Get-PnPProperty -ClientObject $($ContentType | Where-Object {$_.Group -like "*Custom*"}) -Property Fields

        #   Add-PnPContentTypeToList -List $DL.Title -ContentType "Enterprise Keywords"
        #   Add-PnPTaxonomyField -List $DL.Title -DisplayName "Enterprise Keywords" -InternalName "TaxKeyword" #-AddToDefaultView

        #   IF ($FieldInternalName -notin $DL.Fields.InternalName){

            Write-Host "Processing $($DL.Title) in site $($Subsite.Title) ..." -ForegroundColor Cyan

            #   Below adds a new column (not a Site column)
            Add-PnPTaxonomyField -List $DL -DisplayName $FieldDisplayName1 -InternalName $FieldInternalName1 -TaxonomyItemId e4667c1b-b843-4b81-99c3-25726739595b -AddToDefaultView -MultiValue -FieldOptions AddToAllContentTypes -ErrorAction SilentlyContinue
            Add-PnPTaxonomyField -List $DL -DisplayName $FieldDisplayName2 -InternalName $FieldInternalName2 -TaxonomyItemId 1492628c-9866-4739-a42a-37236011a12d -AddToDefaultView -MultiValue -FieldOptions AddToAllContentTypes -ErrorAction SilentlyContinue
            Write-Host ""
        
        #   } ELSE { Write-Host "Keywords fiel was already found in Document Library: $($DL.Title). Nothing further to do." -ForegroundColor Yellow }

    }

}

<#
#     TROUBLESHOOTING COLLECTION HAS NOT BEEN INITILIAZED

#Get the List content type
$ContentType = Get-PnPContentType -Identity $ContentTypeName -List $DL.Title
  
#Load the "Fields" collection to retrieve All Fields from the Content Type
$ContentTypeFields = Get-PnPProperty -ClientObject $ContentType -Property Fields
 
#Get Field Title, Internal Name and ID
$ContentTypeFields | Select Title, InternalName, ID
#>