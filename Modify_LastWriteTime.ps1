$FilesInSource = @()

$SourceFiles = Get-ChildItem -Path D:\FER-BKP\Desktop -Filter *.txt -Recurse

# Getting original modified TimeStamp values
# THIS PART OF THE SCRIPT MUST RUN BEFORE MIGRATIONWIZ COPY ONEDRIVE FILES

foreach ($File in $SourceFiles) {

    $Hash = [ordered]@{
        FileName        =   $File.Name
        Location        =   $File.DirectoryName
        LastWriteTime   =   $File.LastWriteTime
    }

    $NewObject = New-Object psobject -Property $Hash
    $FilesInSource += $NewObject

}

$FilesInSource


# BELOW PART OF THE SCRIPT MUST RUN AFTER MIGRATIONWIZ HAS FINISHED WITH ONEDRIVE FILES COPY.
# OTHERWISE YOU'LL SCREW EVERYTHING.

# Setting Original Modified TimeStamps (if needed)

$DestinationFiles = Get-ChildItem -Path C:\temp -Filter *.txt -Recurse
$FilesInDestination = @()

foreach ($File in $DestinationFiles) {

    $Hash = [ordered]@{
        FileName        =   $File.Name
        Location        =   $File.DirectoryName
        LastWriteTime   =   $File.LastWriteTime
    }

    $NewObject = New-Object psobject -Property $Hash
    $FilesInDestination += $NewObject

}

$FilesInDestination

$Z = $FilesInSource | Where-Object { $_.FileName -in $FilesInDestination.FileName }

$FilesInDestination.GetValue($Z.FileName)

foreach ($item in $Z) {

$FilesInDestination.GetValue(4)

}


$FinalList = @()
foreach ($File in $FilesInDestination) {

    IF (-NOT ($File.FileName -in $FilesInSource.FileName)) {
        Write-Host "File $($File.FileName) is not a match. Skipping it." -ForegroundColor Gray
    } ELSE {
        Write-Host "A match was found for file $($File.FileName)" -ForegroundColor Green
        $FinalList += $File
        }
}

<#
$FilesComparison = Compare-Object -ReferenceObject $FilesInSource -DifferenceObject $FilesInDestination -IncludeEqual -ExcludeDifferent # | Sort-Object InputObject
$MatchingUsers = $UsersOBJ | Where-Object { $FilesComparison.InputObject -eq $_.SearchingFor }

$C = Compare-Object -ReferenceObject $FilesInSource -DifferenceObject $FilesInDestination -Property LastWriteTime -PassThru | Select FileName, Location, LastWriteTime, SideIndicator | Sort-Object FileName

$Test = Compare-Object -ReferenceObject $FilesInSource -DifferenceObject $FilesInDestination -Property LastWriteTime -IncludeEqual -ExcludeDifferent -PassThru | Select FileName, Location, LastWriteTime, SideIndicator | Sort-Object FileName
$TestCount = ($Test | Measure-Object).Count

$Test.SideIndicator -ne "=="

IF (-NOT($TestCount -eq $FilesInSource.Count)) {
    foreach ($item in $Test) {
        write-host "Different set of files"
    }
}

#>

$Comparison = @()
foreach ($Item in $FinalList) {
    
    Write-Host "Processing item" $($Item.FileName) " // Last Modified Date in destination" $($Item.LastWriteTime)

    $Hash = [ordered]@{
        FileName        =   $Item.FileName
        SourceLocation        =   Get-ChildItem C:\temp\$Item.FileName | % {$_.LastWriteTime = $FilesInSource.LastWriteTime}
        SourceLastWriteTime   =   $File.LastWriteTime
        DestinationLocation   =   $File.Location
        DestinationLastWriteTime = $Item.LastWriteTime
    }

    $NewObject = New-Object psobject -Property $Hash
    $Comparison += $NewObject
}

    IF ($Item -in $FilesInSource -and $_ -match $FilesInSource.LastWriteTime) {
        

    }
    
}

IF ($FinalList.LastWriteTime -eq $FilesInSource.LastWriteTime) {
    Write-Host "All files are good"
    }

$C | Out-GridView

$FilesInSource | select -First 1
$FilesInDestination | select -First 1

# $C.LastWriteTime -eq $FilesInSource.LastWriteTime
$IndexFlag = -1

foreach ($File in $C){
    
    $IndexFlag ++

    Write-Host $File.FileName $File.LastWriteTime

    IF (-NOT ($File.LastWriteTime -eq $C.Item($IndexFlag).LastWriteTime)) {
        # $File.FileName | % {$_.LastWriteTime = $FilesInSource.LastWriteTime}
        Write-Host $File.FileName ": TimeStamp IS NOT equal" } ELSE { Write-Host $File.FileName ": timestamp IS equal" }
    }

}

$FilesInSource.Item($IndexFlag+1).FileName


$FilesInSource | select -First 1
$FilesInDestination | select -First 1 FileName, Location, LastWriteTime

foreach ($Value in $FilesInDestination){

    IF (-NOT $Value.LastWriteTime -eq $FilesInSource.LastWriteTime){
        

        Get-ChildItem C:\temp\B.txt | % {$_.LastWriteTime = $FilesInSource.LastWriteTime}

        Get-ChildItem C:\temp\B.txt | % {$_.LastWriteTime = $(Get-ChildItem D:\FER-BKP\Desktop\B.txt).LastWriteTime}
    }

}

<#

$OriginalDate = "01/27/2017 17:52:25"
$OriginalDate = $FilesInSource.LastWriteTime
$OriginalDate = Get-Date

Get-ChildItem  C:\temp\A.txt | % {$_.LastWriteTime = $OriginalDate}

#>

$Z = $FilesInSource | Where-Object {$_.FileName -in $FilesInDestination.FileName}

foreach ($X in $FinalList) {
    foreach ($G in $Z) {
        IF ($G.LastWriteTime -match $X.LastWriteTime) {
            write-host $G.FileName $G.LastWriteTime
        }
    }
}

Get-ChildItem | Where-Object {$FilesInSource.FileName -like "*$Item.FileName*"} C:\temp\B.txt | % {$_.LastWriteTime = $FilesInSource.LastWriteTime}