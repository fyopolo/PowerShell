$Headers = @{
    "aw-tenant-code" = "ur0b0kC5fUQKdE2jKvWaC4bMCNEqHLoy/UWCyZT0hmQ="
    "Authorization" = "Basic RmVybmFuZG8gWW9wb2xvOkNIQG1wdS4yMg=="
    "Cookie" = "WS1UEMCOOKIE=027c7c87c2-2d5b-42s5YtqvJO2mZMBWO0L9ywLN4C9lxWeJ5gph2c61RlbmhBYVfmox94_VESLM7hbYNrR2Y"
}

$Cred = Get-Credential

$BaseUri = Invoke-RestMethod "https://cn888.awmdm.com/api/mdm/devices/search" -Method Get -Headers $Headers -Credential $Cred
$ResponseUri = Invoke-RestMethod "https://cn888.awmdm.com/api/mdm/devices/search?pagesize=1&page=0" -Method Get -Headers $Headers
$TotalPages = [math]::ceiling($ResponseUri.DeviceSearchResult.Total / 500)
$TotalDevices = $BaseUri.DeviceSearchResult.Total # ---> This is for the progress bar

$AWDevices = @()
$Flag = 0

for ($i = 0; $i -lt $TotalPages; $i++) {
    $response = Invoke-RestMethod "https://cn888.awmdm.com/api/mdm/devices/search?pagesize=500&page=$i" -Method Get -Headers $headers
    $Devices = $response.DeviceSearchResult.Devices    

    foreach ($Device in $Devices){
        $Flag ++
        Write-Progress -Activity "Gathering data..." -Status "Processing $Flag of $($TotalDevices)" -CurrentOperation $Device.DeviceFriendlyName -PercentComplete ($Flag / $TotalDevices * 100)

        $securityResponse = Invoke-RestMethod "https://cn888.awmdm.com/api/mdm/devices/$($Device.Id.'#text')/Security" -Method Get -Headers $headers
        Write-Host "Getting info for device:" $Device.DeviceReportedName -ForegroundColor Cyan
        [dateTime]$DevLSDate = $Device.LastSeen.Split("T")[0]
        [dateTime]$DevEnDate = $Device.LastEnrolledOn.Split("T")[0]

        $Hash =  [ordered]@{
            
                DeviceId                 = $Device.Id.'#text'
                LastSeenDate             = $DevEnDate
                LastSeenTime             = $Device.LastSeen.Split("T")[1]
                HostName                 = $Device.DeviceReportedName
                WhenEnrolled             = $DevEnDate
                FriendlyName             = $Device.DeviceFriendlyName
                OrgGroup                 = $Device.LocationGroupName
                EnrollmentStatus         = $Device.EnrollmentStatus
                ComplianceStatus         = $Device.ComplianceStatus
                Platform                 = $Device.Platform
                OS                       = $Device.OperatingSystem
                IsEncrypted              = $securityResponse.DeviceSecurityInfo.IsEncrypted.'#text'
                EncryptionStatus         = $securityResponse.DeviceSecurityInfo.EncryptionStatus.'#text'
                BitLockerLevelEncryption = $securityResponse.DeviceSecurityInfo.BlockLevelEncryption.'#text'
                PasscodePresent          = $securityResponse.DeviceSecurityInfo.IsPasscodePresent.'#text'
                Model                    = $Device.Model
                ManagedBy                = $Device.ManagedBy
                AssetNumber              = $Device.AssetNumber
                SerialNumber             = $Device.SerialNumber.ToString()
                IMEI                     = $Device.Imei.ToString()
                UserName                 = $Device.UserId.title
                UserLogin                = $Device.UserName
                UserEMail                = $Device.UserEmailAddress
                PersonalRecoveryKey      = $securityResponse.DeviceSecurityInfo.PersonalRecoveryKey.'#text'
                StaticRecoveryKey        = $securityResponse.DeviceSecurityInfo.StaticRecoveryKey.'#text'
                GracePeriodRecoveryKey   = $securityResponse.DeviceSecurityInfo.GracePeriodRecoveryKey.'#text'

        }

            $Object = New-Object psobject -Property $Hash
            $AWDevices += $Object    

    }

}

Export-Excel -InputObject $AWDevices -Path C:\TEMP\AWDevices.xlsx -AutoSize -FreezeTopRow -AutoFilter -BoldTopRow