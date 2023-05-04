
[CmdletBinding()]

param([string]$computername = $env:computername)

$head = @'

<style>

body { background-color:#dddddd;

       font-family:Tahoma;

       font-size:12pt; }

td, th { border:1px solid black;

         border-collapse:collapse; }

th { color:white;

     background-color:black; }

table, tr, td, th { padding: 2px; margin: 0px }

table { margin-left:50px; }

</style>

'@

$OutputFile = "C:\temp\temp.htm"

# function to get computer system info

function Get-CSInfo {

  param($computername)

  $OS = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computername
  $CS = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $computername
  $BIOS = Get-WmiObject -Class Win32_BIOS -ComputerName $computername

  $props = @{
    'ComputerName' = $computername
    'OS Version'= $OS.version
    'OS Build'= $OS.buildnumber
    'Service Pack'= $OS.sevicepackmajorversion
    'RAM' = ([math]::Round($($CS.totalphysicalmemory/1GB)) -as [string]) + " GB"
    'Processors' = $CS.numberofprocessors
    'BIOS Serial'= $BIOS.serialnumber
  }

  $obj = New-Object -TypeName PSObject -Property $props
  Write-Output $obj

}

$frag1 = Get-CSInfo -computername $computername | ConvertTo-Html -As LIST -Fragment -PreContent '<h2>Computer Info</h2>' | Out-String

$frag2 = Get-WmiObject -Class Win32_LogicalDisk -Filter 'DriveType=3' -ComputerName $computername |

Select-Object @{name='Drive';expression={$_.DeviceID}},

              @{name='Size(GB)';expression={$_.Size / 1GB -as [int]}},

              @{name='FreeSpace(GB)';expression={$_.freespace / 1GB -as [int]}} | ConvertTo-Html -Fragment -PreContent '<h2>Disk Info</h2>' | Out-String

ConvertTo-HTML -head $head -PostContent $frag1,$frag2 -PreContent "<h1>Hardware Inventory for $ComputerName</h1>" | Out-File $OutputFile

Invoke-Expression $OutputFile

<#

$frag1 | out-html

Get-WmiObject -Class Win32_LogicalDisk

$frag2 = Get-PSDrive | Select-Object Name, @{name='Used (GB)';expression={$_.Used / 1GB -as [int]}}, @{name='Free(GB)';expression={$_.Free / 1GB -as [int]}}

$frag2

Get-Disk

#>