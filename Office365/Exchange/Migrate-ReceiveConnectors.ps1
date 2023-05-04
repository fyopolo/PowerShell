Add-PSSnapin *Exchange*

$OldServer = "EAL-SRV-MSG02"
$NewServer = "EAL-SRV-MSG01"

$ReceiveConnectors = $null
[array]$ReceiveConnectors = Get-ReceiveConnector -Server $OldServer | Where {$_.Identity -notlike "*client*" -and $_.Identity -notlike "*default*" -and $_.Identity -notlike "*outbound*"}

$ReceiveConnectors

$ReceiveConnectors | foreach {

    New-ReceiveConnector -Name $_.Name -Server $NewServer `
    -Usage Custom `
    -TransportRole $_.TransportRole `
    -RemoteIPRanges $_.RemoteIPRanges `
    -bindings $_.Bindings `
    -Banner $_.Banner `
    -ChunkingEnabled $_.ChunkingEnabled `
    -DefaultDomain $_.DefaultDomain `
    -DeliveryStatusNotificationEnabled $_.DeliveryStatusNotificationEnabled `
    -EightBitMimeEnabled $_.EightBitMimeEnabled `
    -DomainSecureEnabled $_.DomainSecureEnabled `
    -LongAddressesEnabled $_.LongAddressesEnabled `
    -OrarEnabled $_.OrarEnabled `
    -Comment $_.Comment `
    -Enabled $_.Enabled `
    -ConnectionTimeout $_.ConnectionTimeout `
    -ConnectionInactivityTimeout $_.ConnectionInactivityTimeout `
    -MessageRateLimit $_.MessageRateLimit `
    -MaxInboundConnection $_.MaxInboundConnection `
    -MaxInboundConnectionPerSource $_.MaxInboundConnectionPerSource `
    -MaxInboundConnectionPercentagePerSource $_.MaxInboundConnectionPercentagePerSource `
    -MaxHeaderSize $_.MaxHeaderSize `
    -MaxHopCount $_.MaxHopCount `
    -MaxLocalHopCount $_.MaxLocalHopCount `
    -MaxLogonFailures $_.MaxLogonFailures `
    -MaxMessageSize $_.MaxMessageSize `
    -MaxProtocolErrors $_.MaxProtocolErrors `
    -MaxRecipientsPerMessage $_.MaxRecipientsPerMessage `
    -PermissionGroups $_.PermissionGroups `
    -PipeliningEnabled $_.PipeLiningEnabled `
    -ProtocolLoggingLevel $_.ProtocolLoggingLevel `
    -RequireEHLODomain $_.RequireEHLODomain `
    -RequireTLS $_.RequireTLS `
    -EnableAuthGSSAPI $_.EnableAuthGSSAPI `
    -ExtendedProtectionPolicy $_.ExtendedProtectionPolicy `
    -SizeEnabled $_.SizeEnabled `
    -TarpitInterval $_.TarpitInterval `
    -Verbose

}