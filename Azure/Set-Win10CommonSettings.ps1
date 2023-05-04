<#

Deployment mode: Microsoft Intune Portal

#>

# Set-ExecutionPolicy -ExecutionPolicy Bypass

# Remember Last Logged On User = TRUE

$RegistryPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\"
$Property = "dontdisplaylastusername"

$LastLoggedOnUser = Get-ItemProperty -Path $RegistryPath -Name $Property

SWITCH ($LastLoggedOnUser.dontdisplaylastusername){

    0 { Exit } # Nothing to change
    1 { Set-ItemProperty -Path $RegistryPath -Name $Property -Value 0 }
}
