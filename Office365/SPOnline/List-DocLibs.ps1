#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
Import-Module Microsoft.Online.SharePoint.PowerShell -Force
 
#Variables
$SiteURL = "https://aleragroup.sharepoint.com/sites/JAC/"
$DocLibraryName="Documents"
 
#Config Parameters
$SiteCollURL="https://aleragroup.sharepoint.com/sites/JAC/"

#Variables for processing
$AdminCenterURL = "https://aleragroup-admin.sharepoint.com"
 
#User Name Password to connect
$AdminUserName = "fernando.yopolo@aleragroup.com"
$AdminPassword = "fbcpxxnwgfkmvpsm" #App Password
 
#Prepare the Credentials
$SecurePassword = ConvertTo-SecureString $AdminPassword -AsPlainText -Force
$Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $AdminUserName, $SecurePassword
  
#Connect to SharePoint Online tenant
Connect-SPOService -url $AdminCenterURL -Credential $Cred
Connect-SPOService
 
Try {
    #Setup the context
    $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
    $Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.UserName,$Cred.Password)
  
    #sharepoint online get a document library powershell
    $DocLibrary = $Ctx.Web.Lists.GetByTitle($DocLibraryName)
    $Ctx.Load($DocLibrary)
    $Ctx.ExecuteQuery()
 
    Write-host "Total Number of Items in the Document Library:"$DocLibrary.ItemCount
}
Catch {
    write-host -f Red "Error:" $_.Exception.Message
}


#Read more: https://www.sharepointdiary.com/2018/08/sharepoint-online-get-document-library-using-powershell.html#ixzz7lNh2nhrg