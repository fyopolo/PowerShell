
$BitlockerVolumes = Get-BitLockerVolume

$BLStatus = @()

foreach ($Volume in $BitlockerVolumes){

    foreach ($ProtectorType in $Volume){

        [string]$ProtectorID = ($ProtectorType.KeyProtector | Where-Object {$_.KeyProtectorType -eq "RecoveryPassword"}).KeyProtectorId
        
        IF ($Volume.ProtectionStatus -eq "On") {
            IF ($Volume.KeyProtector.RecoveryPassword) {
                [string]$RecoveryKey = $Volume.KeyProtector.RecoveryPassword
                } ELSE { $RecoveryKey = "Key Not Found" }

            $Hash =  [ordered]@{
                ComputerName       = $Volume.ComputerName
                TPMPresent         = (Get-Tpm).TpmPresent
                Volume             = $Volume.MountPoint
                VolumeType         = $Volume.VolumeType
                'VolCapacity(GB)'  = [math]::Ceiling($Volume.CapacityGB)
                ProtectionStatus   = $Volume.ProtectionStatus
                VolumeStatus       = IF ($Volume.VolumeStatus -eq "FullyDecrypted") { "Not Encrypted" } ELSE { $Volume.VolumeStatus }
                KeyProtectorType   = [string]$Volume.KeyProtector.KeyProtectorType
                BitLockerKeyID     = $ProtectorID.Replace("{","").Replace("}","")
                RecoveryKey        = $RecoveryKey.ToString().Trim()
            }

        $Object = New-Object psobject -Property $Hash
        $BLStatus += $Object
    
        }

    }

}
$BLStatus | Out-File -FilePath "C:\TEMP\BicLotkerStat_$($BitlockerVolumes.ComputerName).txt"
$BLStatus | Export-Csv -Path "C:\TEMP\BicLotkerStat_$($BitlockerVolumes.ComputerName).csv" -NoTypeInformation