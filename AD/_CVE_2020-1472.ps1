﻿## Create output directory on executiong user's desktop
$date = get-date -Format MMddyyyy
$rootPath = $env:USERPROFILE + '\Desktop\CISA'
$fullPath = $rootPath + '\' + $date

$UpdateList = $fullPath + '\ALERT.csv'

Write-Host -ForegroundColor White ("INFORMATION: DOES OUTPUT PATH EXIST?")
if (Test-Path $rootPath)
    {
        if (test-path $fullPath)
            {
                Write-Host -ForegroundColor White ("INFORMATION: YES, OUTPUT PATH EXISTS")
            }
        else
            {
                Write-Host -ForegroundColor White ("INFORMATION: NO, OUTPUT PATH DOES NOT EXIST")
                Write-Host -ForegroundColor White ("INFORMATION: CREATING OUTPUT DIRECTORY $fullPath")
                mkdir $fullPath
            }
    }
else
    {
        Write-Host -ForegroundColor White ("INFORMATION: NO, OUTPUT PATH DOES NOT EXIST")
        Write-Host -ForegroundColor White ("INFORMATION: CREATING OUTPUT DIRECTORY $fullPath")
        mkdir $fullPath
    }


## Get all DCs in forest
Write-Host -ForegroundColor White ("INFORMATION: Getting list of all DCs in $(Get-ADForest)")
$allDCs = $((Get-ADForest).Domains | %{ Get-ADDomainController -Filter * -Server $_ }) | select hostname
Write-Host -ForegroundColor White ("INFORMATION: List contains $($((Get-ADForest).Domains | %{ Get-ADDomainController -Filter * -Server $_ }).hostname.count) DCs")

