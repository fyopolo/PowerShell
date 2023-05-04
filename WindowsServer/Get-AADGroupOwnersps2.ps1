$credential = Get-Credential
Import-Module MsOnline
Connect-MsolService -Credential $credential
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
Import-PSSession $exchangeSession -DisableNameChecking

Import-Module ReportHTML

Write-Host "Getting Unified Groups. Please stand by..." -ForegroundColor Cyan

$table = @()
$O365Groups = Get-UnifiedGroup -ResultSize unlimited -IncludeAllProperties

foreach ($O365Group in $O365Groups)  
{
   foreach ($GRPItem in $O365Group){

    $GRPMember = Get-UnifiedGroupLinks -Identity $GRPItem.Identity -LinkType Members
    $GRPOwner = Get-UnifiedGroupLinks -Identity $GRPItem.Identity -LinkType Owners

            $Hash =  [ordered]@{
            GroupDisplayName  = $O365Group.DisplayName
            GroupOwner        = $GRPOwner.Name
            MemberDisplayName = $GRPMember.DisplayName
            GERLevel          = $GRPMember.CustomAttribute4
            MemberManager     = $GRPMember.Manager
        }

    $NewObject = New-Object psobject -Property $Hash
    $table += $NewObject
    }
}



$table | Export-Excel -Show
$table | out-gridview
$table | gm
$O365Groups | gm