#$ServerList = Get-Content "C:\Temp\ServerList.txt"
$ServerList = "localhost"
$Table = @()

foreach ($Server in $ServerList){

    Invoke-Command -ComputerName $Server -ScriptBlock {
        $OS = Get-WmiObject -Namespace "root\cimv2" -Class Win32_OperatingSystem
        #foreach ($item in $OS) {
            $CPU = [string]::Concat((Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average," %")
            $FreeRAM = [string]::Concat([math]::Round($OS.FreePhysicalMemory / 1MB, 2)," (GB)")
            $User = (Get-CimInstance Win32_ComputerSystem).UserName

            $Hash = [Ordered]@{
                ServerName = $Server
                UsedCPU    = $CPU
                FreeRAM    = $FreeRAM
                LoggedUser = $User
            }

            $TableObject = New-Object PSObject -Property $Hash
            $Table += $TableObject

        #}
    }
}

$Table | Out-GridView