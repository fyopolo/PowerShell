$VMs = Get-VM -ComputerName (Get-ClusterNode) | Select ComputerName, Name, State, Id

$Array = @()

foreach ($VM in $VMs){

    $DiskInfo = Get-VHD -ComputerName $VM.ComputerName -VMId $VM.Id

    foreach ($item in $DiskInfo){

        [string]$FilePath = $item.Path

        $Hash =  [ordered]@{
            HyperVNode            = $item.ComputerName
            VMName                = $VM.Name
            VHDFileName           = Split-Path -Path $($item.Path) -Leaf
            VHDFormat             = $item.VhdFormat
            VHDType               = $item.VhdType
            'CurrentDiskSize(GB)' = $item.FileSize/1GB
            'MaximumDiskSize(GB)' = $item.MinimumSize/1GB
            VHDFilePath           = Split-Path -Path $($item.Path) -Parent

        }
    
        $Object = New-Object psobject -Property $Hash
        $Array += $Object

    }

}

$Array | Out-GridView