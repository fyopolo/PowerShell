# -------------------------------------------------------------------------------
# Script: AWS-EC2Report.ps1
# Author: Fernando Yopolo
# Date: 02/02/2022
# Keywords: AWS
# Comments: Gather AWS details and output to XLSX.
#
# Requirements:
#      - PowerShell V3.0
#      - AWSPowerShell Module and AWS CLI
#      - ImportExcel Module
#
# Versioning
# 02/02/2022  Initial Script
# 02/06/2022  Improved report by adding tabs to XLSX file.
# 00/00/2022  Added support for handling local profiles (AWS Cli) and STS Keys
# -------------------------------------------------------------------------------

<#
.SYNOPSIS
    This script was creatd by Fernando Yopolo.


.DESCRIPTION
    The script gathers information and output it for Microsoft Excel.



.NOTES
    Author: Fernando Yopolo
    Date:   02/02/2022
    Version: 1.0 - Initial release


.Examples:

If you want to manually state STS values use:
     
     AWS-EC2Report.ps1 -AccessKey <Access Key ID> -SecretKey <Secret Access Key> -Token <Session Token>

If you don't specify any parameter then script will:
    - Scan for any AWS profile (using AWS CLI commands) and it will prompt you which one you'd like to use for connecting.
    - If no profiles are found (because you didn't create any or because AWS CLI is not installed) then STS values will be prompted.
    - Session Token is not always required so it will be prompted but may not be used for queries (behavior controlled by a Try/Catch script block).


#>


$ErrorActionPreference = 'SilentlyContinue'

<#

Param(
    [Parameter(Mandatory=$true,HelpMessage="Enter Access Key ")][string]$AccessKey,
    [Parameter(Mandatory=$true,HelpMessage="Enter Secret Access Key ")][string]$SecretAccessKey,
    [Parameter(Mandatory=$false,HelpMessage="Enter Session Token ")][string]$SessionToken
    )

#>

Clear-Host

Write-Host ""
Write-Host "Getting EC2 Instances..." -ForegroundColor Cyan
$Creds = Get-AWSCredential -ProfileName AWS-QBC
$EC2 = (Get-EC2Instance -Credential $Creds -Region us-east-1).Instances
Write-Host ""
Write-Host "Getting Volumes..." -ForegroundColor Cyan
Write-Host ""
$Volumes = Get-EC2Volume -Credential $Creds -Region us-east-1
Write-Host "Getting Snapshots..." -ForegroundColor Cyan
$Snapshots = Get-EC2Snapshot -Credential $Creds -Region us-east-1

### Processing EC2 Instances ###

Write-Host "Processing EC2 Instances..." -BackgroundColor Blue

$EC2Instances = @()
$PBarCounter = 0

foreach ($ItemIns in $EC2){

    $PBarCounter ++
    $PBarPercent = $PBarCounter / $EC2.Count * 100
    Write-Progress -Activity "Processing $($EC2.Count) EC2 Instances" -Status ($ItemIns.KeyName) -PercentComplete $PBarPercent

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
        InstanceId         = $ItemIns.InstanceId
        CustomerNumber     = ($ItemIns.Tag.Value.GetValue($TagCNumber)).ToUpper()
        CustomerName       = ($ItemIns.Tag.Value.GetValue($TagCName)).ToUpper()
        AvailabilityZone   = $ItemIns.Placement.AvailabilityZone
        Size               = $ItemIns.InstanceType.Value
        Platform           = $ItemIns.PlatformDetails
        State              = $ItemIns.State.Name.Value.ToUpper()
        PrivateIPv4Address = $ItemIns.PrivateIpAddress
        PublicIPv4Address  = $ItemIns.PublicIpAddress
        Volumes            = $Disks.Count
        TotalStorageGB     = [int]($Disks.Size | Measure-Object -Sum).Sum
        VolumeType         = $VolType
        DeviceName         = $DeviceName
        DeviceType         = $ItemIns.RootDeviceType.Value.ToUpper()
        VolumeIOPS         = $IOPS
        VolumeID           = $VolID
        Snapshots          = $VolSnap
        SecurityGroups     = $SecGrp
    }

    # Creating custom PS object out of Hash Table

    $NewOBJ = New-Object psobject -Property $HashEC2
    $EC2Instances += $NewOBJ
}

# FOR TROUBLESHOOTING: $EC2Instances | Sort InstanceName | Out-GridView

