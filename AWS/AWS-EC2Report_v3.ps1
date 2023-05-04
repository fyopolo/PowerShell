<#

Param(
    [Parameter(Mandatory=$true,HelpMessage="Enter Access Key ")][string]$AccessKey,
    [Parameter(Mandatory=$true,HelpMessage="Enter Secret Access Key ")][string]$SecretAccessKey,
    [Parameter(Mandatory=$false,HelpMessage="Enter Session Token ")][string]$SessionToken
    )

#>

Import-Module AWSPowerShell

Clear-Host



Write-Host ""
Write-Host "Getting EC2 Instances..." -ForegroundColor Cyan
$Creds = Get-AWSCredential -ProfileName AWS-QBC
$EC2 = (Get-EC2Instance -Credential $Creds -Region us-east-1).Instances
# $Instances = $(Get-EC2Instance -AccessKey $AccessKey -SecretKey $SecretAccessKey -SessionToken $SessionToken).Instances
Write-Host ""
Write-Host "Getting Volumes..." -ForegroundColor Cyan
Write-Host ""
$Volumes = Get-EC2Volume -AccessKey $AccessKey -SecretKey $SecretAccessKey -SessionToken $SessionToken
Write-Host "Getting Snapshots..." -ForegroundColor Cyan
$Snapshots = Get-EC2Snapshot -AccessKey $AccessKey -SecretKey $SecretAccessKey -SessionToken $SessionToken

$EC2Instances = @()

foreach ($ItemIns in $Instances){

    # Get TAGS Index

    $Flag = 0
    $Tags = $ItemIns.Tags
    
    foreach ($Tag in $Tags){

        $Flag ++
        IF ($Tag.Key -eq "Customer Number") {$TagCNumber = $Flag -1}
        IF ($Tag.Key -eq "Customer Name") {$TagCName = $Flag -1}
        IF ($Tag.Key -eq "Name") {$TagName = $Flag -1}

    }
    
    # Processing Hash Table values

    $Disks = $($Volumes | Where-Object {$_.Attachments.InstanceId -eq $ItemIns.InstanceId})
    IF ($Disks.SnapshotId -gt 1) { $VolSnap = [string]::Join(", ", $Disks.SnapshotId) } ELSE { $VolSnap = $Disks.VolumeId }
    IF ($Disks.VolumeId -gt 1) { $VolID = [string]::Join(", ", $Disks.VolumeId) } ELSE { $VolID = $Disks.VolumeId }
    IF ($Disks.Attachments.Device -gt 1) { $DeviceName = [string]::Join(", ", $Disks.Attachments.Device) } ELSE { $DeviceName = $Disks.Attachments.Device }
    IF ($Disks.VolumeType.Value.Count -gt 1) { $VolType = [string]::Join(", ", $Disks.VolumeType.Value.ToUpper()) } ELSE { $VolType = $Disks.VolumeType.Value.ToUpper() }
    IF ($Disks.Iops.Count -gt 1) { $IOPS = [string]::Join(", ", $Disks.Iops) } ELSE { $IOPS = $Disks.Iops }
    IF ($ItemIns.SecurityGroups.Count -gt 1) { $SecGrp = [string]::Join(", ", $ItemIns.SecurityGroups.GroupName) } ELSE { $SecGrp = $ItemIns.SecurityGroups.GroupName }

    # Building Hash Table

    $HashEC2 = [ordered]@{
        InstanceName       = $ItemIns.Tag.Value.GetValue($TagName).ToUpper()
        KeyName            = $ItemIns.KeyName
        CustomerNumber     = ($ItemIns.Tag.Value.GetValue($TagCNumber)).ToUpper()
        CustomerName       = ($ItemIns.Tag.Value.GetValue($TagCName)).ToUpper()
        AvailabilityZone   = $ItemIns.Placement.AvailabilityZone
        Size               = $ItemIns.InstanceType.Value
        Platform           = $ItemIns.PlatformDetails
        State              = $ItemIns.State.Name.Value.ToUpper()
        Volumes            = $Disks.Count
        TotalStorageGB     = [int]($Disks.Size | Measure-Object -Sum).Sum
        VolumeType         = $VolType
        DeviceName         = $DeviceName
        DeviceType         = $ItemIns.RootDeviceType.Value.ToUpper()
        VolumeIOPS         = $IOPS
        VolumeID           = $VolID
        Snapshots          = $VolSnap
        PrivateIPv4Address = $ItemIns.PrivateIpAddress
        PublicIPv4Address  = $ItemIns.PublicIpAddress
        SecurityGroups     = $SecGrp
    }

    # Creating custom PS object out of Hash Table

    $NewOBJ = New-Object psobject -Property $HashEC2
    $EC2Instances += $NewOBJ
}

# FOR TROUBLESHOOTING: $EC2Instances | Sort InstanceName | Out-GridView