## Foreach DC, get Component Based Servicing provided updates and MSI installed updates. Then dump to a common CSV
$allDCs | % {

    $DC = $_.Hostname
    $OS = $(Get-WmiObject -ComputerName $DC -Class Win32_OperatingSystem).caption

    Write-Host -ForegroundColor White ("INFORMATION: Getting updates for $DC")
    Write-Host -ForegroundColor White ("INFORMATION: CBS Updates...")

    Get-WmiObject Win32_quickfixengineering -ComputerName $DC | Select-Object * | ForEach-Object{
        $Hotfix = $_.HotFixID
        $Type = "CBS"

        $result = switch ($Hotfix){   
            KB4571729 { 
                $CBSObj = New-Object -TypeName psobject
                $CBSObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $CBSObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $Hotfix
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True
                $CBSObj | Export-Csv -path $UpdateList -Append -NoTypeInformation 
            }
            KB4571719 { 
                $CBSObj = New-Object -TypeName psobject
                $CBSObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $CBSObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $Hotfix
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True
                $CBSObj | Export-Csv -path $UpdateList -Append -NoTypeInformation 
            }
            KB4571736 { 
                $CBSObj = New-Object -TypeName psobject
                $CBSObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $CBSObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $Hotfix
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True
                $CBSObj | Export-Csv -path $UpdateList -Append -NoTypeInformation 
            }
            KB4571702 { 
                $CBSObj = New-Object -TypeName psobject
                $CBSObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $CBSObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $Hotfix
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True
                $CBSObj | Export-Csv -path $UpdateList -Append -NoTypeInformation 
            }
            KB4571703 { 
                $CBSObj = New-Object -TypeName psobject
                $CBSObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $CBSObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $Hotfix
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True
                $CBSObj | Export-Csv -path $UpdateList -Append -NoTypeInformation 
            }
            KB4571723 { 
                $CBSObj = New-Object -TypeName psobject
                $CBSObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $CBSObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $Hotfix
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True
                $CBSObj | Export-Csv -path $UpdateList -Append -NoTypeInformation 
            }
            KB4571694 { 
                $CBSObj = New-Object -TypeName psobject
                $CBSObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $CBSObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $Hotfix
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True
                $CBSObj | Export-Csv -path $UpdateList -Append -NoTypeInformation 
            }
            KB4565349 { 
                $CBSObj = New-Object -TypeName psobject
                $CBSObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $CBSObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $Hotfix
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True
                $CBSObj | Export-Csv -path $UpdateList -Append -NoTypeInformation 
            }
            KB4565351 { 
                $CBSObj = New-Object -TypeName psobject
                $CBSObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $CBSObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $Hotfix
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True
                $CBSObj | Export-Csv -path $UpdateList -Append -NoTypeInformation 
            }
            KB4566782 { 
                $CBSObj = New-Object -TypeName psobject
                $CBSObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $CBSObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $Hotfix
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True
                $CBSObj | Export-Csv -path $UpdateList -Append -NoTypeInformation 
            }
            KB4577051 { 
                $CBSObj = New-Object -TypeName psobject
                $CBSObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $CBSObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $Hotfix
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True
                $CBSObj | Export-Csv -path $UpdateList -Append -NoTypeInformation 
            }
            KB4577038 { 
                $CBSObj = New-Object -TypeName psobject
                $CBSObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $CBSObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $Hotfix
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True
                $CBSObj | Export-Csv -path $UpdateList -Append -NoTypeInformation 
            }
            KB4577066 { 
                $CBSObj = New-Object -TypeName psobject
                $CBSObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $CBSObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $Hotfix
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True
                $CBSObj | Export-Csv -path $UpdateList -Append -NoTypeInformation 
            }
            KB4577015 { 
                $CBSObj = New-Object -TypeName psobject
                $CBSObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $CBSObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $Hotfix
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True
                $CBSObj | Export-Csv -path $UpdateList -Append -NoTypeInformation 
            }
            KB4577069 { 
                $CBSObj = New-Object -TypeName psobject
                $CBSObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $CBSObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $Hotfix
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True
                $CBSObj | Export-Csv -path $UpdateList -Append -NoTypeInformation 
            }
            KB4574727 { 
                $CBSObj = New-Object -TypeName psobject
                $CBSObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $CBSObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $Hotfix
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True
                $CBSObj | Export-Csv -path $UpdateList -Append -NoTypeInformation 
            }
            KB4577062 { 
                $CBSObj = New-Object -TypeName psobject
                $CBSObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $CBSObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $Hotfix
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True
                $CBSObj | Export-Csv -path $UpdateList -Append -NoTypeInformation 
            }
            KB4571744 { 
                $CBSObj = New-Object -TypeName psobject
                $CBSObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $CBSObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $Hotfix
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True
                $CBSObj | Export-Csv -path $UpdateList -Append -NoTypeInformation 
            }
            KB4571756 { 
                $CBSObj = New-Object -TypeName psobject
                $CBSObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $CBSObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $Hotfix
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True
                $CBSObj | Export-Csv -path $UpdateList -Append -NoTypeInformation 
            }
            KB4571748 { 
                $CBSObj = New-Object -TypeName psobject
                $CBSObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $CBSObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $Hotfix
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True
                $CBSObj | Export-Csv -path $UpdateList -Append -NoTypeInformation 
            }
            KB4570333 { 
                $CBSObj = New-Object -TypeName psobject
                $CBSObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $CBSObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $Hotfix
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $CBSObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True
                $CBSObj | Export-Csv -path $UpdateList -Append -NoTypeInformation 
            }
            
        }
    }

    Write-Host -ForegroundColor White ("INFORMATION: MSI Updates...")
    $((Invoke-Command -ComputerName $DC -ScriptBlock { $Session = New-Object -ComObject Microsoft.Update.Session ; $UpdateSearch = $Session.CreateUpdateSearcher() ; $UpdateSearch.Search("IsInstalled=1").Updates | select Title })) | % {
        $Title = $_.Title
        $Type = "MSI"

        $result = switch -Wildcard ($Title){   
            "*4571729*" {
                $KB = "KB4571729"  
                $MSIObj = New-Object -TypeName psobject
                $MSIObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $MSIObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $KB
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True 
                $MSIObj | Export-Csv -path $UpdateList -Append -NoTypeInformation  
            }
            "*4571719*" {
                $KB = "KB4571719" 
                $MSIObj = New-Object -TypeName psobject
                $MSIObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $MSIObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $KB
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True 
                $MSIObj | Export-Csv -path $UpdateList -Append -NoTypeInformation  
            }
            "*4571736*" {
                $KB = "KB4571736" 
                $MSIObj = New-Object -TypeName psobject
                $MSIObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $MSIObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $KB
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True 
                $MSIObj | Export-Csv -path $UpdateList -Append -NoTypeInformation  
            }
            "*4571702*" {
                $KB = "KB4571702" 
                $MSIObj = New-Object -TypeName psobject
                $MSIObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $MSIObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $KB
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True 
                $MSIObj | Export-Csv -path $UpdateList -Append -NoTypeInformation  
            }
            "*4571703*" {
                $KB = "KB4571703"  
                $MSIObj = New-Object -TypeName psobject
                $MSIObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $MSIObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $KB
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True 
                $MSIObj | Export-Csv -path $UpdateList -Append -NoTypeInformation  
            }
            "*4571723*" {
                $KB = "KB4571723"  
                $MSIObj = New-Object -TypeName psobject
                $MSIObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $MSIObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $KB
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True 
                $MSIObj | Export-Csv -path $UpdateList -Append -NoTypeInformation 
            }
            "*4571694*" {
                $KB = "KB4571694" 
                $MSIObj = New-Object -TypeName psobject
                $MSIObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $MSIObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $KB
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True 
                $MSIObj | Export-Csv -path $UpdateList -Append -NoTypeInformation 
            }
            "*4565349*" {
                $KB = "KB4565349" 
                $MSIObj = New-Object -TypeName psobject
                $MSIObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $MSIObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $KB
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True 
                $MSIObj | Export-Csv -path $UpdateList -Append -NoTypeInformation  
            }
            "*4565351*" {
                $KB = "KB4565351" 
                $MSIObj = New-Object -TypeName psobject
                $MSIObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $MSIObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $KB
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True 
                $MSIObj | Export-Csv -path $UpdateList -Append -NoTypeInformation  
            }
            "*4566782*" {
                $KB = "KB4566782" 
                $MSIObj = New-Object -TypeName psobject
                $MSIObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $MSIObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $KB
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True 
                $MSIObj | Export-Csv -path $UpdateList -Append -NoTypeInformation  
            }
            "*4577051*" {
                $KB = "KB4577051" 
                $MSIObj = New-Object -TypeName psobject
                $MSIObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $MSIObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $KB
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True 
                $MSIObj | Export-Csv -path $UpdateList -Append -NoTypeInformation  
            }
            "*4577038*" {
                $KB = "KB4577038" 
                $MSIObj = New-Object -TypeName psobject
                $MSIObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $MSIObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $KB
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True 
                $MSIObj | Export-Csv -path $UpdateList -Append -NoTypeInformation  
            }
            "*4577066*" {
                $KB = "KB4577066" 
                $MSIObj = New-Object -TypeName psobject
                $MSIObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $MSIObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $KB
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True 
                $MSIObj | Export-Csv -path $UpdateList -Append -NoTypeInformation  
            }
            "*4577015*" {
                $KB = "KB4577015" 
                $MSIObj = New-Object -TypeName psobject
                $MSIObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $MSIObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $KB
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True 
                $MSIObj | Export-Csv -path $UpdateList -Append -NoTypeInformation  
            }
            "*4577069*" {
                $KB = "KB4577069" 
                $MSIObj = New-Object -TypeName psobject
                $MSIObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $MSIObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $KB
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True 
                $MSIObj | Export-Csv -path $UpdateList -Append -NoTypeInformation  
            }
            "*4574727*" {
                $KB = "KB4574727" 
                $MSIObj = New-Object -TypeName psobject
                $MSIObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $MSIObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $KB
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True 
                $MSIObj | Export-Csv -path $UpdateList -Append -NoTypeInformation  
            }
            "*4577062*" {
                $KB = "KB4577062" 
                $MSIObj = New-Object -TypeName psobject
                $MSIObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $MSIObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $KB
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True 
                $MSIObj | Export-Csv -path $UpdateList -Append -NoTypeInformation  
            }
            "*4571744*" {
                $KB = "KB4571744" 
                $MSIObj = New-Object -TypeName psobject
                $MSIObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $MSIObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $KB
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True 
                $MSIObj | Export-Csv -path $UpdateList -Append -NoTypeInformation  
            }
            "*4571756*" {
                $KB = "KB4571756" 
                $MSIObj = New-Object -TypeName psobject
                $MSIObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $MSIObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $KB
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True 
                $MSIObj | Export-Csv -path $UpdateList -Append -NoTypeInformation  
            }
            "*4571748*" {
                $KB = "KB4571748" 
                $MSIObj = New-Object -TypeName psobject
                $MSIObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $MSIObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $KB
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True 
                $MSIObj | Export-Csv -path $UpdateList -Append -NoTypeInformation  
            }
            "*4570333*" {
                $KB = "KB4570333" 
                $MSIObj = New-Object -TypeName psobject
                $MSIObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
                $MSIObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $KB
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
                $MSIObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $True 
                $MSIObj | Export-Csv -path $UpdateList -Append -NoTypeInformation  
            }
           
            
        }
        
    }
    
}

