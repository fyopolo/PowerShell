################################################################################################################################################################  
# Script accepts 2 parameters from the command line  
#  
# Office365Username - Optional - Administrator login ID for the tenant we are querying  
# Office365Password - Optional - Administrator login password for the tenant we are querying  
#  
#  
# To run the script  
#  
# .\Get-DistributionGroupMembers.ps1 [-Office365Username admin@xxxxxx.onmicrosoft.com] [-Office365Password Password123] 
#  
#  
# Author:                 Alan Byrne  
# Version:                 2.0  
# Last Modified Date:     16/08/2014  
# Last Modified By:     Alan Byrne alan@cogmotive.com  
################################################################################################################################################################  
  
#Accept input parameters  
Param(  
    [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true)]  
    [string] $Office365Username,  
    [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]  
    [string] $Office365Password  
)  
  
#Constant Variables  
$OutputFile = "DistributionGroupMembers.csv"   #The CSV Output file that is created, change for your purposes  
$arrDLMembers = @{}  
  
  
#Prepare Output file with headers  
Out-File -FilePath $OutputFile -InputObject "Distribution Group DisplayName,Distribution Group Email,Member DisplayName, Member Email, Member Type" -Encoding UTF8  
  
#Get all Distribution Groups from Office 365  
$objDistributionGroups = Get-DynamicDistributionGroup -ResultSize Unlimited
  
#Iterate through all groups, one at a time      
Foreach ($objDistributionGroup in $objDistributionGroups)  
{      
     
    write-host "Processing $($objDistributionGroup.DisplayName)..."  
  
    #Get members of this group  
    $objDGMembers = Get-DynamicDistributionGroupMember -Identity $($objDistributionGroup.PrimarySmtpAddress)  
      
    write-host "Found $($objDGMembers.Count) members..."  
      
    #Iterate through each member  
    Foreach ($objMember in $objDGMembers)  
    {  
        Out-File -FilePath $OutputFile -InputObject "$($objDistributionGroup.DisplayName),$($objDistributionGroup.PrimarySMTPAddress),$($objMember.DisplayName),$($objMember.PrimarySMTPAddress),$($objMember.RecipientType)" -Encoding UTF8 -append  
        write-host "`t$($objDistributionGroup.DisplayName),$($objDistributionGroup.PrimarySMTPAddress),$($objMember.DisplayName),$($objMember.PrimarySMTPAddress),$($objMember.RecipientType)" 
    }  
}  
 
#Clean up session  
# Get-PSSession | Remove-PSSession 