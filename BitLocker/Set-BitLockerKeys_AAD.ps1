
$BitlockerVolumes = Get-BitLockerVolume

$BLStatus = @()

foreach ($Volume in $BitlockerVolumes){

    #     Recovery Password Key
    $RKey = $null
    $RecoveryPassword = $null
    $RKey = $Volume.KeyProtector | Where-Object {$_.KeyProtectorType -eq "RecoveryPassword"}
    
    IF($RKey.Count -ge 1){
        foreach ($Key in $RKey){
            [string]$RecoveryPassword += "$(($Key.RecoveryPassword))`r`n"
            BackupToAAD-BitLockerKeyProtector -KeyProtectorId $Key.KeyProtectorId -MountPoint $Volume.MountPoint
        }
    } ELSE { $RecoveryPassword = "Not Present" }
    
    #     Recovery Key ID
    $RKeyID = $null
    $RecoveryKeyID = $null
    $RKeyID = $RKey.KeyProtectorId

    IF (-NOT([string]::IsNullOrWhiteSpace($RKeyID))) {
        foreach ($KeyID in $RKeyID){
            [string]$RecoveryKeyID += "$(($KeyID.TrimStart("{").TrimEnd("}")))`r`n"
            BackupToAAD-BitLockerKeyProtector -KeyProtectorId $Key.KeyProtectorId -MountPoint $Volume.MountPoint
        }
    } ELSE { $RecoveryKeyID = "Not Present" }

    $Hash =  [ordered]@{
        ComputerName       = $Volume.ComputerName
        TPMPresent         = (Get-Tpm).TpmPresent
        Volume             = $Volume.MountPoint
        VolumeType         = $Volume.VolumeType
        'VolCapacity(GB)'  = [math]::Ceiling($Volume.CapacityGB)
        ProtectionStatus   = $Volume.ProtectionStatus
        VolumeStatus       = IF ($Volume.VolumeStatus -eq "FullyDecrypted") { "Not Encrypted" } ELSE { $Volume.VolumeStatus }
        KeyProtectorType   = "RecoveryPassword"
        BitLockerKeyID     = $RecoveryKeyID.Trim()
        RecoveryKey        = $RecoveryPassword.Trim()
    }

    $Object = New-Object psobject -Property $Hash
    $BLStatus += $Object

}

# $BLStatus | Out-GridView
$BLStatus | Out-File -FilePath "C:\TEMP\BicLotkerStat_POST_$($env:COMPUTERNAME).txt"
$BLStatus | Export-Csv -Path "C:\TEMP\BicLotkerStat_POST_$($env:COMPUTERNAME).csv" -NoTypeInformation