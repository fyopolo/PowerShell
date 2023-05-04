Function Get-LogonProperties {
    [CmdletBinding(SupportsShouldProcess=$True)]
    [Alias()]
    [OutputType([bool])]
    Param
    (
        # Remove Logon Script
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [bool]
        $RemoveLogonScript,

        # Remove Home Drive
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]

        [bool]
        $RemoveHomeDrive,
        
        # Remove Home Diretory
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]

        [bool]
        $RemoveHomeDirectory
    )

    Begin {
        IF (-NOT(Get-Module -Name ActiveDirectory)){
            Write-Warning "Active Directory Module was not found. Aborting script!"
            Exit
        }
    }

    Process {
        $UserProfile = Get-ADUser -Filter { ScriptPath -ne "*" -or HomeDrive -ne "*" -or HomeDirectory -ne "*" } -Properties * | Sort DisplayName | Select DisplayName, SamAccountName, ScriptPath, HomeDrive, HomeDirectory
        IF ($UserProfile -ge 0){
                Write-Host "The following accounts will be affected" -ForegroundColor Cyan
                $UserProfile | ft -AutoSize
                $UserProfile | Out-File C:\TEMP\UserADProfile.txt
                        
            foreach ($User in $UserProfile){
                Set-ADUser -Identity $User.SamAccountName -ScriptPath $null -Confirm -Verbose
                Set-ADUser -Identity $User.SamAccountName -HomeDrive $null -Confirm -Verbose
                Set-ADUser -Identity $User.SamAccountName -HomeDirectorty $null -Confirm -Verbose
                } # End foreach
            } # End IF
        } # End PROCESS section

    End {
        Write-Host "The following accounts were affected..." -ForegroundColor Yellow
        Write-Host ""
        $UserProfile
        } # End END section
}

Get-LogonProperties -Confirm