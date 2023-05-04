$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("aw-tenant-code", "ur0b0kC5fUQKdE2jKvWaC4bMCNEqHLoy/UWCyZT0hmQ=")
$headers.Add("Authorization", "Basic RmVybmFuZG8gWW9wb2xvOkNIQG1wdS4yMg==")
$headers.Add("Cookie", "WS1UEMCOOKIE=027c7c87c2-2d5b-42s5YtqvJO2mZMBWO0L9ywLN4C9lxWeJ5gph2c61RlbmhBYVfmox94_VESLM7hbYNrR2Y")

$body = ""

Add-Content -Path "C:\TEMP\AirWatchDeviceEncryptionKeys.csv" -Value '"ID","Last Seen","HostName","When Enrolled","Device Friendly Name","Enrollment Status","Compliance Status","Device Model","OS","Asset Number","IMEI","User Login","User Name","User Email","PersonalRecoveryKey","StaticRecoveryKey","GracePeriodRecoveryKey"'

$pageResponse = Invoke-RestMethod 'https://cn888.awmdm.com/api/mdm/devices/search?pagesize=1&page=0' -Method 'GET' -Headers $headers -Body $body

$totalPages = [math]::ceiling($pageResponse.DeviceSearchResult.Total / 500)

for ($i = 0; $i -lt $totalPages; $i++) {
    try {
        $response = Invoke-RestMethod "https://cn888.awmdm.com/api/mdm/devices/search?pagesize=500&page=$i" -Method 'GET' -Headers $headers -Body $body
        $response.DeviceSearchResult.Devices | ForEach-Object {
            $deviceId = $_.Id.InnerXML
            $deviceId
            $deviceLastSeen = $_.LastSeen
            $devicePlatform = $_.Platform.replace(","," ")
            $deviceHostName = $_.DeviceReportedName
            $deviceWhenEnrolled     = $_.LastEnrolledOn
            $deviceFriendlyName = $_.DeviceFriendlyName.replace(","," ")
            $deviceEnrollmentStatus = $_.EnrollmentStatus
            $deviceComplianceStatus = $_.ComplianceStatus
            $deviceModel = $_.Model.replace(","," ")
            $deviceOS = $_.OperatingSystem.replace(","," ")
            $deviceAssetNumber      = $_.AssetNumber
            $deviceIMEI             = $_.Imei
            $deviceUser = $_.UserName
            $deviceUserName = $_.UserId.Title
            $deviceUserEmail = $_.UserEmailAddress

            try {
                $securityResponse = Invoke-RestMethod "https://cn888.awmdm.com/api/mdm/devices/$deviceId/Security" -Method 'GET' -Headers $headers -Body $body
                $PersonalRecoveryKey = $securityResponse.DeviceSecurityInfo.PersonalRecoveryKey.InnerXML
                $StaticRecoveryKey = $securityResponse.DeviceSecurityInfo.StaticRecoveryKey.InnerXML
                $GracePeriodRecoveryKey = $securityResponse.DeviceSecurityInfo.GracePeriodRecoveryKey.InnerXML   
            }
            catch {
                Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 
                Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
                $PersonalRecoveryKey = ""
                $StaticRecoveryKey = ""
                $GracePeriodRecoveryKey = ""  
            }
            Add-Content -Path "C:\TEMP\AirWatchDeviceEncryptionKeys.csv" -Value "$deviceId,$deviceLastSeen,$devicePlatform,$deviceHostName,$deviceWhenEnrolled,$deviceFriendlyName,$deviceEnrollmentStatus,$deviceComplianceStatus,$deviceModel,$deviceOS,$deviceAssetNumber,$deviceIMEI,$deviceUser,$deviceUserName,$deviceUserEmail,$PersonalRecoveryKey,$StaticRecoveryKey,$GracePeriodRecoveryKey"
            
        }
    }
    catch {
        Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__ 
        Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
    }
}