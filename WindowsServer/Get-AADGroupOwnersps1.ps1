<#
 This script will output a csv file of all O365 Groups Owners to a comma separated file.
 This script requires modification to automate creation of the group that the author did not have
 Most users have rights to read groups and group membership but elevated privileges in Exchange and AAD are required to edit groups
 CSV format includes the UserPrincipalName, DisplayName, GroupDisplayName, and GroupOwnerCount.
 If the $uniqueUsersOnly variable is set to true, the $allO365GroupOwners.UserPrincipleName will contain
 the distinct membership for the SG-AZW-Stream Owners AD security group.
#>


# Creating remote PowerShell session to Exchange Online

$credential = Get-Credential
Import-Module MsOnline
Connect-MsolService -Credential $credential
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
Import-PSSession $exchangeSession -DisableNameChecking


<#
 outputFilePath is the path to the csv file which can be output from this script
 uniqueUsersOnly will toggle reporting on unique users and a count of the groups where they are an Owner or All users and each individual group they are an owner of
#>
$outputFilePath = "$($env:OneDrive)\SG-AZW-Stream Owners.csv"
$uniqueUsersOnly = $true

<#
  The below Install-Module is required if you have not already installed the AzureAD PowerShell module
  Install-Module -Name AzureAD -Scope CurrentUser
#>
<#
 The following will add the path to your OneDrive WindowsPowerShell Modules folder which is required if you are using OneDrive Backup of your Important folders
 and import the AzureAD module
#>
$env:PSModulePath = $env:PSModulePath + ";$($env:OneDrive)\Documents\WindowsPowerShell\Modules"
Import-Module -Name AzureAD -Scope Local 



<#
 The following has been commented out as modifications to security policies have required manually entering credentials using standard Azure authentication dialogs
 $adminCred = $host.ui.PromptForCredential("Enter Office 365 Global Admin Account Credentials","Enter Password:","$($env:USERNAME)@fmi.com","")
 $tenandId = "5f229ce1-773c-46ed-a6fa-974006fae097" 
 $serviceCreds = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $adminCred.UserName, $adminCred.Password
 $aad = Connect-AzureAD -Credential $serviceCreds -TenantId $tenandId -AzureEnvironmentName AzureCloud -AccountId $serviceCreds.UserName
#>
$aad = Connect-AzureAD -Credential $credential

<#
 This section will retrieve all AzureAD groups and omit security enabled groups which are not O365 groups in the $allAADGroups array
 Below are for troubleshooting and validation of data
 Get-AzureADGroup -SearchString "Group Owner" | Get-AzureADGroupOwner -All:$true
 Get-AzureADGroup -SearchString "Group Owner" | FL
#>
write-host "Getting all AzureAD groups..."
$allAADGroups = @()
$allAADGroups = Get-AzureADGroup -All:$true
$allAADGroups = $allAADGroups | ?{$_.SecurityEnabled -eq $false} #O365 groups are not security enabled
$allGroupsCount = $allAADGroups.Count

Write-Host "Getting Unified Groups. Please stand by..."
$O365Groups = Get-UnifiedGroup -ResultSize unlimited
$O365GroupsCounter = 0

<#

foreach ($O365Group in $O365Groups){  

    $Members = Get-UnifiedGroupLinks –Identity $O365Group.Alias –LinkType Members
    $O365Group | Select Owner, DisplayName, PrimarySMTPAddress, EmailAddresses
}
#>

#Get-UnifiedGroupLinks -Identity "$identity" -LinkType Members Select DisplayName, GroupMemberCount

# $O365Groups.Alias #| gm | Export-Excel -Show

#Get-MsolDirSyncProvisioningError | Where-Object {$_.ObjectType -eq "User"} | Out-GridView | gm
#Get-MsolHasObjectsWithDirSyncProvisioningErrors

#Get-MsolDirSyncProvisioningError -ErrorCategory

#Get-MsolDirSyncProvisioningError -ErrorCategory PropertyConflict -PropertyName UserPrincipalName

#Get-MsolDirSyncFeatures


