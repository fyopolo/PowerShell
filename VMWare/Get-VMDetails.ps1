# -------------------------------------------------------------------------------
# Script: Get-VMDetails.ps1
# Author: Fernando Yopolo
# Date: 04/01/2020
# Keywords: VMware
# Comments: Gather VMware environment details and generate an HTML report
#
# Versioning
# 04/01/2020  Initial Script
# -------------------------------------------------------------------------------

Function Save-RPTFile($initialDirectory) {  
    [System.Reflection.Assembly]::LoadWithPartialName(“System.windows.forms”) | Out-Null

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.Title = "Select SKU File"
    $OpenFileDialog.Filter = “Excel Files (*.xlsx)| *.xlsx”
    $Button = $OpenFileDialog.ShowDialog()
    $OpenFileDialog.FileName | Out-Null
    IF ($Button -eq "OK") { Return $OpenFileDialog.FileName }
    ELSE { Write-Error "Operation cancelled by user. Aborting script execution."; Break }
}

Function Select-Folder { 
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $OpenFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog

    $Topmost = New-Object System.Windows.Forms.Form
    $Topmost.TopMost = $True
    $Topmost.MinimizeBox = $True

    $OpenFolderDialog.ShowNewFolderButton = $True
    $OpenFolderDialog.Rootfolder = "Desktop"
    $OpenFolderDialog.Description = "Select Folder in where to store HTML result file"
    $Button = $OpenFolderDialog.ShowDialog($Topmost)
    IF ($Button -eq "OK") { Return $OpenFolderDialog.SelectedPath }
    ELSE { Write-Error "Operation cancelled by user. Aborting script execution"; Break }
}

Function Create-Report {
    $OutputFolder = Select-FolderDialog
    $rptFile = $OutputFolder + "\" + "SMTP-Report-" + "$TenantDefaultDomain" + ".htm"
    $rpt | Set-Content -Path $rptFile -Force
    Invoke-Item $rptFile
    Start-Sleep 1
}

Clear-Host

$LogFile = "C:\TEMP\VMware-Report.log"

# Start-Transcript -IncludeInvocationHeader -LiteralPath $LogFile -Verbose

# $ServerConn = Read-Host "IP Address or Host Name"
# $Credentials = Get-Credential
# Connect-VIServer -Server $ServerConn -Credential $Credentials -Force

$VMs = Get-VM

$VmsDetails = @()
$VmDisks = @()
$VmOSVolume = @()
$VmOSCapacityGB = @()
$VmOSFreeSpaceGB = @()
$VmOSUsedSpaceGB = @()
$VmOSPercentFree = @()

foreach ($vm in $VMs){
 $view = Get-View $vm
   foreach ($item in $vm) {
        $VmOSVolume      = $null
        $VmOSCapacityGB  = $null
        $VmOSUsedSpaceGB = $null
        $VmOSFreeSpaceGB = $null
        $VmOSPercentFree = $null
        $VmDisks = $item.Guest.Disks | Sort Path

        foreach($VAR1 in $VmDisks){
            $VmOSVolume += "$($VAR1.Path)`r`n"
            $VmOSCapacityGB1   = [int]$VAR1.CapacityGB; $VmOSCapacityGB2 = "{0:N0} GB" -f $VmOSFreeGB1; $VmOSCapacityGB  += "$($VmOSCapacityGB2)`r`n"
            $VmOSFreeGB1       = [int]$VAR1.FreeSpaceGB; $VmOSFreeGB2 = "{0:N0} GB" -f $VmOSFreeGB1; $VmOSFreeSpaceGB  += "$($VmOSFreeGB2)`r`n"
            $VmOSUsedGB1       = (([int]$VAR1.CapacityGB) - ([int]$VAR1.FreeSpaceGB)); $VmOSUsedGB2 = "{0:N0} GB" -f $VmOSUsedGB1; $VmOSUsedSpaceGB  += "$($VmOSUsedGB2)`r`n"
            $VmOSPercent1      = ([int]$VAR1.FreeSpaceGB * 100) / ([int]$VAR1.CapacityGB); $VmOSPercent2 = "{0:N0} %" -f $VmOSPercent1; $VmOSPercentFree  += "$($VmOSPercent2)`r`n"
        }
        
        IF ($view.config.hardware.Device.Backing.ThinProvisioned -eq $true){
            $Hash = [ordered]@{
              VMName              = $item.Name
              DNSName             = $item.Guest.HostName
              State               = $item.PowerState
              BootTime            = $view.Runtime.BootTime
              HARestartPriority   = $item.HARestartPriority
              ESXServer           = $item.VMHost.Name
              IPAddress           = $item.Guest.IPAddress
              RAM                 = "{0:N0} GB" -f $item.MemoryGB
              Provisioned         = "{0:N0} GB" -f [math]::round(($view.config.hardware.Device | Measure-Object CapacityInKB -Sum).sum/1048576,2)
              Volume              = $VmOSVolume
              VolumeSize          = $VmOSCapacityGB
              VolumeUsed          = $VmOSUsedSpaceGB
              VolumeFree          = $VmOSFreeSpaceGB
              VolPerFree          = $VmOSPercentFree
              VMDK                = $view.config.hardware.Device.Backing.FileName
              DiskMode            = $view.config.hardware.Device.Backing.DiskMode
              Thin                = $view.config.hardware.Device.Backing.ThinProvisioned
          }

       $NewObject = New-Object psobject -Property $Hash
       $VmsDetails += $NewObject

       }
   }
}
$VmsDetails | Sort VMName | Out-GridView

