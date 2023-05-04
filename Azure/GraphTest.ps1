$clientId = "456d146e-c675-4058-a7bb-3c26e06be533"
$authTenant = "5b808100-5f89-4e87-b816-634cd9906236"
$graphScopes = "BitlockerKey.Read.All BitlockerKey.ReadBasic.All Device.Command Device.Read Device.Read.All DeviceManagementApps.Read.All DeviceManagementApps.ReadWrite.All DeviceManagementConfiguration.Read.All DeviceManagementConfiguration.ReadWrite.All DeviceManagementManagedDevices.PrivilegedOperations.All DeviceManagementManagedDevices.Read.All DeviceManagementManagedDevices.ReadWrite.All DeviceManagementRBAC.Read.All DeviceManagementRBAC.ReadWrite.All DeviceManagementServiceConfig.Read.All DeviceManagementServiceConfig.ReadWrite.All Policy.ReadWrite.DeviceConfiguration TeamworkDevice.Read.All TeamworkDevice.ReadWrite.All User.Read profile openid email Mail.Read Mail.Send"

# Authenticate the user
Connect-MgGraph -ClientId $clientId -TenantId $authTenant -Scopes $graphScopes -UseDeviceAuthentication

# Get the Graph context
$GraphContext = Get-MgContext

# Get the authenticated user by UPN
$user = Get-MgUser -UserId $GraphContext.Account -Select 'displayName, id, mail, userPrincipalName, ManagedDevices'

# Get-MgUser -UserId $GraphContext.Account | gm
# Get-MgDevice | gm

# $user | fl

Write-Host "Hello," $user.DisplayName
# For Work/school accounts, email is in Mail property
# Personal accounts, email is in UserPrincipalName
Write-Host "Email:" ($user.Mail)


Get-MgUserMailFolderMessage -UserId $user.Id -MailFolderId Inbox -Select `
  "from,isRead,receivedDateTime,subject" -OrderBy "receivedDateTime DESC" `
  -Top 25 | Format-Table Subject,@{n='From';e={$_.From.EmailAddress.Name}}, `
  IsRead,ReceivedDateTime

$sendMailParams = @{
    Message = @{
        Subject = "Testing Microsoft Graph"
        Body = @{
            ContentType = "text"
            Content = "Hello world!"
        }
        ToRecipients = @(
            @{
                EmailAddress = @{
                    Address = ($user.Mail ?? $user.UserPrincipalName)
                }
            }
        )
    }
}
Send-MgUserMail -UserId $user.Id -BodyParameter $sendMailParams