if (Test-Path $UpdateList){
    $CSV = Import-Csv -Path $UpdateList | select DomainController -Unique
    $compare = Compare-Object -ReferenceObject $allDCs.hostname -DifferenceObject $CSV.DomainController
    foreach ($i in $compare) {
        $DC = $i.Inputobject
        $OS = $(Get-WmiObject -ComputerName $DC -Class Win32_OperatingSystem).caption
        $KB = "No KB Installed for CVE-2020-1472"
        $Type = "Not Relevant"
        $Compliance = $False

        $NullDCObj = New-Object -TypeName psobject
        $NullDCObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
        $NullDCObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
        $NullDCObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $KB
        $NullDCObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
        $NullDCObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $Compliance
        $NullDCObj | Export-Csv -path $UpdateList -Append -NoTypeInformation

    }
}
else{
    $allDCs | ForEach-Object {
        $DC = $_.Hostname
        $OS = $(Get-WmiObject -ComputerName $DC -Class Win32_OperatingSystem).caption
        $Type = "Not Relevant"
        $KB = "No KB Installed for CVE-2020-1472"
        $Compliance = $False

        $NullDCObj = New-Object -TypeName psobject
        $NullDCObj | Add-Member -MemberType NoteProperty -Name "DomainController" -Value $DC
        $NullDCObj | Add-Member -MemberType NoteProperty -Name "OperatingSystem" -Value $OS
        $NullDCObj | Add-Member -MemberType NoteProperty -Name "Update" -Value $KB
        $NullDCObj | Add-Member -MemberType NoteProperty -Name "Type" -Value $Type
        $NullDCObj | Add-Member -MemberType NoteProperty -Name "Compliance" -Value $Compliance
        $NullDCObj | Export-Csv -path $UpdateList -Append -NoTypeInformation
    }

}

Write-Host -ForegroundColor White ("INFORMATION: DONE!")