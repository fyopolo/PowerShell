Function Get-LogonProperties {
    [CmdletBinding(SupportsShouldProcess=$True)]
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
        IF (-NOT(Get-Module -ListAvailable | Where-Object {$_.Name -eq "ActiveDirectory" } )){
            Write-Warning "Active Directory Module was not found. Aborting script!"
            Break
        }
    } # End BEGIN section

    Process {
        $UserProfile = Get-ADUser -Filter { Enabled -eq "True" -and ScriptPath -ne "*" -or HomeDrive -ne "*" -or HomeDirectory -ne "*" } -Properties * | Sort DisplayName | Select DisplayName, SamAccountName, ScriptPath, HomeDrive, HomeDirectory
        IF ($UserProfile.Count -gt 0){
            Write-Host "Getting information..." -ForegroundColor Yellow
            $UserProfile | Out-GridView
            $UserProfile | ft -AutoSize | Out-File C:\TEMP\UserLogonProperties.txt # Save a snapshot before deleting information

            foreach ($User in $UserProfile){
                # IF (-NOT([string]::IsNullOrWhiteSpace($User.ScriptPath))){ Set-ADUser -Identity $User.SamAccountName -ScriptPath $null -ErrorAction SilentlyContinue -Verbose }
                # IF (-NOT([string]::IsNullOrWhiteSpace($User.HomeDrive))) { Set-ADUser -Identity $User.SamAccountName -HomeDrive $null -ErrorAction SilentlyContinue -Verbose }
                # IF (-NOT([string]::IsNullOrWhiteSpace($User.HomeDirectory))) { Set-ADUser -Identity $User.SamAccountName -HomeDirectory "" -ErrorAction SilentlyContinue -Verbose }
                } # End foreach
        } ELSE {
            Write-Host "No user accounts were found that meet the criteria." -ForegroundColor Cyan
            Break
            }
    } # End PROCESS section
    
    End {
        Write-Host ""
        Write-Host "The following accounts were affected..." -ForegroundColor Yellow
        $UserProfile | ft -AutoSize
    } # End END section
}

Get-LogonProperties