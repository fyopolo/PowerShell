#note, you must run connect-msol first!
$licenses = get-msolaccountsku | Where-Object {$_.SkuPartNumber -notlike "*FLOW_FREE*" -and $_.SkuPartNumber -notlike "*WINDOWS_STORE*" -and $_.SkuPartNumber -notlike "*POWER_BI*"}
Write-host "This script will output all the license and sublicense types for your tenant"
write-host "(Technically, these are AccountSkuID and ServiceStatus.Serviceplan.Servicename)" -foregroundcolor gray
write-host " "
write-host "Primary License (AccountSkuID)" -foregroundcolor green
write-host "   Sub License (AccountSkuID.ServiceStatus.ServicePlan.ServiceName)" -foregroundcolor yellow
write-host "----------------------------------------------------------------------------"
foreach ($license in $licenses | Sort-Object AccountSkuId)
{
    $line = "{0,-35} {1,18} {2,18}" -f $license.accountskuID, "($($license.activeunits) active)", "($($license.consumedunits) used)" 
    write-host $line -foregroundcolor green
    
    <#  
    foreach ($sublicense in $license.servicestatus)
	{
    	write-host  "   $($sublicense.serviceplan.servicename)" -foregroundcolor yellow
    }
#>
}

$license.Activeunits