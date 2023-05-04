Connect-MgGraph -ClientId "456d146e-c675-4058-a7bb-3c26e06be533" -TenantId "5b808100-5f89-4e87-b816-634cd9906236"
$AllDevices = Get-MgDevice -All
$WinDevices = $AllDevices | Where-Object {$_.OperatingSystem -eq "Windows"}

$Devices = @()
foreach ($Device in $WinDevices){

    $BLKeyId = (Get-MgInformationProtectionBitlockerRecoveryKey -Filter "deviceId eq '$($Device.DeviceId)'").Id
    $BLKey = ((Get-MgInformationProtectionBitlockerRecoveryKey -BitlockerRecoveryKeyId $BLKeyId -Property "key").Key).ToString()
    
    $OwnerID = Get-MgDeviceRegisteredOwner -DeviceId $Device.Id

    $Hash =  [ordered]@{
        DisplayName       = $Device.DisplayName
        DeviceId          = $Device.DeviceId
        OS                = $Device.OperatingSystem
        OSVersion         = $Device.OperatingSystemVersion
        Owner             = (Get-MgUser -UserId $OwnerID.Id).DisplayName
        UserPrincipalName = (Get-MgUser -UserId $OwnerID.Id).UserPrincipalName
        MDM               = IF ($Device.IsManaged) { $Device.IsManaged } ELSE {"None"}
    }
    
    $CusObject = New-Object psobject -Property $Hash
    $Devices += $CusObject


}

# $Devices | Out-GridView