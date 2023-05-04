Write-Host "Dedupe"
$DedupeFeature = Get-WindowsFeature | where { $_.InstallState -eq "Installed" -and $_.DisplayName -eq "Data Deduplication" }
    
IF ([string]::IsNullOrWhiteSpace($DedupeFeature.Name)) {

    Add-WindowsFeature -Name FS-Data-Deduplication -IncludeAllSubFeature
    Enable-DedupVolume -Volume R: -UsageType Backup
    Set-DedupVolume -Volume R: -MinimumFileAgeDays 1
        
} ELSE { "Data Deduplication feature found installed" }

$RunningVMs = Get-VM | Where-Object { $_.State -ne "Off"}
$RootPath = "R:\Rollback"
$Today = (Get-Date).ToString("yyyy-MM-dd")

#     Determining Total VMs Size

$Storage = @()

foreach ($VM in $RunningVMs){

    $vHDD = Get-VHD -VMId $vm.Id

    foreach ($Disk in $vHDD){
        $Hash =  [ordered]@{
            VMName = $VM.Name
            DiskCount = $vHDD.Count
            AttachedvHDD = $Disk.Path
            SizeGB = [math]::Round(($Disk.FileSize/1GB),2)
        } # Hash

    $NewObject = New-Object psobject -Property $Hash
    $Storage += $NewObject
    }
}

$TotaVMsSizeGB = ($Storage | Measure-Object -Property SizeGB -Sum).Sum

IF ($TotaVMsSizeGB -lt (Get-PSDrive -Name R).Free){

#   Export Virtual Machines

    foreach ($VM in $RunningVMs){

        $TargetPath = $($RootPath + "\" + $Today + "\" + $VM.Name)

        IF (-NOT(Test-Path -Path $($TargetPath))){
            New-Item -Path $TargetPath -ItemType Directory -Force
        }

        Write-Host "Exporting $($VM.Name)..."
        Export-VM -VM $VM -Path $TargetPath -Passthru

    }

}

<#

$BitLockerInfo = @()

foreach ($Device in (Get-BitLockerVolume)){

    $Device

}

#>