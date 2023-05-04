# $clientId = "456d146e-c675-4058-a7bb-3c26e06be533"
# $authTenant = "5b808100-5f89-4e87-b816-634cd9906236"
# $graphScopes = "BitlockerKey.Read.All BitlockerKey.ReadBasic.All Device.Command Device.Read Device.Read.All DeviceManagementApps.Read.All DeviceManagementApps.ReadWrite.All DeviceManagementConfiguration.Read.All DeviceManagementConfiguration.ReadWrite.All DeviceManagementManagedDevices.PrivilegedOperations.All DeviceManagementManagedDevices.Read.All DeviceManagementManagedDevices.ReadWrite.All DeviceManagementRBAC.Read.All DeviceManagementRBAC.ReadWrite.All DeviceManagementServiceConfig.Read.All DeviceManagementServiceConfig.ReadWrite.All Policy.ReadWrite.DeviceConfiguration TeamworkDevice.Read.All TeamworkDevice.ReadWrite.All User.Read profile openid email Mail.Read Mail.Send"

# Authenticate the user
# Connect-MgGraph -ClientId $clientId -TenantId $authTenant -Scopes $graphScopes -UseDeviceAuthentication

# Get-MgContext

# Get-MgUser -Select "displayName,id,mail" -Top 25 -OrderBy "displayName"
# Get-MgDevice -DeviceId 3f5e0a6d-0482-4a5b-ad3d-8fca09037d96

# Get-MgDevice | gm
# Get-MgDeviceManagement | gm
# Get-MgDeviceManagementDeviceConfiguration | gm
# Get-MgUserRegisteredDevice -UserId a070916e-24ab-4365-a681-e90e75e3501a

# $Dev = Get-MgDevice -DeviceId 3f5e0a6d-0482-4a5b-ad3d-8fca09037d96
# $Dev.IsManaged

# Connect-MgGraph -ClientId "456d146e-c675-4058-a7bb-3c26e06be533" -TenantId "5b808100-5f89-4e87-b816-634cd9906236"
# Get-MgInformationProtectionBitlockerRecoveryKey

# $Device = Get-MGDevice -filter "Name eq 'ZIN-CShaud'"

# $Device = Get-MgDevice -DeviceId 0052cfe2-ff94-4a83-8f36-24c388f3a163

# $BTKey = Get-MgInformationProtectionBitlockerRecoveryKey -filter "deviceId eq $device.guid"

# $bitlockerRecoveryKeyId = Get-MgInformationProtectionBitlockerRecoveryKey -BitlockerRecoveryKeyId "ad5eb0e5-3a77-4051-9ec4-32b2263e49df"

Connect-MgGraph -ClientId "456d146e-c675-4058-a7bb-3c26e06be533" -TenantId "5b808100-5f89-4e87-b816-634cd9906236"
# Import-Module Microsoft.Graph.Identity.SignIns
Get-MgInformationProtectionBitlockerRecoveryKey -BitlockerRecoveryKeyId "ad5eb0e5-3a77-4051-9ec4-32b2263e49df" -Property "key"