<# 
 This section will return the Owners from all O365 groups
 In addition to User information it will add the associated O365 group DisplayName, Description, ObjectID, and Owner Count to the object
 
 Below are for troubleshooting and validation of data
 $samplegroup = $allAADGroups[37]
 $samplegroup | fl
 $samplegroupOwners = @()
 $samplegroupOwners = Get-AzureADGroupOwner -ObjectId $samplegroup.ObjectID -All:$true
 $samplegroupOwners.count # O365 groups have owners, else it is a DL
#>

$allAADGroups | fl | select -First 10

$allO365GroupOwners = @()
$counter = 0
$UnifiedGRPOwners = @()

foreach($AADGroup in $allAADGroups){
    $counter++
    Write-Host "Processing group $($counter) of $($allGroupsCount): $($AADGroup.DisplayName)"
    $GroupOwners = @()
    $GroupOwnerCount = 0
    $GroupOwners = Get-AzureADGroupOwner -ObjectId $AADGroup.ObjectID -All:$true
    try
    {
        Write-Host "Group has $($GroupOwners.Count) owners" # O365 groups have owners, else it is orphaned or a DL and should be ignored

        $Hash =  [ordered]@{
            GroupDisplayName = $AADGroup.DisplayName
            GroupDescription = $AADGroup.Description
            GroupObjectID    = $AADGroup.ObjectID
            GroupOwnerCount  = $GroupOwners.Count
            DirSyncEnabled   = $AADGroup.DirSyncEnabled
            ObjectType       = $AADGroup.ObjectType
            SecurityEnabled  = $AADGroup.SecurityEnabled
        }

    $NewObject = New-Object psobject -Property $Hash
    $UnifiedGRPOwners += $NewObject
    
    }

    catch
    {
        Write-Host "Group has 0 owners" -ForegroundColor Yellow # O365 groups have owners, else it is a DL and should be ignored
    } 
}

$UnifiedGRPOwners | Export-Excel -show

if ($counter -eq $allAADGroupsCount){write-host "Error - processed $counter of $allAADGroupsCount" -BackgroundColor Green}
else{write-host "Error - processed $counter of $allAADGroupsCount" -BackgroundColor Yellow}

if ($uniqueUsersOnly) {$allO365GroupOwners | sort userprincipalname -Unique | Select userprincipalname, DisplayName, groupdisplayname, groupownercount | Export-Csv -Path $outputFilePath -NoTypeInformation -Force }
else {$allO365GroupOwners | sort userprincipalname | Select userprincipalname, DisplayName, groupdisplayname, groupownercount | Export-Csv -Path $outputFilePath -NoTypeInformation -Force }

<#
 Below are for troubleshooting and validation of data

 $allO365GroupOwners | sort userprincipalname -unique | FT userprincipalname, groupdisplayname, groupownercount
 $allO365GroupOwners.count
 ($allO365GroupOwners | sort userprincipalname -unique).count

 $o365GroupsSorted = $allO365Groups | sort -Unique
 $o365GroupsSorted.Count
 $allO365Groups[36] | FL

 $allO365GroupOwners | Sort GroupDisplayName | FT GroupDisplayName, Description, GroupOwnerCount, UserPrincipalName 
 $AADGroup = $allO365Groups | ?{$_.DisplayName -like "*OG-MIS-tech*"}
 $groupOwners = Get-AzureADGroupOwner -ObjectId $AADGroup.ObjectID -All:$true
 $groupOwners.Count
#>
<#
 Below are for troubleshooting and validation of data
 $streamGroup = Get-AzureADGroup -SearchString "SG-AZW-Stream Owners"
 $streamGroupMembers = Get-AzureADGroupMember -ObjectId $streamGroup.ObjectID -All:$true
 $streamGroupMembers | sort userprincipalname | Select userprincipalname, DisplayName | Export-Csv -Path "C:\Users\dpeterma\OneDrive - Freeport-McMoRan Inc\Architecture and Build\O365\Stream\AllStreamGroupMembers.csv" -NoTypeInformation -Force
#>

$streamGroupMembers | Out-GridView
$streamGroupMembers | Select UserPrincipalName, DisplayName, DirSyncEnabled, UserType | Out-GridView

#######################################################

Import-Module ReportHTML
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

