
Param(
    [Parameter(Mandatory=$true,HelpMessage="Enter Access Key ")][string]$AccessKey,
    [Parameter(Mandatory=$true,HelpMessage="Enter Secret Access Key ")][string]$SecretAccessKey,
    [Parameter(Mandatory=$true,HelpMessage="Enter Session Token ")][string]$SessionToken
    )

Import-Module AWSPowerShell

Clear-Host

$Instances = $(Get-EC2Instance -AccessKey $AccessKey -SecretKey $SecretAccessKey -SessionToken $SessionToken).Instances
$Volumes = Get-EC2Volume -AccessKey $AccessKey -SecretKey $SecretAccessKey -SessionToken $SessionToken

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

    $Hash =  [ordered]@{
        InstanceName       = $Item.Tag.Value.GetValue($TagIndex).ToUpper()
        AvailabilityZone   = $Item.Placement.AvailabilityZone
        Size               = $Item.InstanceType.Value
        Platform           = $Item.PlatformDetails
        State              = $Item.State.Name.Value
        Volumes            = $Disks.Count
        TotalStorageGB     = [int]($Disks.Size | Measure-Object -Sum).Sum
        VolumeType         = $Disks.VolumeType.Value.ToUpper()
        DeviceName         = $Disks.Attachments.Device
        DeviceType         = $Item.RootDeviceType.Value.ToUpper()
        VolumeIOPS         = $Disks.Iops
        Snapshots          = $Disks.SnapshotId
        PrivateIPv4Address = $Item.PrivateIpAddress
        PublicIPv4Address  = $Item.PublicIpAddress
        SecurityGroups     = $Item.SecurityGroups.GroupName
    }

    $NewOBJ = New-Object psobject -Property $Hash
    $EC2Instances += $NewOBJ
}

$EC2Instances | Sort InstanceName | Out-GridView
$EC2Instances | Export-Excel -Path C:\TEMP\ITX-Prod-EC2.xlsx -Title "ITX Production EC2 Instances Report" -TitleSize 24 -TitleBold -AutoSize -AutoFilter

$StoppedEC2 = $EC2Instances | Where-Object {$_.State -eq "Stopped"}
$StoppedEC2Storage = ($StoppedEC2.TotalStorageGB | Measure-Object -Sum).Sum

Write-Host "Stopped EC2 Instances:" $StoppedEC2.Count -ForegroundColor Yellow
Write-Host ""
Write-Host "Total storage for stopped instances (GB):" $StoppedEC2Storage -ForegroundColor Yellow
Write-Host ""
Write-Host "Unattached Volumes" -ForegroundColor Cyan
$Volumes | Where-Object {$_.Status -eq "Available"} | Select VolumeId, CreateTime, Iops, Size, State | ft -AutoSize