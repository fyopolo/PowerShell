#requires -version 2
<#
.SYNOPSIS
   Show all WiFi profiles stored on the local computer with passwords.
   Many thanks to: https://heineborn.com/tech/display-all-saved-wifi-passwords who gave the main code!

.DESCRIPTION
    The script lets can show you all WiFi profiles which are stored on a local computer. It can also show you only the password of a selected Wifi 
    profile or shows all Wifi profiles whith their saved passwords



.PARAMETER <Parameter_Name>
   None

.INPUTS
    None

.OUTPUTS
   Output is displayed on screen

.NOTES
    Template Version:  1.0   
    Version:           1.0
    Author:            R.Dorreboom
    Creation Date:     03-02-2016
    Purpose/Change:   Initial script development
  
.EXAMPLE
  GetWifIPasswords
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------
#clear the Screen
Clear-Host 

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#Find open PowerShell sessions and close them
Get-PSSession|Remove-PSSession

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "1.0"

#Create QuestionBox
    $title = "Reveal WiFi network password"
    $message = "Do you want to reveal all or just one WiFi password stored on this computer?"
    $All = New-Object System.Management.Automation.Host.ChoiceDescription "&All", "Reveal all stored WiFi Passwords"
    $One = New-Object System.Management.Automation.Host.ChoiceDescription "&One", "Reveal only a selected stored WiFi Password"
    $ShowWiFiProfiles = New-Object System.Management.Automation.Host.ChoiceDescription "&Show WiFi Profiles", "Only Display stored Wifi Profiles on this computer"
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($All, $One, $ShowWiFiProfiles )
    $result = $host.ui.PromptForChoice($title, $message, $options, 0) 

#Get all WiFi Profiles
    $Profiles = @()
    $Profiles += (netsh wlan show profiles)|Select-String "\:(.+)$" | Foreach{$_.Matches.Groups[1].Value.Trim()} |sort-object


#Read out the user input
    switch ($result)
        {
            0 {
                #The user selected All
                $Profiles | Foreach{$ProfileName = $_ ; (netsh wlan show profile name="$_" key=clear)} | `
                        Select-String "Key Content\W+\:(.+)$" | `
                            Foreach{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | `
                                Foreach{[PSCustomObject]@{ PROFILE_NAME=$ProfileName;PASSWORD=$pass }} | `
                                    Format-Table -AutoSize 
            }


            1 {
                #The user selected One
                $Wifi2Reveal = Read-Host "Name of the WiFi profile you wish to reveal"
                (netsh wlan show profile name="$Wifi2Reveal" key=clear)| `
                        Select-String "Key Content\W+\:(.+)$" | `
                            Foreach{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | `
                                Foreach{[PSCustomObject]@{ PROFILE_NAME=$Wifi2Reveal;PASSWORD=$pass }} | `
                                    Format-Table -AutoSize 
            }

            2 {
                #The user selected Only Show Wifi profiles
                $Profiles 
 
            }
        }
