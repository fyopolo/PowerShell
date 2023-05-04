$VMs = Get-VM -ComputerName (Get-ClusterNode)

$Array = @()

foreach ($VM in $VMs){

    $DiskInfo = Get-VHD -ComputerName $VM.ComputerName -VMId $VM.Id

    foreach ($item in $DiskInfo){

        [string]$FilePath = $item.Path
        $vm.Uptime
        $Hash =  [ordered]@{
            HyperVNode            = $item.ComputerName
            VMName                = $VM.Name
            VMSate                = $VM.State
            Uptime                = IF($VM.State -eq "Off"){ "VM is Offline" } ELSE { "$($VM.Uptime.Days) days, $($VM.Uptime.Hours) hours, $($VM.Uptime.Minutes) minutes" }
            Generation            = $VM.Generation
            'RAM(MB)'             = $VM.MemoryAssigned/1MB
            vCPU                  = $VM.ProcessorCount
            VHDFileName           = Split-Path -Path $($item.Path) -Leaf
            VHDFormat             = $item.VhdFormat
            VHDType               = $item.VhdType
            'CurrentDiskSize(GB)' = [math]::Round($item.FileSize/1GB)
            'MaximumDiskSize(GB)' = [math]::Round($item.MinimumSize/1GB)
            VHDFilePath           = Split-Path -Path $($item.Path) -Parent

        }
    
        $Object = New-Object psobject -Property $Hash
        $Array += $Object

    }

}

$Array | Out-GridView
$Array | Export-Csv -Path C:\temp\vmsInCluster.csv -NoTypeInformation