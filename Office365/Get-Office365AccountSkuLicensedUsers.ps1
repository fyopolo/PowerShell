function Get-Office365AccountSkuLicensedUsers
{
    [CmdletBinding()]
    [Alias()]
    Param
    (
        # AccountSkuId
        [Parameter(Mandatory=$true,
                   ParameterSetName = "AccountSkuId",
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateSet("ENTERPRISEPACK","RIGHTSMANAGEMENT","AAD_PREMIUM","PLANNERSTANDALONE","POWER_BI_STANDARD","ENTERPRISEWITHSCAL")]
        $AccountSkuId
    )
 
    Begin
    {
 
    }
    Process
    {
        If ($PSBoundParameters.ContainsKey("AccountSkuId"))
        {
            $AccountSkuIdUsers = Get-MsolUser | Select-Object DisplayName,UserPrincipalName -ExpandProperty Licenses |  Where-Object {$_.AccountSkuId -like "*$AccountSkuId*"}
            $AccountSkuIdUsers | Select-Object DisplayName,UserPrincipalName | Sort-Object DisplayName
        }
    }
    End
    {
 
    }
}

Get-Office365AccountSkuLicensedUsers -AccountSkuId POWER_BI_STANDARD