Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -ShowProgress $true

$Date = Get-Date -DisplayHint Date -Format MM-dd-yyyy
$FileName = "GCG_All_Staff" + "_" + $Date + ".xlsx"
$DynDL = Get-DynamicDistributionGroup -Identity GCG_All_Staff
$Array = @()

foreach ($DL in $DynDL) { # This container is left for future script upgrades and to include all Dynamic DLs

    foreach ($Member in $DL) {
        
        $Members = Get-DynamicDistributionGroupMember -Identity $Member.Name -ResultSize Unlimited

        foreach ($Item in $Members) {

            $Hash =  [ordered]@{
            Name               = $Item.Name
            DisplayName        = $Item.DisplayName
            PrimarySmtpAddress = $Item.PrimarySmtpAddress
            Type               = $Item.RecipientTypeDetails

            }

        $NewObject = New-Object psobject -Property $Hash
        $Array += $NewObject
        }
    }
}

$Array | Sort-Object Name | Export-Excel -Path $('C:\TEMP\' + $FileName) -AutoSize -AutoFilter -FreezeTopRow  -BoldTopRow