function Get-IPAddress
{
    Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration |
    Where-Object { $_.IPEnabled -eq $true } |
    # add two new properties for IPv4 and IPv6 at the end
    Select-Object -Property Description, MacAddress, IPAddress, IPAddressV4, IPAddressV6, DHCPEnabled, DHCPLeaseObtained, DHCPLeaseExpires, IPSubnet |
    ForEach-Object {
        # add IP addresses that match the filter to the new properties
        $_.IPAddressV4 = $_.IPAddress | Where-Object { $_ -like '*.*.*.*' }
        $_.IPAddressV6 = $_.IPAddress | Where-Object { $_ -notlike '*.*.*.*' }
        $AdapterName = Get-CimInstance -ClassName Win32_NetworkAdapter | Select NetConnectionID
        # return the object
        $_
    } |
    # remove the property that holds all IP addresses
    Select-Object -Property AtapterName, Description, MacAddress, IPAddressV4, IPAddressV6, DHCPEnabled, DHCPLeaseObtained, DHCPLeaseExpires, IPSubnet | ft
}
  
Get-IPAddress

Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration | Where-Object { $_.ServiceName -eq "NETwNe64" -or $_.ServiceName -eq "e1iexpress" } | ft -AutoSize


Get-CimInstance -ClassName Win32_NetworkAdapter | Select NetConnectionID
