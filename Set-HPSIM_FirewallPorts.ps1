New-NetFirewallRule -DisplayName "Ping Discovery (ICMP)" -LocalPort 7 -Action Allow -Group "HPE Systems Insight Manager" -Profile any -Direction Inbound -Protocol ICMPv4 -Verbose

New-NetFirewallRule -DisplayName "Ping Discovery (TCP)" -LocalPort 80 -Action Allow -Group "HPE Systems Insight Manager" -Profile any -Direction Inbound -Protocol TCP -Verbose

New-NetFirewallRule -DisplayName "HPE Systems Insight Manager Web Server" -LocalPort 280 -Action Allow -Group "HPE Systems Insight Manager" -Profile any -Direction Inbound -Protocol TCP -Verbose

New-NetFirewallRule -DisplayName "RMI Registry" -LocalPort 2367 -Action Allow -Group "HPE Systems Insight Manager" -Profile any -Direction Inbound -Protocol TCP -Verbose

New-NetFirewallRule -DisplayName "JBoss RMI/JRMP Invoker" -LocalPort 4444 -Action Allow -Group "HPE Systems Insight Manager" -Profile any -Direction Inbound -Protocol TCP -Verbose

New-NetFirewallRule -DisplayName "JBoss Pooled Invoker" -LocalPort 4445 -Action Allow -Group "HPE Systems Insight Manager" -Profile any -Direction Inbound -Protocol TCP -Verbose

New-NetFirewallRule -DisplayName "JBoss Web Service port" -LocalPort 8083 -Action Allow -Group "HPE Systems Insight Manager" -Profile any -Direction Inbound -Protocol TCP -Verbose

New-NetFirewallRule -DisplayName "HPE Systems Insight Manager Secure Web Server" -LocalPort 50000 -Action Allow -Group "HPE Systems Insight Manager" -Profile any -Direction Inbound -Protocol TCP -Verbose

New-NetFirewallRule -DisplayName "HPE Systems Insight Manager SOAP" -LocalPort 50001,50003 -Action Allow -Group "HPE Systems Insight Manager" -Profile any -Direction Inbound -Protocol TCP -Verbose

New-NetFirewallRule -DisplayName "HPE Systems Insight Manager SOAP with Client Certificate Authentication" -LocalPort 50002 -Action Allow -Group "HPE Systems Insight Manager" -Profile any -Direction Inbound -Protocol TCP -Verbose

New-NetFirewallRule -DisplayName "HPE Systems Insight Manager WBEM Event Receiver" -LocalPort 50004 -Action Allow -Group "HPE Systems Insight Manager" -Profile any -Direction Inbound -Protocol TCP -Verbose

New-NetFirewallRule -DisplayName "WBEM Events" -LocalPort 50005 -Action Allow -Group "HPE Systems Insight Manager" -Profile any -Direction Inbound -Protocol TCP -Verbose

New-NetFirewallRule -DisplayName "PostgreSQL" -LocalPort 50006 -Action Allow -Group "HPE Systems Insight Manager" -Profile any -Direction Inbound -Protocol TCP -Verbose

New-NetFirewallRule -DisplayName "PJBoss Naming Service RMI port" -LocalPort 50008 -Action Allow -Group "HPE Systems Insight Manager" -Profile any -Direction Inbound -Protocol TCP -Verbose

New-NetFirewallRule -DisplayName "JBoss Naming Service port" -LocalPort 50009 -Action Allow -Group "HPE Systems Insight Manager" -Profile any -Direction Inbound -Protocol TCP -Verbose

New-NetFirewallRule -DisplayName "HPE Systems Insight Manager VMM Essentials v 1.1.2.0" -LocalPort 50010 -Action Allow -Group "HPE Systems Insight Manager" -Profile any -Direction Inbound -Protocol TCP -Verbose

New-NetFirewallRule -DisplayName "Web services RMI class loader" -LocalPort 50013 -Action Allow -Group "HPE Systems Insight Manager" -Profile any -Direction Inbound -Protocol TCP -Verbose

New-NetFirewallRule -DisplayName "WJRMP invoker" -LocalPort 50014 -Action Allow -Group "HPE Systems Insight Manager" -Profile any -Direction Inbound -Protocol TCP -Verbose

New-NetFirewallRule -DisplayName "Pooled invoker" -LocalPort 50015 -Action Allow -Group "HPE Systems Insight Manager" -Profile any -Direction Inbound -Protocol TCP -Verbose

New-NetFirewallRule -DisplayName "SNMP Trap Listener" -LocalPort 162 -Action Allow -Group "HPE Systems Insight Manager" -Profile any -Direction Inbound -Protocol UDP -Verbose

New-NetFirewallRule -DisplayName "SNMP Agent" -LocalPort 161 -Action Allow -Group "HPE Systems Insight Manager" -Profile any -Direction Inbound -Protocol UDP -Verbose

New-NetFirewallRule -DisplayName "SSH Port" -LocalPort 22 -Action Allow -Group "HPE Systems Insight Manager" -Profile any -Direction Inbound -Protocol TCP -Verbose

New-NetFirewallRule -DisplayName "WBEM/WMI Mapper" -LocalPort 5988 -Action Allow -Group "HPE Systems Insight Manager" -Profile any -Direction Inbound -Protocol TCP -Verbose

New-NetFirewallRule -DisplayName "WBEM/WMIMapper Secure Port" -LocalPort 5989 -Action Allow -Group "HPE Systems Insight Manager" -Profile any -Direction Inbound -Protocol TCP -Verbose

New-NetFirewallRule -DisplayName "HPE SMH Web Server" -LocalPort 2301 -Action Allow -Group "HPE Systems Insight Manager" -Profile any -Direction Inbound -Protocol TCP -Verbose

New-NetFirewallRule -DisplayName "HPE SMH Secure Web Server" -LocalPort 2381 -Action Allow -Group "HPE Systems Insight Manager" -Profile any -Direction Inbound -Protocol TCP -Verbose