$SiteURL= "https://aleragroup.sharepoint.com/teams/TheDBLCenter"
Connect-PnPOnline -Url $SiteURL -Interactive
  
#Get All Items deleted from a specific path or library - sort by most recently deleted
$DeletedItems = Get-PnPRecycleBinItem -RowLimit 500000 | Sort-Object -Property DeletedDate -Descending
Write-Host "Found $($DeletedItems.Count) items in Recycle Bin" -ForegroundColor Cyan
Write-Host ""

$DeletedItems | Select Title, DeletedDate, DeletedByName, ItemType, LeafName, Id | ft -AutoSize

#Restore all deleted items from the given path to its original location
ForEach($Item in $DeletedItems) {

    #Get the Original location of the deleted file
    $OriginalLocation = "/"+$Item.DirName+"/"+$Item.LeafName
    
    IF ($Item.ItemType -eq "File") { $OriginalItem = Get-PnPFile -Url $OriginalLocation -AsListItem -ErrorAction SilentlyContinue }
    ELSE { $OriginalItem = Get-PnPFolder -Url $OriginalLocation -ErrorAction SilentlyContinue } #Folder
    
    #Check if the item exists in the original location
    
    IF ($OriginalItem -eq $null) {
        #Restore the item
        #$Item | Restore-PnpRecycleBinItem -Force -Verbose
        Write-Host "Item '$($Item.LeafName)' restored Successfully!" -ForegroundColor Green
    }
    ELSE { Write-Host "There is another file with the same name... Skipping item name '$($Item.LeafName)' // Item type: $($Item.ItemType)" -ForegroundColor Yellow }
}

$Rpt = $DeletedItems | Select Title, DeletedDate, DeletedByName, ItemType, LeafName, Id
$Rpt | Export-Csv -Path C:\TEMP\DBL_Deleted_SPOnline.csv -NoTypeInformation
$Rpt | Out-GridView