Write-Host "Processing Stopped EC2 Instances..." -BackgroundColor Blue

$StoppedEC2 = $EC2Instances | Where-Object {$_.State -eq "Stopped"}
$StoppedEC2Count = $StoppedEC2.Count
$StoppedEC2Storage = ($StoppedEC2.TotalStorageGB | Measure-Object -Sum).Sum


IF ($StoppedEC2Count -gt 0){

    Write-Host "Stopped EC2 Instances:" $StoppedEC2Count -ForegroundColor Yellow
    $StoppedEC2 | Sort InstanceName | ft -AutoSize
    Write-Host "Total storage for stopped instances (GB):" $StoppedEC2Storage -ForegroundColor Yellow
    Write-Host ""

}


### Processing Volumes ###

Write-Host "Processing Volumes..." -BackgroundColor Blue

$EC2Vols = @()
$PBarCounter = 0

foreach ($ItemVol in $Volumes){

    $PBarCounter ++
    $PBarPercent = $PBarCounter / $Volumes.Count * 100
    Write-Progress -Activity "Processing $($Volumes.Count) Volumes" -Status ($ItemVol.VolumeId) -PercentComplete $PBarPercent

    # Get TAGS Index

    $Flag = 0
    $Tags = $ItemVol.Tags

    foreach ($Tag in $Tags){

        $Flag ++
        IF ($Tag.Key -eq "Snapshot") {$TagSnap = $Flag -1}
        IF ($Tag.Key -eq "LastBackup") {$TagSnapBkp = $Flag -1}
        IF ($Tag.Key -eq "Customer Name") {$TagCusName = $Flag -1} ELSE { "" }
        IF ($Tag.Key -eq "Name") {$TagVolName = $Flag -1}

    }

    $AttachedEC2 = ($EC2Instances | Where-Object {$_.InstanceId -eq $ItemVol.Attachment.InstanceId}).InstanceName
    # $TagName = IF ($ItemVol.Tags.Key -eq "Name") {$ItemVol.Tags.Value}

    $HashVol = [ordered]@{
        VolumeName       = $ItemVol.Tag.Value.GetValue($TagVolName).ToUpper()
        VolumeId         = $ItemVol.VolumeId
        CreateTime       = $ItemVol.CreateTime
        Size             = $ItemVol.Size
        IOPs             = $ItemVol.Iops
        VolumeType       = $ItemVol.VolumeType.Value.ToUpper()
        Attached         = IF ($ItemVol.Status -eq "Available") {"NO"} ELSE {"Yes"}
        AttachedTo       = $AttachedEC2
        AvailabilityZone = $ItemVol.AvailabilityZone
        Encrypted        = $ItemVol.Encrypted
        Snapshot         = $ItemVol.Tag.Value.GetValue($TagSnap)
        CustomerName     = $ItemVol.Tag.Value.GetValue($TagCusName)
        LastBackup       = $ItemVol.Tag.Value.GetValue($TagSnapBkp)
    }

    # Creating custom PS object out of Hash Table

    $NewOBJ = New-Object psobject -Property $HashVol
    $EC2Vols += $NewOBJ

}

# FOR TROUBLESHOOTING: $EC2Vols | Sort VolumeName | Out-GridView

### Getting Unattached Volumes ###

$VolUnattached = $Volumes | Where-Object {$_.Status -eq "Available"}
IF ($VolUnattached.Count -gt 0) {

    Write-Host ""
    Write-Host "Unattached Volumes:" $($VolUnattached.Count) -ForegroundColor Cyan
    $VolUnattached | Select VolumeId, CreateTime, Iops, Size, State | Sort CreateTime -Descending | ft -AutoSize
    $VolUnattachedRpt = $VolUnattached
    } ELSE {
    Write-Host "All volumes are in use" -ForegroundColor Cyan
}


# FOR TROUBLESHOOTING: $Volumes | Out-GridView

### Processing SNAPSHOTS ###

Write-Host "Processing Snapshots..." -BackgroundColor Blue

# $SnapshotsSTD = ($Snapshots | Where-Object {$_.StorageTier -eq "standard"}).Count
# $SnapshotsARCH = ($Snapshots | Where-Object {$_.StorageTier -eq "archived"}).Count

Write-Host $Snapshots.Count "snapshots found. Please wait while processing..." -ForegroundColor White

$SnapTable = @()
$PBarCounter = 0

