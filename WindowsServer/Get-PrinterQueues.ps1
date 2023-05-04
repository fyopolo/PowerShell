$ADPrinters = Get-AdObject -filter "objectCategory -eq 'printqueue'" -Properties *

$Table = @()

foreach ($Printer in $ADPrinters){

    $Hash =  [ordered]@{
        shortServerName   = $Printer.shortServerName
        printerName       = $Printer.printerName
        portName          = $Printer.portName.split("{").split("}")
        CanonicalName     = $Printer.CanonicalName
        Location          = $Printer.Location
        
                }

    $NewObject = New-Object psobject -Property $Hash
    $Table += $NewObject

}

$Table | Out-GridView

# $file | Export-Excel -Show