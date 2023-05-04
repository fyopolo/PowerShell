$Servers = "AG-CH3-HS2", "AG-CH3-HS3", "AG-DC-HS1", "AG-DC-HS5", "AG-CH3-CL1-ND1", "AG-CH3-CL1-ND2"

# $VMs = Get-VM -ComputerName (Get-ClusterNode) | Select ComputerName, Name, State, Id
$VMsArray = @()
$Array = @()

foreach ($HV in $Servers){
    $VMsArray += Get-VM -ComputerName $HV | Select ComputerName, Name, State, Id
    
}

foreach ($VM in $VMsArray){

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
$Array | Export-Csv -Path C:\Temp\VRTXClusterVMsDisk.csv