# Get-AdvancedSetting -Entity $item | Select Description, Entity, Id, Name, Type, Uid, Value | Out-GridView

# (Get-AdvancedSetting -Entity $item).Id

$ClusterInfo = Get-Cluster
$DatacenterInfo = Get-Datacenter

$VMDisks = Get-HardDisk -VM EALEXCH1 | Select Name, DiskType, Persistence, StorageFormat, FileName | Out-GridView
$VMNetwork = Get-NetworkAdapter -VM EALEXCH1 | Select Name, NetworkName, Type, ConnectionState
$vSwitch = Get-VirtualSwitch | Select Name, Nic, VMHost

$LUN = Get-VMHost | Get-ScsiLun
$LUN  | Select CapacityGB, IsLocal, IsSsd, LunType, Model, MultipathPolicy, SerialNumber, Vendor, VMHost, VMHostId, VsanStatus | Out-GridView


$ESXiNetInfo = Get-VMHostNetwork (Get-VMHost | select -First 1) | Select HostName, DomainName, DnsFromDhcp, DnsAddress, IPv6Enabled, SearchDomain

$VMHost = Get-VMHost
foreach ($Server in $VMHost){
    Get-VMHostHardware -VMHost $Server.Name -SkipAllSslCertificateChecks #| Select VMHost, Manufacturer, Model, SerialNumber, AssetTag, CpuModel, CpuCoreCountTotal, MhzPerCpu, NicCount, MemoryModules, MemorySlotCount, PowerSupplies

    $Hash =  [ordered]@{
        ServerName             =    $Server.Name
        A = $Server.ConnectionState
        NTP = $Server.ExtensionData.Config.DateTimeInfo.NtpConfig.Server
        FaultToleranceVersion = $Server.ExtensionData.Config.FeatureVersion
        FirewallRules = $Server.ExtensionData.Config.Firewall.Ruleset
        HyperThreading = $Server.HyperthreadingActive
        DNSConfig = $Server.ExtensionData.Config.Network.DnsConfig
        DefaultGateway = $Server.ExtensionData.Config.Network.IpRouteConfig.DefaultGateway
        IPv6Enabled = $Server.ExtensionData.Config.Network.IpV6Enabled
        PhysicalNICs = $Server.ExtensionData.Config.Network.Pnic.Device
        vSwitchName = $Server.ExtensionData.Config.Network.Vswitch.Name
        vSwitchPortGroup = ($Server.ExtensionData.Config.Network.Vswitch.Portgroup).TrimStart("key-vim.host.PortGroup-")
        Product = $Server.ExtensionData.Config.Product
        ServicesRunning = ($Server.ExtensionData.Config.Service.Service).Where({$_.Running -eq "True"})
        
        # Storage
        
        StorageAdapters = $Server.ExtensionData.Config.StorageDevice.HostBusAdapter | Select Model, IScsiName
        Name = $Server.ExtensionData.Config.StorageDevice.ScsiLun.DisplayName
        SSD = $Server.ExtensionData.Config.StorageDevice.ScsiLun.Ssd
        LunType = $Server.ExtensionData.Config.StorageDevice.ScsiLun.LunType
        Model = $Server.ExtensionData.Config.StorageDevice.ScsiLun.Model
        ScsiLevel = $Server.ExtensionData.Config.StorageDevice.ScsiLun.ScsiLevel
        BlockSize = $Server.ExtensionData.Config.StorageDevice.ScsiLun.Capacity.BlockSize
        
        CPUAllocation = $Server.ExtensionData.Config.SystemResources.Config.CpuAllocation
        RAMAllocation = $Server.ExtensionData.Config.SystemResources.Config.MemoryAllocation

        Vmotion = $Server.ExtensionData.Summary.Config.VmotionEnabled
        FaultTolerance = $Server.ExtensionData.Summary.Config.FaultToleranceEnabled
        FeatureVersion = $Server.ExtensionData.Summary.Config.FeatureVersion.Value

        ProcessorSockets = $Server.ExtensionData.Hardware.CpuInfo.NumCpuPackages
        CPUCores = $Server.ExtensionData.Hardware.CpuInfo.NumCpuCores
        LogicalProcessors = $Server.ExtensionData.Hardware.CpuInfo.NumCpuThreads
        
        ProcessorInfo = $Server.ExtensionData.Hardware.CpuPkg

        BootTime = $Server.ExtensionData.Runtime.BootTime

        NICS = $Server.ExtensionData.Summary.Hardware.NumNics
        
        
    }
  
#    $MBXObject = New-Object psobject -Property $Hash
#    $Mailboxes += $MBXObject

}