$StoppedEC2 = $EC2Instances | Where-Object {$_.State -eq "Stopped"}
$StoppedEC2Count = $StoppedEC2.Count
$StoppedEC2Storage = ($StoppedEC2.TotalStorageGB | Measure-Object -Sum).Sum


IF ($StoppedEC2Count -gt 0){

    Write-Host "Stopped EC2 Instances:" $StoppedEC2Count -ForegroundColor Yellow
    $StoppedEC2 | Sort InstanceName | ft -AutoSize
    Write-Host "Total storage for stopped instances (GB):" $StoppedEC2Storage -ForegroundColor Yellow
    Write-Host ""

}

# Getting Unattached Volumes

$Unattached = $Volumes | Where-Object {$_.Status -eq "Available"}
IF ($Unattached.Count -gt 0) {

    Write-Host "Unattached Volumes:" $($Unattached.Count) -ForegroundColor Cyan
    $Unattached | Select VolumeId, CreateTime, Iops, Size, State | Sort CreateTime -Descending | ft -AutoSize
    $UnattachedRpt = $Unattached
    } ELSE {
    Write-Host "All volumes are in use" -ForegroundColor Cyan
}


# FOR TROUBLESHOOTING: $Volumes | Out-GridView

# Processing SNAPSHOTS

$SnapshotsSTD = $Snapshots | Where-Object {$_.StorageTier -eq "standard"}
IF ($SnapshotsSTD) {

    $SnapSTD = @()
    $SnapSTDCount = $SnapshotsSTD.Count

    Write-Host "Processing" $SnapSTDCount "items. Please wait..." -ForegroundColor White

    foreach ($ItemSnapSTD in $SnapshotsSTD) {

        $DependentVolName = $Volumes | Where-Object {$ItemSnapSTD.Tags -in $_.Tags}
        $DependentEC2     = $EC2Instances | Where-Object {$ItemSnapSTD.VolumeId -in $_.VolumeId}
        $SnapshotTier1    = $ItemSnapSTD.StorageTier

        $HashSnapshotsSTD = [ordered]@{
            SnapshotTier     = $SnapshotTier1.Value.ToUpper()
            SnapshotId       = $ItemSnapSTD.SnapshotId
            TimeStamp        = $ItemSnapSTD.StartTime
            VolSizeGB        = $ItemSnapSTD.VolumeSize
            DependentVolId   = $ItemSnapSTD.VolumeId
            DependentVolName = $DependentVolName.Tags
            DependentEC2     = $DependentEC2.InstanceName
        }

    $NewOBJ = New-Object psobject -Property $HashSnapshotsSTD
    $SnapSTD += $NewOBJ 

    }
}

# FOR TROUBLESHOOTING: $SnapSTD | Out-GridView

# Archived Snapshots

$SnapshotsARCH = $Snapshots | Where-Object {$_.StorageTier -eq "archived"}
IF ($SnapshotsARCH) {
    
    $SnapARCH = @()
    $SnapARCHCount = $SnapshotsARCH.Count
    Write-Host "Processing" $SnapSARCHount "items. Please wait..." -ForegroundColor White

    foreach ($ItemSnapARCH in $SnapshotsARCH) {

       $DependentVolName = $Volumes | Where-Object {$ItemSnapARCH.Tags -in $_.Tags}
       $DependentEC2     = $EC2Instances | Where-Object {$ItemSnapARCH.VolumeId -in $_.VolumeId}
       $SnapshotTier2    = $ItemSnapARCH.StorageTier

       $HashSnapshotsARCH = [ordered]@{
            SnapshotTier            = $SnapshotTier2.Value.ToUpper()
            SnapshotId              = $ItemSnapARCH.SnapshotId
            TimeStamp               = $ItemSnapARCH.StartTime
            VolSizeGB               = $ItemSnapARCH.VolumeSize
            DependentVolId          = $ItemSnapARCH.VolumeId
            DependentVolName        = $DependentVolName.Tags
            SourceEC2InstanceName   = $DependentEC2.InstanceName
        }

    $NewOBJ = New-Object psobject -Property $HashSnapshotsARCH
    $SnapARCH += $NewOBJ 

    }
}

# FOR TROUBLESHOOTING: $SnapARCH | Out-GridView

# Summary Table

$SummaryTable = @()

$HashSummaryTable =  [ordered]@{
    EC2Instances        = $EC2Instances.Count
    SnapshotSTDCount    = IF ($SnapSTDCount -gt 0) {$SnapSTDCount} ELSE {0}
    SnapshotSTDSizeGB   = ($SnapSTD.VolSizeGB | Measure-Object -Sum).Sum
    SnapshotARCHCount   = IF ($SnapARCHCount -gt 0) {$SnapARCHCount} ELSE {0}
    SnapshotARCHSizeGB  = ($SnapARCH.VolSizeGB | Measure-Object -Sum).Sum
}

$NewOBJ = New-Object psobject -Property $HashSummaryTable
$SummaryTable = $NewOBJ

# FOR TROUBLESHOOTING: $SummaryTable | Out-GridView

####################
#  Building Report #
####################

