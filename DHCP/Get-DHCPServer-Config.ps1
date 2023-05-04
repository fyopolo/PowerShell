# -------------------------------------------------------------------------------
# Script: DHCP-Server-Config.ps1
# Author: Fernando Yopolo
# Date: 05/04/2018
# Keywords: DHCP
# Comments: Gather Windows DHCP servers info.
#             This requires PowerShell v4+ and have installed the following:
#             Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
#             Install-Module -Name ReportHTML -Force
# Versioning
# 05/04/2018  Initial Script
# 07/04/2018  HTML Reporting capabilities
# -------------------------------------------------------------------------------

Clear-Host

Import-Module ReportHtml
# Get-Command -Module ReportHtml

$ServerCount = 0
$FQDN = (Get-DhcpServerInDC).DnsName



# Create an empty array for HTML strings
$rpt = @()

# NOTE: From here on we always append to the $rpt array variable.
# First, let's add the HTML header information including report title
$rpt += Get-HtmlOpenPage -TitleText "DHCP Servers Report" -LeftLogoString "https://d2oc0ihd6a5bt.cloudfront.net/wp-content/uploads/sites/1064/2015/06/logo.png"

# Looping through each server

foreach ($A in $FQDN)
{

$ServerCount = $ServerCount + 1

Write-Output "Found $ServerCount registered DHCP Server(s)"

$DHCPServer = ((Get-DhcpServerInDC).CimSystemProperties | Select ServerName)
$DHCPServer2 = $DHCPServer -replace "@{ServerName=","}"
$DHCPServer2.ToUpper()


#  Report: Summary Section
$rpt += Get-HtmlContentOpen -HeaderText "General Info for Server $DHCPServer2"


foreach ($Server in $A)

{
    $IPAddress = ((Get-DhcpServerv4Binding -ComputerName $Server).IPAddress).IPAddressToString
    $Server.ToUpper()

    ### Console Output
    Write-Output "Server Name: $Server"
    Write-Output "IP Address: $IPAddress"
    Write-Output ""

    ### Report Output
    $rpt += Get-HtmlContenttext -Heading "FQDN" -Detail $A.ToUpper()
    $rpt += Get-HtmlContenttext -Heading "IP Address" -Detail $IPAddress
    

    # Looping through each scope

    foreach ($DHCPHost in $Server)
        {

        $ScopeCount = (((Get-DhcpServerv4Scope).ScopeId).IPAddressToString | measure).Count
        
        IF ($ScopeCount -gt 0)
        {
        Write-Output "Found $ScopeCount IP v4 scope(s) in server $DHCPHost"
        $rpt += Get-HtmlContenttext -Heading "Total IP v4 Scope(s)" -Detail $ScopeCount
        $rpt += Get-HtmlContentClose

            foreach ($Scope in $ScopeCount)
                {

                $ScopeOverview = Get-DhcpServerv4Scope |
                    Select -Property @{n='Name';e={$_.Name}},
                    @{n='State';e={$_.State}},
                    @{n='Start Range';e={$_.StartRange}},
                    @{n='End Range';e={$_.EndRange}},
                    @{n='Subnet Mask';e={$_.SubnetMask}},
                    @{n='Lease Duration';e={$_.LeaseDuration}}


                $ScopeID = ((Get-DhcpServerv4Scope).ScopeId).IPAddressToString

                $ScopeName = (Get-DhcpServerv4Scope).Name
                
                $Reservations = Get-DhcpServerv4Scope -ComputerName $A | Get-DhcpServerv4Reservation -ComputerName $A |
                Select -Property @{n='Host Name';e={$_.Name}},
                @{n='IP Address';e={$_.IPAddress}},
                @{n='Description';e={$_.Description}}

                $ExclusionRange = Get-DhcpServerv4ExclusionRange |
                Select -Property @{n='Start Range';e={$_.StartRange}},
                @{n='End Range';e={$_.EndRange}}
                
                
                $Leases = Get-DhcpServerv4Lease -ScopeId ((Get-DhcpServerv4Scope).ScopeId).IPAddressToString |
                Select -Property @{n='Address State';e={$_.AddressState}},
                @{n='IP Address';e={$_.IPAddress}},
                @{n='Host Name';e={$_.HostName}},
                @{n='Lease Expiry Time';e={$_.LeaseExpiryTime}}

                            
                # Console Output           

                Write-Output ""
                Write-Output "Scope $ScopeID Overview: " $ScopeOverview | fl
                Write-Output "Reservations" $Reservations
                Write-Output ""
                Write-Output "Exclusion Range for Scope: $ScopeID"
                Write-Output $ExclusionRange
                Write-Output "Leases" $Leases
                Write-Output ""

                # Report Output: SCOPE
                $rpt += Get-HtmlContentOpen -HeaderText "Scope $ScopeID Details"
                $rpt += Get-HtmlContenttext -Heading "Name" -Detail $ScopeOverview.Name
                $rpt += Get-HtmlContenttext -Heading "State" -Detail $ScopeOverview.State
                $rpt += Get-HtmlContenttext -Heading "Start Range" -Detail $ScopeOverview.("Start Range")
                $rpt += Get-HtmlContenttext -Heading "End Range" -Detail $ScopeOverview.("End Range")
                $rpt += Get-HtmlContenttext -Heading "Subnet Mask" -Detail $ScopeOverview.("Subnet Mask")
                $rpt += Get-HtmlContenttext -Heading "Lease Duration (Days/Hours/Minutes)" -Detail $ScopeOverview.("Lease Duration")
                $rpt += Get-HtmlContentClose
                
                
                # Report Output: EXCLUSIONS
                $rpt += Get-HtmlContentOpen -HeaderText "Exclusions" -IsHidden
                $rpt += Get-HtmlContentTable $ExclusionRange -Fixed
                $rpt += Get-HtmlContentClose

                # Report Output: RESERVATIONS
                $rpt += Get-HtmlContentOpen -HeaderText "Reservations" -IsHidden
                $rpt += Get-HtmlContentTable $Reservations -Fixed
                $rpt += Get-HtmlContentClose

                # Report Output: LEASES
                $rpt += Get-HtmlContentOpen -HeaderText "Leases" -IsHidden
                $rpt += Get-HtmlContentTable $Leases -Fixed -GroupBy ("Address State")
                $rpt += Get-HtmlContentClose
               
                }
        }
        
        ELSE
            {
            Write-Output "No IPv4 Scopes Found in server $A"
            Write-Output ""
            $rpt += Get-HtmlContenttext -Heading "No IPv4 Scopes Found in server $A"
            }

        $rpt += Get-HtmlContentClose
    }
        
}
}


########## REPORT SETTINGS ##########

#  Close HTML Report
$rpt += Get-HtmlClosePage

$ReportName = "DHCP Servers Report"
  
# Function: Prompt the user where to store HTML result file

Function Select-FolderDialog
{
    param([string]$Description="Select Folder in where to store HTML result file",[string]$RootFolder="Desktop")

 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
     Out-Null     

   $objForm = New-Object System.Windows.Forms.FolderBrowserDialog
        $objForm.Rootfolder = $RootFolder
        $objForm.Description = $Description
        $Show = $objForm.ShowDialog()
        If ($Show -eq "OK")
        {
            Return $objForm.SelectedPath
        }
        Else
        {
            Write-Error "Operation cancelled by user."
        }
    }

# Creating HTML File

$FileName = $ReportName.Replace(" ","") + ".htm"
$OutputFolder = Select-FolderDialog
$rptFile = $OutputFolder + "\" + $FileName
$rpt | Set-Content -Path $rptFile -Force

#Open File in browser
Invoke-Item $rptFile