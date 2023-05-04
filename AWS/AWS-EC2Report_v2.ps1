
Param(
    [Parameter(Mandatory=$true,HelpMessage="Enter Access Key ")][string]$AccessKey,
    [Parameter(Mandatory=$true,HelpMessage="Enter Secret Access Key ")][string]$SecretAccessKey,
    [Parameter(Mandatory=$true,HelpMessage="Enter Session Token ")][string]$SessionToken
    )

Import-Module AWSPowerShell

Clear-Host

Write-Host "Getting EC2 Instances..." -ForegroundColor Cyan
$Instances = $(Get-EC2Instance -AccessKey $AccessKey -SecretKey $SecretAccessKey -SessionToken $SessionToken).Instances
Write-Host "Getting Volumes..." -ForegroundColor Cyan
$Volumes = Get-EC2Volume -AccessKey $AccessKey -SecretKey $SecretAccessKey -SessionToken $SessionToken
Write-Host "Getting Snapshots..." -ForegroundColor Cyan

foreach ($Item in $Volumes){

    $Item.SnapshotId

}

$Snapshots = $Volumes
$Snapshots = Get-EC2Snapshot -AccessKey $AccessKey -SecretKey $SecretAccessKey -SessionToken $SessionToken


Write-Host ""
Write-Host "Total Snapshots:" $Snapshots.Count


# Archived Snapshots
IF ($Snapshots | Where-Object {$_.StorageTier -eq "archive"}) { $SnapArchived = $Snapshots | Where-Object {$_.StorageTier -eq "archive"} ; $SnapArchivedCount = $SnapArchived.Count }

$EC2Instances = @()

foreach ($Item in $Instances){

    # Get Item Tag = NAME

    $Flag = 0
    $TagIndex = 0
    $Tags = $Item.Tags
    
    foreach ($Tag in $Tags){

        $Flag ++
        IF ($Tag.Key -eq "Name") {$TagIndex = $Flag -1}

    }
    
    $Disks = $($Volumes | Where-Object {$_.Attachments.InstanceId -eq $Item.InstanceId})
    $VolSnap = [string]::Concat("", $Disks.SnapshotId)
    $DeviceName = [string]::Join(", ", $Disks.Attachments.Device)
    $VolType = [string]::Join(", ", $Disks.VolumeType.Value.ToUpper())
    $IOPS = [string]::Join(", ", $Disks.Iops)
    $SecGrp = [string]::Join(", ", $Item.SecurityGroups.GroupName)

    $Hash =  [ordered]@{
        InstanceName       = $Item.Tag.Value.GetValue($TagIndex).ToUpper()
        AvailabilityZone   = $Item.Placement.AvailabilityZone
        Size               = $Item.InstanceType.Value
        Platform           = $Item.PlatformDetails
        State              = $Item.State.Name.Value
        Volumes            = $Disks.Count
        TotalStorageGB     = [int]($Disks.Size | Measure-Object -Sum).Sum
        VolumeType         = $VolType
        DeviceName         = $DeviceName
        DeviceType         = $Item.RootDeviceType.Value.ToUpper()
        VolumeIOPS         = $IOPS
        Snapshots          = $VolSnap
        PrivateIPv4Address = $Item.PrivateIpAddress
        PublicIPv4Address  = $Item.PublicIpAddress
        ElasticIPAddress   = $Item
        SecurityGroups     = $SecGrp
    }

    $NewOBJ = New-Object psobject -Property $Hash
    $EC2Instances += $NewOBJ
}

$EC2Instances | Sort InstanceName |  Out-GridView
$EC2Instances | Export-Excel -Path C:\TEMP\ITX-Prod-EC2.xlsx -Title "ITX Production EC2 Instances Report" -TitleSize 24 -TitleBold -AutoSize -AutoFilter

$StoppedEC2 = $EC2Instances | Where-Object {$_.State -eq "Stopped"}
$StoppedEC2Storage = ($StoppedEC2.TotalStorageGB | Measure-Object -Sum).Sum
$SnapshotsVolTotalGB = ($Snapshots.VolumeSize | Measure-Object -Sum).Sum

Write-Host ""
Write-Host "Stopped EC2 Instances:" $StoppedEC2.Count -ForegroundColor Yellow
Write-Host "Total storage for stopped instances (GB):" $StoppedEC2Storage -ForegroundColor Yellow
$StoppedEC2 | Sort InstanceName | ft -AutoSize
Write-Host "Unattached Volumes:" $($Volumes | Where-Object {$_.Status -eq "Available"}).Count -ForegroundColor Yellow
$Volumes | Where-Object {$_.Status -eq "Available"} | Sort CreateTime -Descending | Select VolumeId, Attachments, State, AvailabilityZone, CreateTime, Iops, Size, Tags | ft -AutoSize
Write-Host ""
Write-Host "Snapshots:" $Snapshots.Count "//" "Total Storage (GB):" $SnapshotsVolTotalGB -ForegroundColor Yellow
$SnapTest = $Snapshots | Select SnapshotId, VolumeSize, StorageTier, State, StartTime, Description | Select -First 5 | ft -AutoSize


### NECESITO CALCULAR EL TAMAÑO (GB) TOTAL POR TIER /// .VolumeSize


