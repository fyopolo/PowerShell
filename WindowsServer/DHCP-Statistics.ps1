$Servers = (Get-DhcpServerInDC).DnsName
$ScopeStatistics = @()

foreach ($Server in $Servers){

    $ScopeIDs = Get-DhcpServerv4Scope

    foreach ($Scope in $ScopeIDs){
        
        $ScopeInfo = Get-DhcpServerv4ScopeStatistics -ComputerName $Server -ScopeId $Scope.ScopeId

        $Hash =  [ordered]@{
            ServerName       = $Server
            ScopeId          = $ScopeInfo.ScopeId
            ScopeName        = $Scope.Name
            ScopeStatus      = $Scope.State
            ScopeDescription = $Scope.Description
            Free             = $ScopeInfo.Free
            InUse            = $ScopeInfo.InUse
            PercentageInUse  = $ScopeInfo.PercentageInUse
            Reserved         = $ScopeInfo.Reserved
            Pending          = $ScopeInfo.Pending
            SuperScopeName   = $ScopeInfo.SuperscopeName
        }

    $NewObject = New-Object psobject -Property $Hash
    $ScopeStatistics += $NewObject
    
    }
}

<# -- Export the results according to your needs

$ScopeStatistics | ft -AutoSize
$ScopeStatistics | ft -AutoSize | Out-File C:\Temp\DHCPScopeStatistics.txt
$ScopeStatistics | Out-GridView -Title "Scope Statistics for Servers"

#>