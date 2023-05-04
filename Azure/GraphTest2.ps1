# Retrieve all available BitLocker recovery keys, select only desired properties
$BitLockerRecoveryKeys = Invoke-MSGraphOperation -Get -APIVersion "Beta" -Resource "bitlocker/recoveryKeys?`$select=id,createdDateTime,deviceId" -Headers $AuthenticationHeader -Verbose:$VerbosePreference

Invoke-MSGraphOperation -Get -APIVersion "Beta" -Resource "bitlocker/recoveryKeys?`$select=id,createdDateTime,deviceId" #-Headers $AuthenticationHeader -Verbose:$VerbosePreference

Invoke-MSGraphOperation -Get -APIVersion "Beta" -Resource "bitlocker/recoveryKeys?"

Invoke-MSGraphOperation -Get -APIVersion "Beta" -Resource Devices




# Retrieve all managed Windows devices in Intune
$ManagedDevices = Invoke-MSGraphOperation -Get -APIVersion "v1.0" -Resource "deviceManagement/managedDevices?`$filter=operatingSystem eq 'Windows'&select=azureADDeviceId&`$select=deviceName,id,azureADDeviceId" -Headers $AuthenticationHeader -Verbose:$VerbosePreference