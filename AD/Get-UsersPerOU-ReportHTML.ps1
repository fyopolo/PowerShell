Function Create-Report {
    $rptFile = "C:\TEMP\UsersByOU.htm"
    $rpt | Set-Content -Path $rptFile -Force
    Invoke-Item $rptFile
    Start-Sleep 1
}

$OUs = Get-ADOrganizationalUnit -Filter * -SearchScope Subtree -Properties * | Sort CanonicalName
$Array = @()

foreach ($OU in $OUs){

    Write-Host "Searching for users in" $OU -ForegroundColor Cyan
    $UsersInOU = Get-ADUser -Filter * -SearchBase $OU -Properties * -SearchScope Subtree
     
    IF ($UsersInOU.Count -gt 0) {

        foreach ($Item in $UsersInOU) {
        
            IF (-NOT($Array.SamAccountName -contains $Item.SamAccountName)){
            
                IF (-NOT([string]::IsNullOrWhiteSpace($Item.LastLogon) -OR ($Item.lastLogon -like "*null*"))) { $LastLogon = ($(w32tm /ntte $Item.LastLogon) -split " - ",2)[1] } ELSE { $LastLogon = "Never" }
            
                $Hash =  [ordered]@{
                    DisplayName       = $Item.DisplayName
                    UserName          = $Item.Name
                    SamAccountName    = $Item.SamAccountName
                    UserPrincipalName = $Item.UserPrincipalName
                    Enabled           = $Item.Enabled
                    LastLogon         = $LastLogon
                    OU                = ($Item.CanonicalName).TrimEnd($Item.Name).TrimEnd("/").Replace("/"," > ")
                }
    
            $Object = New-Object psobject -Property $Hash
            $Array += $Object

            }
        }
    } ELSE { Write-Host "There are no users in $OU" -ForegroundColor DarkYellow }
}

# $Array | Sort OU | Out-GridView

###### HTLM REPORT ######
Import-Module ReportHTML
$DomainName = $((Get-ADDomain).DNSRoot)

$rpt += Get-HtmlOpenPage -TitleText "Users Last Logon Date for domain $DomainName" -LeftLogoString "https://ownakoa.com/wp-content/uploads/2016/09/TeamLogic-IT-Logo.png"

    $rpt += Get-HTMLHeading -headerSize 1 -headingText "Users"
    $rpt += Get-HTMLContentOpen -HeaderText "List"
	    $rpt += Get-HTMLContentTable $Array -GroupBy OU
    $rpt += Get-HTMLContentClose

$rpt += Get-HTMLClosePage -FooterText "Fernando Yopolo // fyopolo@homail.com // Year $((Get-Date).Year)" ##    CLOSING HTML REPORT


Create-Report