Get-VMHostImageProfile -Entity (Get-VMHost | select -First 1)

#     Storage Section

$DataStores = Get-Datastore

$DSCustom = @()
foreach($ESX in $VMHost){
    foreach ($DS in $DataStores){
        $CapacityGB = [math]::round($DS.CapacityGB , 2)
        $FreeSpaceGB = [math]::round($DS.FreeSpaceGB , 2)
        $Hash =  [ordered]@{
            ESX                =  ($ESX.Name).ToUpper()
            Name               =  $DS.Name
            State              =  $DS.State
            Type               =  $DS.Type
            BlockSizeMB        =  $DS.ExtensionData.Info.Vmfs.BlockSizeMb
            MaxFileSize        =  $DS.ExtensionData.Info.MaxFileSize
            CapacityGB         =  $CapacityGB
            UsedGB             =  $CapacityGB - $FreeSpaceGB
            FreeSpaceGB        =  $FreeSpaceGB
            FileSystemVersion  =  $DS.FileSystemVersion
            Server             =  $($DS.RemoteHost)
            Folder             =  $DS.RemotePath
        }
    
        $NewObject = New-Object psobject -Property $Hash
        $DSCustom += $NewObject
    }
}

$DSCustom | Sort ESX,Name | Out-GridView

#     Storage Adapters Section

$SAdapter = @()
foreach($ESXHost in $VMHost){
    $StorageAdapters = Get-VMHostHba -VMHost $ESXHost.Name #| Select VMHost, Device, Driver, Type, Model, Name, Status, CurrentSpeedMb, ScsiLunUids, IScsiAlias, ISciName
    foreach ($Adapter in $StorageAdapters){
    $Hash =  [ordered]@{
            ESX                =  $ESXHost.Name
            Device             =  $Adapter.Device
            Type               =  $Adapter.Type
            WWN                =  $Adapter.IScsiName
            Status             =  $Adapter.Status
            Model              =  $Adapter.Model
            Name2              =  $Adapter.Name
            SpeedMB            =  $Adapter.CurrentSpeedMb
            ScsiLunUids        =  $Adapter.ScsiLunUids
            IScsiAlias         =  $Adapter.IScsiAlias
    }
    }
    $Adapter | fl
        $NewObject = New-Object psobject -Property $Hash
        $SAdapter += $NewObject
}

