$ErrorActionPreference = “SilentlyContinue”

Connect-MgGraph -ClientId "456d146e-c675-4058-a7bb-3c26e06be533" -TenantId "5b808100-5f89-4e87-b816-634cd9906236"
$AllDevices = Get-MgDevice -All
$WinDevices = $AllDevices | Where-Object {$_.OperatingSystem -eq "Windows"}

$Devices = @()
$Flag = 0

foreach ($Device in $WinDevices){

    $Flag ++
    Write-Progress -Activity "Gathering data..." -Status "Processing $Flag of $($WinDevices.Count)" -CurrentOperation $Device.DisplayName -PercentComplete ($Flag / $($WinDevices.Count) * 100)
    
    $BLKeyId = (Get-MgInformationProtectionBitlockerRecoveryKey -Filter "deviceId eq '$($Device.DeviceId)'").Id
    IF ([string]::IsNullOrWhiteSpace($BLKeyId)) { $BLKey = "Not found" } ELSE { $BLKey = ((Get-MgInformationProtectionBitlockerRecoveryKey -BitlockerRecoveryKeyId $BLKeyId -Property "key").Key).ToString() }

    $OwnerID = Get-MgDeviceRegisteredOwner -DeviceId $Device.Id

    $Hash =  [ordered]@{
        DisplayName       = $Device.DisplayName
        DeviceId          = $Device.DeviceId
        Enabled           = $Device.AccountEnabled
        CreationDate      = [dateTime]($Device.AdditionalProperties.createdDateTime).Split("T")[0]
        LastSeen          = $Device.ApproximateLastSignInDateTime
        OS                = $Device.OperatingSystem
        OSVersion         = $Device.OperatingSystemVersion
        Owner             = (Get-MgUser -UserId $OwnerID.Id).DisplayName
        UserPrincipalName = (Get-MgUser -UserId $OwnerID.Id).UserPrincipalName
        JoinType          = IF ($Device.ProfileType -eq "RegisteredDevice") {"Azure AD Registered"} ELSE {"Azure AD Joined"}
        MDM               = IF ($Device.IsManaged) { "Microsoft Intune" } ELSE {"None"}
        BitLockerKeyID    = IF ($BLKeyId) {$BLKeyId} ELSE {"Not found"}
        RecoveryPassword  = IF ($BLKeyId -eq "Not found*") {"Not found"} ELSE {$BLKey}
    }
    
    $CusObject = New-Object psobject -Property $Hash
    $Devices += $CusObject
    

}

# $Devices | Out-GridView
# $Devices | Export-Excel -Show
$Devices | Export-Excel -Path C:\TEMP\AAD-BLKeys.xlsx -AutoSize -FreezeTopRow -BoldTopRow -AutoFilter