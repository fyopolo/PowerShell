<# Creating remote PowerShell session to Exchange Online

$credential = Get-Credential
Import-Module MsOnline
Connect-MsolService -Credential $credential
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
Import-PSSession $exchangeSession -DisableNameChecking

#>

$Recipients = Get-Recipient | Where-Object {$_.RecipientTypeDetails -eq "UserMailbox" -and $_.Name -notlike "*xogito*" -and $_.Name -notlike "*support*"}
$Group = Get-Group -Identity "employees"

$RCPTCount = 0
$Missed = 0
$AA = @()

foreach ($RCPT in $Recipients){
    $RCPTCount ++
    IF ($Group.Members -notcontains $RCPT.Name) {
        $Missed ++

        Write-Warning "$RCPT.Name Was Not Found in $Group distribution list"
        Add-DistributionGroupMember -Identity $($Group.Name) -Member $RCPT.Name -Verbose

        $Hash = [ordered]@{
            DisplayName        = $RCPT.DisplayName
            Alias              = $RCPT.Alias
            Identity           = $RCPT.Identity
            PrimarySmtpAddress = $RCPT.PrimarySmtpAddress
            
                         
        } #     Closing 'Hash'

        $UserTableObject = New-Object psobject -Property $Hash
        $AA += $UserTableObject # Populating custom PS Object with Hash Table elements
    }

}

Write-Host
Write-Host
Write-Host "The following accounts were added to $Group Distribution List" -ForegroundColor Cyan

$AA | Sort-Object DisplayName # | Export-Csv -Path C:\temp\CP-Migration\DL.txt

$DynGroup = Get-DynamicDistributionGroup
Get-Recipient -RecipientPreviewFilter $DynGroup.RecipientFilter