foreach ($ItemSnapshot in $Snapshots) {

    $PBarCounter ++
    $PBarPercent = $PBarCounter / $Snapshots.Count * 100
    Write-Progress -Activity "Processing $($Snapshots.Count) Snapshots" -Status ($ItemSnapshot.SnapshotId) -PercentComplete $PBarPercent

    # Get TAGS Index

#    $Flag = 0
#    $Tags = $SnapTable.Tags

#   foreach ($Tag in $Tags){

#        $Flag ++
#        IF ($Tag.Key -eq "Name") {$TagSnapName = $Flag -1}

#    }

    $SnapshotName = IF ($ItemSnapshot.Tags.Key -eq "Name") {$ItemSnapshot.Tags.Value}
    $StorageTier   = $ItemSnapshot.StorageTier    
    $ParentVName = ($EC2Vols | Where-Object {$_.VolumeId -eq $ItemSnapshot.VolumeId})
    $AttachedEC2Name = ($EC2Vols | Where-Object {$_.VolumeId -eq $ItemSnapshot.VolumeId})
        
    $HashSnapshotsSTD = [ordered]@{
        StorageTier      = $StorageTier.Value.ToUpper()
        Name             = $SnapshotName
        Description      = $ItemSnapshot.Description
        SnapshotId       = $ItemSnapshot.SnapshotId
        SizeGB           = $ItemSnapshot.VolumeSize
        WhenCreated      = $ItemSnapshot.StartTime
        Encrypted        = $ItemSnapshot.Encrypted
        Progress         = $ItemSnapshot.Progress
        ParentVolumeId   = $ItemSnapshot.VolumeId
        ParentVolName    = $ParentVName.VolumeName
        AssociatedEC2    = $AttachedEC2Name.AttachedTo
    }

    $NewOBJ = New-Object psobject -Property $HashSnapshotsSTD
    $SnapTable += $NewOBJ
}

# FOR TROUBLESHOOTING: $SnapTable | Select -Last 10 | Out-GridView

# Summary Table

Write-Host "Processing Summary Table..." -BackgroundColor Blue

$SummaryTable = @()

$HashSummaryTable =  [ordered]@{
    EC2Instances        = $EC2Instances.Count
    SnapshotSTDCount    = IF (($SnapTable | Where-Object {$_.StorageTier -eq "standard"}).Count -gt 0) { $SnapTable.Count } ELSE {0}
    SnapshotSTDSizeGB   = (($SnapTable | Where-Object {$_.StorageTier -eq "standard"}).SizeGB | Measure-Object -Sum).Sum
    SnapshotARCHCount   = IF (($SnapTable | Where-Object {$_.StorageTier -eq "standard"}).Count -gt 0) { $SnapTable.Count } ELSE {0}
    SnapshotARCHSizeGB  = (($SnapTable | Where-Object {$_.StorageTier -eq "archived"}).SizeGB | Measure-Object -Sum).Sum
}

$NewOBJ = New-Object psobject -Property $HashSummaryTable
$SummaryTable = $NewOBJ

# FOR TROUBLESHOOTING: $SummaryTable | Out-GridView

####################
#  Building Report #
####################

Write-Host "Building Report..." -BackgroundColor Blue

$FilePath = "C:\TEMP\ITX-Prod-AWS.xlsx"

# SUMMARY Tab

$TitleRpt          = "ITX AWS Production Report"
$TitleEC2RUN       = "EC2 Running Instances"
$TitleEC2STOP      = "EC2 Stopped Instances"
$TitleEC2STOPSize  = "Total SizeGB Stopped EC2"
$TitleSSTD         = "Standard Snapshots"
$TitleSSTDSize     = "Total SizeGB Snapshots Standard"
$TitleSARCH        = "Archived Snapshots"
$TitleSARCHSize    = "Total SizeGB Archived Snapshots"
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

$EC2Instances | Export-Excel -Path $FilePath -Title "EC2 Instances: $($EC2Instances.Count)" -TitleSize 24 -TitleBold -AutoSize -AutoFilter -WorksheetName "EC2 Instances" -Append
$EC2Vols | Export-Excel -Path $FilePath -Title "Volumes: $($EC2Vols.Count) " -TitleSize 24 -TitleBold -AutoSize -AutoFilter -WorksheetName "Volumes" -Append
$SnapTable | Export-Excel -Path $FilePath -Title "Snapshots: $($Snapshots.Count)" -TitleSize 24 -TitleBold -AutoSize -AutoFilter -WorksheetName "Snapshots" -Append

