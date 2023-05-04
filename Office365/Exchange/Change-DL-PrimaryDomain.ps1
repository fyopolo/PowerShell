#
$credential = Get-Credential
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -ShowProgress $true -Credential $credential
#>

$NewDomain = "@shhospitality.co"
$DLS = Get-DistributionGroup

foreach ($item in $DLS){

    $SAM = $item.Alias
    $OLDAddress = $item.PrimarySmtpAddress
    $index = $OLDAddress.IndexOf("@miafrancesca.com")
    $NEWAddress = $OLDAddress.Remove($index) + $NewDomain

    # Add new email address and make old one an alias
    Set-DistributionGroup -Identity $item.Name -EmailAddresses @{Add=$NEWAddress} -Verbose
    Set-DistributionGroup -Identity $item.Name -PrimarySmtpAddress $NEWAddress -Verbose


}
