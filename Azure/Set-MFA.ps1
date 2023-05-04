# Connect-MsolService

# IDENTIFY MFA REGISTERED USERS

# Get-MsolUser -All | where {$_.StrongAuthenticationMethods -ne $null} | Select-Object -Property UserPrincipalName | Sort-Object userprincipalname

Get-MsolUser -All | where {$_.StrongAuthenticationMethods -ne $null} | Set-MsolUser -StrongAuthenticationMethods


# IDENTIFY MFA NON-REGISTERED USERS

# Get-MsolUser -All | where {$_.StrongAuthenticationMethods.Count -eq 0} | Select-Object -Property UserPrincipalName | Sort-Object userprincipalname


# Sets the MFA requirement state
function Set-MfaState {

    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName=$True)]
        $ObjectId,
        [Parameter(ValueFromPipelineByPropertyName=$True)]
        $UserPrincipalName,
        [ValidateSet("Disabled","Enabled","Enforced")]
        $State
    )

    Process {
        Write-Verbose ("Setting MFA state for user '{0}' to '{1}'." -f $ObjectId, $State)
        $Requirements = @()
        if ($State -ne "Disabled") {
            $Requirement =
                [Microsoft.Online.Administration.StrongAuthenticationRequirement]::new()
            $Requirement.RelyingParty = "*"
            $Requirement.State = $State
            $Requirements += $Requirement
        }

        Set-MsolUser -ObjectId $ObjectId -UserPrincipalName $UserPrincipalName `
                     -StrongAuthenticationRequirements $Requirements
    }
}

# Disable MFA for all users
Get-MsolUser -All | Set-MfaState -State Disabled

Get-MsolUser -All | Set-MfaState -State Disabled

$Upn = "adam@adamrubinstein.com"
$noMfaConfig = @()
Set-MsolUser -UserPrincipalName $Upn -StrongAuthenticationMethods $noMfaConfig

Get-MsolUser -UserPrincipalName $Upn | Select StrongAuthenticationMethods



Import-Module MsOnline

# Get Office 365 Object ID
try
{
    $objectId = [Guid]$Context.TargetObject.Get("adm-O365ObjectId")
}
catch
{
    $Context.LogMessage("The user %fullname% doesn't have an Office 365 account.", "Warning")
    return
}

# Connect to Office 365
Connect-MsolService -Credential $Context.GetOffice365Credential()

$authenticationRequirements = New-Object "Microsoft.Online.Administration.StrongAuthenticationRequirement"
$authenticationRequirements.RelyingParty = "*"
$authenticationRequirements.State = "Disabled"

# Set MFA state in Office 365
Set-MsolUser -ObjectId $objectId -StrongAuthenticationRequirements $authenticationRequirements