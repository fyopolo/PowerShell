# Get Creds - Global Administrator prefered
# $Credential = Get-Credential

# Import API DLL
$dllpath = 'C:\Program Files\Microsoft\Exchange\Web Services\2.2\Microsoft.Exchange.WebServices.dll'
Import-Module $dllpath

# Connect To Exchange Online
# $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Credential -Authentication Basic -AllowRedirection Import-PSSession $Session -AllowClobber

# Set Global Admmin User used to login to exchange online above To Allow Application Impersonation to use EWS So This Thing Works!
Enable-OrganizationCustomization -ErrorAction SilentlyContinue
New-ManagementRoleAssignment -Role ApplicationImpersonation -User $Credential.UserName

# Setup User Impersonation for the $Service variable
$ExchangeVersion = [Microsoft.Exchange.WebServices.Data.ExchangeVersion]::Exchange2013

# Define UPN of the Account that has impersonation rights
$AccountWithImpersonationRights = $Credential.UserName

# Create Exchange Service Object
$service = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService($ExchangeVersion)

# Get valid Credentials using UPN for the ID that is used to impersonate mailbox
$psCred = $Credential
$creds = New-Object System.Net.NetworkCredential($psCred.UserName.ToString(),$psCred.GetNetworkCredential().password.ToString())
$service.Credentials = $creds

# Set the URL of the CAS (Client Access Server)
$service.Url = new-object Uri("https://outlook.office365.com/EWS/Exchange.asmx")

# Search a User Mailbox with impersonation and list all the folders, itemcounts, childfoldercount, etc. Search Mailbox to get the Folders and then get the individual Folder ID to use to set the tag command
$SMTP = 'ejones@primecp.com'
$service.ImpersonatedUserId = New-Object Microsoft.Exchange.WebServices.Data.ImpersonatedUserId([Microsoft.Exchange.WebServices.Data.ConnectingIdType]::SmtpAddress,$SMTP)
$ConnectToMailboxRootFolders = New-Object Microsoft.Exchange.WebServices.Data.FolderId([Microsoft.Exchange.Webservices.Data.WellKnownFolderName]::MsgFolderRoot,$SMTP)
$EWSParentFolder = [Microsoft.Exchange.WebServices.Data.Folder]::Bind($service,$ConnectToMailboxRootFolders)
$FolderView = New-Object Microsoft.Exchange.WebServices.Data.FolderView(100)
$FolderView.Traversal = [Microsoft.Exchange.WebServices.Data.FolderTraversal]::Deep

# Uncomment the line below if you want to search for a specific folder name. Load $FolderName Variable with the name you are looking for.
# $SearchFilter = New-Object Microsoft.Exchange.WebServices.Data.SearchFilter + IsEqualTo([Microsoft.Exchange.WebServices.Data.FolderSchema]::Name,$FolderName)
$MailboxFolderList = $EWSParentFolder.FindFolders($FolderView)
$MailboxFolderList | Select DisplayName, FolderClass, ChildFolderCount, TotalCount, UnreadCount, ID | Sort DisplayName | FT -AutoSize


# $AutodiscoverUrl = New-Object Microsoft.Exchange.WebServices.Autodiscover.AutodiscoverService