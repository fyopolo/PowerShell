# Connect-VIServer -Server vcenter-langenfeld -Force
$VMs = Get-VM
$VmsDetails = @()
foreach ($vm in $VMs){
 $view = Get-View $vm
   IF ($view.config.hardware.Device.Backing.ThinProvisioned -eq $true){
   # $row = '' | select Name, Provisioned, Total, Used, VMDKs, Thin
      $Hash = [ordered]@{
          Name = $vm.Name
          ProvisionedGB = [math]::round($vm.ProvisionedSpaceGB , 2)
          TotalGB = [math]::round(($view.config.hardware.Device | Measure-Object CapacityInKB -Sum).sum/1048576,2)
          TotalTB = [math]::round(($view.config.hardware.Device | Measure-Object CapacityInKB -Sum).sum/1073741824,2)
          UsedGB  = [math]::round($vm.UsedSpaceGB,2)
          VMDKs   = "$($view.config.hardware.Device.Backing.Name)`r`n"
          Thin    = "$($view.config.hardware.Device.Backing.ThinProvisioned)`r`n"
      }
   $NewObject = New-Object psobject -Property $Hash
   $VmsDetails += $NewObject


   }
}

[int]$F = ($view.config.hardware.Device | Measure-Object CapacityInKB -Sum).sum/1073741824
[int]$L = ($view.config.hardware.Device | Measure-Object CapacityInKB -Sum).sum

SWITCH (($L | Measure-Object -Character).Characters) {
    10 {$Measure = "KB"}
    7 {$Measure = "MB"}
    4 {$Measure = "GB"}
    default {$Measure = "TB"}

}

[int]$A = 0.234
    $SizeTB = [math]::round(($view.config.hardware.Device | Measure-Object CapacityInKB -Sum).Sum/1073741824,2)
    $SizeGB = [math]::round(($view.config.hardware.Device | Measure-Object CapacityInKB -Sum).Sum/1048576,2)
    
    IF (($A | Measure-Object -Character).Characters -eq 4) {
        $Measure = "GB"
        [string]$FSize = $SizeGB -join($Measure) }
    ELSEIF (($A | Measure-Object -Character).Characters -lt 4 -and [string]$A.StartWith("0.")) {
        $Measure = "TB"
        [string]$FSize = ([int]$Size * 1024) + "HOLA"
    }

    [string]$Size.StartsWith("0.")

($L | Measure-Object -Character).Characters
($F | Measure-Object -Character).Characters

$VmsDetails | Sort Name | Out-GridView
$VmsDetails | Sort Name | Export-Excel -Path C:\TEMP\VMs.xlsx -Show

#$view.Config.DatastoreUrl.Name

$view.config.hardware.Device