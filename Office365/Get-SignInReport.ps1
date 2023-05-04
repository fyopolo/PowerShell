Connect-AzureAD

$Logs = Get-AzureADAuditSignInLogs -All $True

$SigninDetails = @()

foreach ($Item in $Logs){

    $Hash =  [ordered]@{
            'Event recorded on (UTC)'  = $Item.CreatedDateTime
            'User Display Name'        = $Item.UserDisplayName
            'User Principal Name'      = $Item.UserPrincipalName
            'IP Address'               = $Item.IpAddress
            Application                = $Item.AppDisplayName
            'Client App Used'          = $Item.ClientAppUsed
            'Country or Region'        = $Item.Location.CountryOrRegion
            State                      = $Item.Location.State
            City                       = $Item.Location.City
            'Is Interactive'           = $Item.IsInteractive
            Status                     = IF($Item.Status.ErrorCode -eq 0){"Success"} ELSE {"Failure"}
            'Failure Reason'           = IF($Item.Status.FailureReason -eq "Other.") {""} ELSE { $Item.Status.FailureReason }
        
    }

    $Object = New-Object psobject -Property $Hash
    $SigninDetails += $Object    

}

# $SigninDetails | Out-GridView

Import-Module ReportHTML

$rpt += Get-HtmlOpenPage -TitleText "Azure AD Sign-In Report: $((Get-AzureADTenantDetail).DisplayName)" -LeftLogoString "https://ownakoa.com/wp-content/uploads/2016/09/TeamLogic-IT-Logo.png"
# $ReportName = "Office 365 Identities

$rpt += Get-HtmlContentOpen -HeaderText "SignIn Info"
    # $rpt += Get-HTMLContentTable $SigninDetails -GroupBy 'User Display Name'
    $rpt += Get-HTMLContentDataTable -ArrayOfObjects ($SigninDetails | Sort-Object 'User Display Name' -Descending) -PagingOptions '100,200,500,' -HideFooter
$rpt += Get-HtmlContentClose
$rpt += Get-HTMLClosePage -FooterText "Fernando Yopolo // fyopolo@homail.com // Year $((Get-Date).Year)" ##    CLOSING HTML REPORT


Save-HTMLReport -ReportContent $rpt -ShowReport