$FilePath = "C:\TEMP\ITX-Prod-AWS.xlsx"

# SUMMARY Tab

$TitleRpt          = "ITX AWS Production Report"
$TitleEC2RUN       = "EC2 Running Instances"
$TitleEC2STOP      = "EC2 Stopped Instances"
$TitleEC2STOPSize  = "Total SizeGB Stopped EC2"
$TitleSSTD         = "Standard Snapshots"
$TitleSSTDSize     = "Total SizeGB Snapshots Standard"
$TitleSARCH        = "Archived Snapshots"
$TitleSARCHSize    = "Totall SizeGB Archived Snapshots"
$TitleVolumesAT    = "Volumes Attached"
$TitleVolumesUN    = "Volumes Unttached"

Export-Excel -Path $FilePath -StartRow 1 -Title $TitleRpt -WorksheetName "Summary" -TitleBold -TitleSize 20

# EC2 Instances Detail
Export-Excel -Path $FilePath -StartRow 5 -StartColumn 1 -InputObject $TitleEC2RUN -WorksheetName "Summary" -Append
Export-Excel -Path $FilePath -StartRow 5 -StartColumn 2 -InputObject $SummaryTable.EC2Instances  -WorksheetName "Summary" -Numberformat '#,##0' -Append

# Stopped EC2 Detail
Export-Excel -Path $FilePath -StartRow 5 -StartColumn 1 -InputObject $TitleEC2STOP -WorksheetName "Summary" -Append
Export-Excel -Path $FilePath -StartRow 5 -StartColumn 2 -InputObject $StoppedEC2Count -WorksheetName "Summary" -Numberformat '#,##0' -Append
Export-Excel -Path $FilePath -StartRow 6 -StartColumn 1 -InputObject $TitleEC2STOPSize -WorksheetName "Summary" -Append
Export-Excel -Path $FilePath -StartRow 6 -StartColumn 2 -InputObject $StoppedEC2Storage -WorksheetName "Summary" -Numberformat '#,##0' -Append

# Snapshots Detail
Export-Excel -Path $FilePath -StartRow 7 -StartColumn 1 -InputObject $TitleSSTD -WorksheetName "Summary" -Append
Export-Excel -Path $FilePath -StartRow 7 -StartColumn 2 -InputObject $SummaryTable.SnapshotSTDCount -WorksheetName "Summary" -Numberformat '#,##0' -Append
Export-Excel -Path $FilePath -StartRow 8 -StartColumn 1 -InputObject $TitleSSTDSize -WorksheetName "Summary" -Append
Export-Excel -Path $FilePath -StartRow 8 -StartColumn 2 -InputObject $SummaryTable.SnapshotSTDSizeGB -WorksheetName "Summary" -Numberformat '#,##0' -Append
Export-Excel -Path $FilePath -StartRow 9 -StartColumn 1 -InputObject $TitleSARCH -WorksheetName "Summary" -Append
Export-Excel -Path $FilePath -StartRow 9 -StartColumn 2 -InputObject $SummaryTable.SnapshotARCHCount  -WorksheetName "Summary" -Numberformat '#,##0' -Append
Export-Excel -Path $FilePath -StartRow 10 -StartColumn 1 -InputObject $TitleSARCHSize -WorksheetName "Summary" -Append
Export-Excel -Path $FilePath -StartRow 10 -StartColumn 2 -InputObject $SummaryTable.SnapshotARCHSizeGB  -WorksheetName "Summary" -Numberformat '#,##0' -Append

# Other Tabs

$EC2Instances | Export-Excel -Path $FilePath -Title "EC2 Running Instances" -TitleSize 24 -TitleBold -AutoSize -AutoFilter -WorksheetName "EC2 Instances" -Append
$Volumes | Select VolumeId, Size, Iops, VolumeType, State, Attachment, SnapshotId, AvailabilityZone, CreateTime, Progress, Encrypted | Export-Excel -Path $FilePath -Title "VOLUMES" -TitleSize 24 -TitleBold -AutoSize -AutoFilter -WorksheetName "Volumes" -Append
$Snapshots | Select -Property SnapshotId, StorageTier, Progress, State, Description, @{n="CreateTime";e={$_.StartTime}}, Encrypted, OwnerId, VolumeId, VolumeSize | Export-Excel -Path $FilePath -Title "SNAPSHOTS" -TitleSize 24 -TitleBold -AutoSize -AutoFilter -WorksheetName "Snapshots" -Append


# $Snapshots | Select SnapshotId, StorageTier, Progress, State, Description, @{n="CreateTime";e={$_.StartTime}}, Encrypted, OwnerId, VolumeId, VolumeSize | Out-GridView



# $Snapshots | Select SnapshotId, @{n="Tier";e={$_.StorageTier.ToUpper()}}, Progress, State, Description, @{n="CreateTime";e={$_.StartTime}}, Encrypted, OwnerId, VolumeId, VolumeSize -First 3 | Sort CreateTime -Descending | Out-GridView

