Function Load-CSVFile($initialDirectory) {  
    [System.Reflection.Assembly]::LoadWithPartialName(“System.windows.forms”) | Out-Null

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.Title = "Select CSV File"
    $OpenFileDialog.Filter = “Excel Files (*.csv)| *.csv”
    $Button = $OpenFileDialog.ShowDialog()
    $OpenFileDialog.FileName | Out-Null
    IF ($Button -eq "OK") { Return $OpenFileDialog.FileName }
    ELSE { Write-Error "Operation cancelled by user. Aborting script execution."; Break }
}

Clear-Host
$LogFile = "C:\TEMP\Set-ADProxyAddresses_Transcript.log"
Start-Transcript -IncludeInvocationHeader -LiteralPath $LogFile -Verbose
Write-Host ""
Write-Host ""

$Users = Import-Csv -Path $(Load-CSVFile)

foreach ($User in $Users){

    $ADObject = Get-ADUser $User.SAM -Properties ProxyAddresses
    $ADOAliasesQuery = $($ADObject.ProxyAddresses | Where-Object { $_ -cmatch "smtp:" })

    IF ($ADOAliasesQuery.Count -gt 0 ) {
        Write-Host "Current Proxy addresses found for" $ADObject.SamAccountName -ForegroundColor Cyan
        $ADObject.ProxyAddresses
        Write-Host ""

        foreach ($CurrAItem in $ADOAliasesQuery){
        #   Removing current objects
            Write-Host "Wiping current alias:" $CurrAItem -ForegroundColor Yellow
            Set-ADUser -Identity $User.SAM -Remove @{ ProxyAddresses=$CurrAItem } -ErrorAction SilentlyContinue
        }
    } ELSE { Write-Warning "No addresses were found for $($ADObject.SamAccountName)" }

    Write-Host ""

#   Adding Aliases from CSV

    $NewAliases = ($User.Aliases).Split(",")
    foreach ($NAL in $NewAliases) {
        Write-Host "Adding $NAL... OK!"
        Set-ADUser -Identity $User.SAM -Add @{ ProxyAddresses="smtp:$NAL" } -ErrorAction SilentlyContinue
    }

#   Adding Alias from old primay  
    $ADOPrimaryQuery = $($ADObject.ProxyAddresses | Where-Object {$_ -cmatch "SMTP:"})
    IF (-NOT([string]::IsNullOrWhiteSpace($ADOPrimaryQuery))) {
        $ADOPrimary = $($ADOPrimaryQuery.TrimStart("SMTP:"))
        Get-ADUser $User.SAM -Properties ProxyAddresses | Set-ADUser -Remove @{ ProxyAddresses=$ADOPrimaryQuery }
        Get-ADUser $User.SAM -Properties ProxyAddresses | Set-ADUser -Add @{ ProxyAddresses="smtp:$ADOPrimary" }
    }

#   Adding NEW Primary (SMTP) address
    Write-Host ""
    $NP = "SMTP:" + $($User.UPN)
    Get-ADUser $User.SAM -Properties ProxyAddresses | Set-ADUser -Add @{ ProxyAddresses=$NP } -ErrorAction SilentlyContinue
    Write-Host "Setting new Primay address as $($User.UPN)... OK!"
    Write-Host ""
}

Stop-Transcript