$computer = $env:COMPUTERNAME

$os = Get-CimInstance –ClassName Win32_OperatingSystem –ComputerName $computer
$cs = Get-CimInstance –ClassName Win32_ComputerSystem –ComputerName $computer
$bios = Get-CimInstance –ClassName Win32_BIOS –ComputerName $computer

$properties = @{'ComputerName'=$computer;
'OSVersion' =$os.version;
'OSBuild' =$os.buildnumber;
'Mgfr' =$cs.manufacturer;
'Model' =$cs.model;
'BIOSSerial' =$bios.serialnumber}

$obj = New-Object –TypeName PSObject –Property $properties
Write-Output $obj

[System.Math]::PI

[Windows.System.RemoteDesktop.InteractiveSession]

[System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces()

[System.Net.Configuration]

[System.Windows.MessageBox]::Show("Message","Window Title","AbortRetryIgnore","Asterisk")

[System.Windows.Forms.MessageBox]::Show("Message","Exception Report",0,16)

[system.enum]::getNames([System.Windows.Forms.MessageBoxButtons])|foreach{[console]::Writeline("{0,20} {1,-40:D}",$_,[System.Windows.Forms.MessageBoxButtons]::$_.value__)}


[System.Windows.Forms.MessageBox]::Show("Message Text","Title",1)

[system.enum]::getValues([System.Windows.Forms.MessageBoxButtons])|foreach {[System.Windows.Forms.MessageBox]::Show("["+$_.GetType()+"]::"+$_.ToString(),"Message box Buttons",$_)}

[system.enum]::getValues([System.Windows.Forms.MessageBoxIcon])|foreach {[System.Windows.Forms.Messagebox]::Show("["+$_.GetType()+"]::"+$_.ToString(),"Message box Icons",[System.Windows.Forms.MessageBoxButtons]::OK,$_)}