$SAdapter | Out-GridView

#     XXX Section
Get-HAPrimaryVMHost

Get-Cluster | Get-HAPrimaryVMHost

$Inventory = Get-Inventory
$Inventory | Sort-Object Type | ft -AutoSize

$Inventory.Where($Type -eq "VirtualMachine")

(Get-Datacenter | Get-Inventory).Count

$HBAInfo = Get-IScsiHbaTarget | Select Address, IScsiHbaName, IScsiName, Port, Type, VmHostId | ft -AutoSize


#Get-VM | gm

#$view.Config.Hardware.Device.Backing.ThinProvisioned

<#

Disconnect-VIServer -Server $Server

#############################
### CREATING HTML REPORT  ###
#############################

$Step++
Write-Progress -Id 0 -Activity $Task -Status "Step $Step of $TotalSteps" -CurrentOperation "Creating HTML Report. Please stand by..." -PercentComplete ($Step / $TotalSteps * 100)

$rpt += Get-HtmlOpenPage -TitleText "VMware Report for " -LeftLogoString "https://ownakoa.com/wp-content/uploads/2016/09/TeamLogic-IT-Logo.png"

##    TABS DEFINITIONS

$TABarray = @('Hosts','Virtual Machines','Network','Storage')
$rpt += Get-HTMLTabHeader -TabNames $TABarray


## =======   OPENING TAB: LICENSING  ======= ##


$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(0) -Tabheading (" ")
$rpt += Get-HTMLTabContentClose ## CLOSING TAB


## =======  OPENING TAB: MAILBOXES  ======= ##


$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(1) -Tabheading (" ")
$rpt += Get-HTMLTabContentClose ## CLOSING TAB


## =======  OPENING TAB: DISTRIBUTION LISTS  ======= ##


$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(2) -Tabheading (" ")
$rpt += Get-HTMLTabContentClose ## CLOSING TAB


## =======  OPENING TAB: OFFICE 365 GROUPS  ======= ##


$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(3) -Tabheading (" ")
$rpt += Get-HTMLTabContentClose ## CLOSING TAB


## =======  OPENING TAB: MAIL CONTACTS  ======= ##


$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(4) -Tabheading (" ")
$rpt += Get-HTMLTabContentClose ## CLOSING TAB


## =======  OPENING TAB: EXTENDED PERISSIONS  ======= ##


$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(5) -Tabheading (" ")
$rpt += Get-HTMLTabContentClose ## CLOSING TAB


## =======  OPENING TAB: OTHER RECIPIENTS  ======= ##


$rpt += Get-HTMLTabContentOpen -TabName $TABarray.Item(6) -Tabheading (" ")
$rpt += Get-HTMLTabContentClose ## CLOSING TAB

$rpt += Get-HTMLClosePage -FooterText "Fernando Yopolo // fyopolo@homail.com // Year $((Get-Date).Year)" ##    CLOSING HTML REPORT

Write-Progress -Id 0 -Activity $Task -Completed

#>





Get-View -ViewType HostSystem | Sort Name |

Select Name,

@{N="Serial number";E={($_.Hardware.SystemInfo.OtherIdentifyingInfo | where {$_.IdentifierType.Key -eq "ServiceTag"}).IdentifierValue}},

@{N="OS Version";E={$_.Config.Product.Version + " - Build " + $_.Config.Product.Build}},

@{N="Type";E={$_.Hardware.SystemInfo.Vendor + " " + $_.Hardware.SystemInfo.Model}},

@{N="BIOS version";E={$_.Hardware.BiosInfo.BiosVersion}},

@{N="BIOS Date";E={$_.Hardware.BiosInfo.releaseDate}},

@{N="IP Address";E={($_.Config.Network.Vnic | ? {$_.Device -eq "vmk0"}).Spec.Ip.IpAddress}},

@{N="Datacenter";E={Get-Datacenter -VMHost $_.Name}},

@{N="ImageProfile";E={(Get-EsxCli -VMHost $_.Name).software.profile.get() | Select -ExpandProperty Name}} | Out-GridView

$ESCLI = Get-EsxCli -VMHost (Get-VMHost | select -First 1)

$ESCLI.software.profile.get().Name
