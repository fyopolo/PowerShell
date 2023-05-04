# first line of InviteGuests.ps1 PowerShell script
# requires latest AzureADPreview
# Get-Module -ListAvailable AzureAD*
# Uninstall-Module AzureAD
# Uninstall-Module AzureADPreview
# Install-Module AzureADPreview
 
 
# customizable properties for this script
 
$csvDir = ''
$csvInput = $csvDir + 'BulkInvite.csv'
$csvOutput = $csvDir + 'BulkInviteResults.csv'
 
$domain = 'YourTenantOrganization.onmicrosoft.com'
$admin = "admin@$domain"
$redirectUrl = 'https://YourTenantOrganization.sharepoint.com/sites/SiteName/'
$groupName = 'SiteName'
 
 
# CSV file expected format (with the header row):
# Name,Email
# Jane Doe,jane@contoso.com
 
$csv = import-csv $csvInput
 
# will prompt for credentials for the tenantorganization admin account
# (who has permissions to send invites and add to groups)
Connect-AzureAD -TenantDomain $domain -AccountId $admin
 
$group = (Get-AzureADGroup -SearchString $groupName)
 
foreach ($row in $csv)
{
    Try
    {
        if ((Get-Member -inputobject $row -name 'error') -and `
            ($row.error -eq 'success'))
        {
            $out = $row  #nothing to do, user already invited and added to group
        }
        else
        {
            echo ("name='$($row.Name)' email='$($row.Email)'")
 
            $inv = (New-AzureADMSInvitation -InvitedUserEmailAddress $row.Email -InvitedUserDisplayName $row.Name `
                        -InviteRedirectUrl $redirectUrl -SendInvitationMessage $false)
 
            $out = $row
            $out|Add-Member -MemberType ScriptProperty -force -name 'time' -Value {$(Get-Date -Format u)}
            $out|Add-Member -MemberType ScriptProperty -force -name 'status' -Value {$inv.Status}
            $out|Add-Member -MemberType ScriptProperty -force -name 'userId' -Value {$inv.InvitedUser.Id}
            $out|Add-Member -MemberType ScriptProperty -force -name 'redeemUrl' -Value {$inv.inviteRedeemUrl}
            $out|Add-Member -MemberType ScriptProperty -force -name 'inviteId' -Value {$inv.Id}
 
            # this will send a welcome to the group email
            Add-AzureADGroupMember -ObjectId $group.ObjectId -RefObjectId $inv.InvitedUser.Id
 
            $out|Add-Member -MemberType ScriptProperty -force -name 'error' -Value {'success'}
        }
    }
    Catch
    {
        $err = $PSItem.Exception.Message
        $out|Add-Member -MemberType ScriptProperty -force -name 'error' -Value {$err}
    }
    Finally
    {
        $out | export-csv -Path $csvOutput -Append
    }
}
 
# for more information please see
# https://docs.microsoft.com/azure/active-directory/b2b/b2b-tutorial-bulk-invite
# end of InviteGuests.ps1 powershell script