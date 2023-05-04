Connect-MgGraph -ClientId "456d146e-c675-4058-a7bb-3c26e06be533" -TenantId "5b808100-5f89-4e87-b816-634cd9906236"

Write-Host "Fetching devices. Please wait..."
$AllDevices = Get-MgDevice -All
Write-Host "Found $($AllDevices.Count) devices."
$WinDevices = $AllDevices | Where-Object {$_.OperatingSystem -eq "Windows"} # | select -First 1000
# $WinDevices = Get-MgDevice -DeviceId 0d0a9968-199b-46ec-a0b6-cd729f247d76 # THIS LINE IS FOR TESTING ONLY AS THIS DEVICE HAS MULTIPLE BL KEYS AND DRIVE TYPES
Write-Host "Found $($WinDevices.Count) Windows devices."
Write-Host "Gathering security info. Please wait..."
$KeyInfo = Get-MgInformationProtectionBitlockerRecoveryKey -All

$Devices = @()
$Flag = 0

foreach ($Device in $WinDevices){

    $BLKeyID = $null
    $DriveType = $null
    $BLRKeyPwd = $null
    $VolType = $null

    $Flag ++
    Write-Progress -Activity "Gathering data..." -Status "Processing $Flag of $($WinDevices.Count)" -CurrentOperation $Device.DisplayName -PercentComplete ($Flag / $($WinDevices.Count) * 100)
    
    $RetKeys = $KeyInfo | Where-Object {$_.DeviceId -match $Device.DeviceId}

    foreach ($Item in $RetKeys){

        $BLKeyInfo = Get-MgInformationProtectionBitlockerRecoveryKey -BitlockerRecoveryKeyId $Item.Id -Property Key

        foreach ($Case in $BLKeyInfo){
            $VolType += $Case.VolumeType
            
            SWITCH ($Case.VolumeType){
                1 { [string]$VolType = "Operating System Drive" }
                2 { [string]$VolType = "Fixed Data Drive" }
                default { $VolType = "Unknown" }
            }
     
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
                BitLockerKeyID    = $BLKeyInfo.Id
                DriveType         = $VolType
                RecoveryPassword  = $BLKeyInfo.Key
            }
    
        $CusObject = New-Object psobject -Property $Hash
        $Devices += $CusObject

        }
    }

}

# $Devices
# $Devices | Out-GridView
$Devices | Export-Excel -Path D:\Scripts\PowerShell\BitLocker\AAD-BLKeys_Singleline.xlsx -AutoSize -FreezeTopRow -BoldTopRow -AutoFilter