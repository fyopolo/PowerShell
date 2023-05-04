# -------------------------------------------------------------------------------
# Script: Deploy-O365-ClickToRun.ps1
# Author: Fernando Yopolo
# Date: 11/27/2019
# Keywords: Office, Click-to-Run
# Comments: Check if computer has already installed any Microsoft Office version
#           Through  a series of checks, script will try to Install Office 365
#           Business Premium either 32/64 bits
#           
#
# Versioning
# 11/27/2019  Initial Script
# -------------------------------------------------------------------------------

clear

# Seting Variables
$RegistryPath = "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration"
$RemotePath = “\\TFSHQ02TS\Software$\ODT”
$x86_WKS = "M:\Install_O365Suite_x86-EN-Workstations.bat"
$x64_WKS = "M:\Install_O365Suite_x64-EN-Workstations.bat"
$x86_RDS = "M:\Install_O365Suite_x86-EN-RDS.bat"
$OSArchitecture = $env:PROCESSOR_ARCHITECTURE

Set-Variable OfficeDetails -Option AllScope
Set-Variable OfficeVersion -Option AllScope
# Set-Variable OfficeArch -Option AllScope

Function Gather-LocalInfo (){

    Write-Host ""
    Write-Host "Attempting to find a local installation of Microsoft Office..." -ForegroundColor Yellow    
    $WORD = @()
    $WORD += Get-ChildItem -Path ${env:ProgramFiles(x86)} -Recurse -Filter "WINWORD.EXE" -ErrorAction Ignore
    $WORD += Get-ChildItem -Path $env:ProgramFiles -Recurse -Filter "WINWORD.EXE" -ErrorAction Ignore

    IF ($WORD){
       Write-Host "Local installation detected. Getting details..."
       Write-Host ""
       SWITCH -Wildcard ($WORD.DirectoryName){
            "*(x86)*" { $OfficeArch = "32Bits" }
            Default { $OfficeArch = "64Bits" }
            }

    SWITCH -Wildcard ($WORD.VersionInfo.ProductVersion){

        "12.0.*" { $OfficeVersion = "2007"}
        "14.0.*" { $OfficeVersion = "2010"}
        "15.0.*" { $OfficeVersion = "2013"}
        "16.0.*" {
            IF(Test-Path $RegistryPath) {
                $Property = (Get-ItemProperty -Path $RegistryPath).ProductReleaseIds
                SWITCH -Wildcard ($Property) {
                    "*O365BusinessRetail*" { $OfficeVersion = "Office365 Business Premium" }
                    "*O365ProPlusRetail*" { $OfficeVersion = "Office365 ProPlus" }
                    "*2016*" { $OfficeVersion = "2016" }
                    "*2019*" { $OfficeVersion = "2019"}
                    }
                }
            
    $DetailsMSG = ("======================================

    Version      : $OfficeVersion
    Architecture : $OfficeArch

======================================
")

    $ExitMSG = "You can use this copy of Microsoft Office with Office 365. Installation will not continue."

            Write-Host $DetailsMSG
            Write-Warning $ExitMSG
            Write-Host ""
            PAUSE
            EXIT
            }
}
    $Hash =  [ordered]@{
        Architecture  = $OfficeArch
        Version       = $OfficeVersion
    }

    $Table = New-Object psobject -Property $Hash
    $OfficeDetails += $Table

    }
    ELSE {
        $OfficeDetails = $null
        Write-Host ""
        Write-Host "No local installation of Microsoft Office detected." -ForegroundColor Yellow
        Write-Host "Installing Office 365. Please wait..." -ForegroundColor Yellow
        Write-Host ""
    }
}

Function Detect-VersionToInstall() {

    $OSArchitecture = $env:PROCESSOR_ARCHITECTURE

    IF ( $OSArchitecture -like "*64*" -and $OfficeDetails.Architecture -eq $null ){
        # OS Architecture is x64 and script didn't detect any Office version installed.
        # Installing Office 365 x64 with Workstations settings.
        Deploy-O365 -Version $x64_WKS
    }

    IF ( $OSArchitecture -like "*86*" -and $OfficeDetails.Architecture -eq $null ){
        # OS Architecture is x64 and script didn't detect any Office version installed.
        # Installing Office 365 x64 with Workstations settings.
        Deploy-O365 -Version $x86_WKS
    }

    IF ( $OSArchitecture -like "*64*" -and $OfficeDetails.Architecture -eq "32Bits" ){
        # OS Architecture is x64 and script detected Office 32Bits installed.
        # Installing Office 365 x86 with Workstations settings.
        Deploy-O365 -Version $x86_WKS
    }

    IF ( $OSArchitecture -like "*64*" -and $OfficeDetails.Architecture -eq "64Bits" ){
        # OS Architecture is x64 and script detected Office 64Bits installed.
        # Installing Office 365 x64 with Workstations settings.
        Deploy-O365 -Version $x64_WKS
    }

    IF ( $OSArchitecture -like "*86*" -and $OfficeDetails.Architecture -eq $null ){
        # OS Architecture is x86 and script detected Office 32Bits installed.
        # Installing Office 365 x86 with Workstations settings.
        Deploy-O365 -Version $x86_WKS
    }

    IF ( $OSArchitecture -like "*86*" -and $OfficeDetails.Architecture -eq "32Bits" ){
        # OS Architecture is x86 and script detected Office 32Bits installed.
        # Installing Office 365 x86 with Workstations settings.
        Deploy-O365 -Version $x86_WKS
    }
}

Function Deploy-O365($Version){
    Write-Host "Mapping network drive..."
    New-PSDrive –Name “M” –PSProvider FileSystem –Root $RemotePath –Persist | Out-Null
    Write-Host "Installing Office365. Please wait..."
    Start-Process -WorkingDirectory "M:" -FilePath $Version -Wait
    Write-Host ""
    Write-Host "Removing network drive..."
    Remove-PSDrive -Name M
    Write-Host ""
    Write-Host "Office 365 Deployment Finished" -ForegroundColor Cyan
    Write-Host ""
    Write-Host ""
}

Function Start-Deployment() {

    Gather-LocalInfo
    Detect-VersionToInstall
    PAUSE
}

Start-Deployment
$OfficeDetails
$OfficeVersion