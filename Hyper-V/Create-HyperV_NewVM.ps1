<# 
.NAME
    HyperV New VM
.SYNOPSIS
    Create Hyper V VM's quickly and easily with this great GUI. 
#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$HyperVVMCreator                 = New-Object system.Windows.Forms.Form
$HyperVVMCreator.ClientSize      = New-Object System.Drawing.Point(744,519)
$HyperVVMCreator.text            = "Hyper V - VM Creator"
$HyperVVMCreator.TopMost         = $false

$VMNameLabel                     = New-Object system.Windows.Forms.Label
$VMNameLabel.text                = "VM Name"
$VMNameLabel.AutoSize            = $false
$VMNameLabel.width               = 115
$VMNameLabel.height              = 20
$VMNameLabel.location            = New-Object System.Drawing.Point(25,25)
$VMNameLabel.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',12)
$VMNameLabel.ForeColor           = [System.Drawing.ColorTranslator]::FromHtml("")

$VMRAMinGBLabel                  = New-Object system.Windows.Forms.Label
$VMRAMinGBLabel.text             = "RAM in GB"
$VMRAMinGBLabel.AutoSize         = $false
$VMRAMinGBLabel.width            = 115
$VMRAMinGBLabel.height           = 20
$VMRAMinGBLabel.location         = New-Object System.Drawing.Point(25,50)
$VMRAMinGBLabel.Font             = New-Object System.Drawing.Font('Segoe UI',12)

$CPUCountLabel                   = New-Object system.Windows.Forms.Label
$CPUCountLabel.text              = "CPU Count"
$CPUCountLabel.AutoSize          = $false
$CPUCountLabel.width             = 115
$CPUCountLabel.height            = 20
$CPUCountLabel.location          = New-Object System.Drawing.Point(25,75)
$CPUCountLabel.Font              = New-Object System.Drawing.Font('Microsoft Sans Serif',12)

$SwitchNameLabel                 = New-Object system.Windows.Forms.Label
$SwitchNameLabel.text            = "Switch Name"
$SwitchNameLabel.AutoSize        = $false
$SwitchNameLabel.width           = 120
$SwitchNameLabel.height          = 20
$SwitchNameLabel.location        = New-Object System.Drawing.Point(411,80)
$SwitchNameLabel.Font            = New-Object System.Drawing.Font('Microsoft Sans Serif',12)

$VLANIDLabel                     = New-Object system.Windows.Forms.Label
$VLANIDLabel.text                = "VLAN ID"
$VLANIDLabel.AutoSize            = $false
$VLANIDLabel.width               = 115
$VLANIDLabel.height              = 20
$VLANIDLabel.location            = New-Object System.Drawing.Point(411,104)
$VLANIDLabel.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',12)

$DriveCLabel                     = New-Object system.Windows.Forms.Label
$DriveCLabel.text                = "C"
$DriveCLabel.AutoSize            = $false
$DriveCLabel.width               = 25
$DriveCLabel.height              = 14
$DriveCLabel.location            = New-Object System.Drawing.Point(25,222)
$DriveCLabel.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$DriveDLabel                     = New-Object system.Windows.Forms.Label
$DriveDLabel.text                = "D"
$DriveDLabel.AutoSize            = $false
$DriveDLabel.width               = 25
$DriveDLabel.height              = 14
$DriveDLabel.location            = New-Object System.Drawing.Point(25,242)
$DriveDLabel.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$DriveELabel                     = New-Object system.Windows.Forms.Label
$DriveELabel.text                = "E"
$DriveELabel.AutoSize            = $false
$DriveELabel.width               = 25
$DriveELabel.height              = 14
$DriveELabel.location            = New-Object System.Drawing.Point(25,262)
$DriveELabel.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$DriveFLabel                     = New-Object system.Windows.Forms.Label
$DriveFLabel.text                = "F"
$DriveFLabel.AutoSize            = $false
$DriveFLabel.width               = 25
$DriveFLabel.height              = 14
$DriveFLabel.location            = New-Object System.Drawing.Point(25,282)
$DriveFLabel.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$DriveGLabel                     = New-Object system.Windows.Forms.Label
$DriveGLabel.text                = "G"
$DriveGLabel.AutoSize            = $false
$DriveGLabel.width               = 25
$DriveGLabel.height              = 14
$DriveGLabel.location            = New-Object System.Drawing.Point(25,302)
$DriveGLabel.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$DriveHLabel                     = New-Object system.Windows.Forms.Label
$DriveHLabel.text                = "H"
$DriveHLabel.AutoSize            = $false
$DriveHLabel.width               = 25
$DriveHLabel.height              = 14
$DriveHLabel.location            = New-Object System.Drawing.Point(25,322)
$DriveHLabel.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$DriveILabel                     = New-Object system.Windows.Forms.Label
$DriveILabel.text                = "I"
$DriveILabel.AutoSize            = $false
$DriveILabel.width               = 20
$DriveILabel.height              = 14
$DriveILabel.location            = New-Object System.Drawing.Point(27,342)
$DriveILabel.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$DriveKLabel                     = New-Object system.Windows.Forms.Label
$DriveKLabel.text                = "K"
$DriveKLabel.AutoSize            = $false
$DriveKLabel.width               = 25
$DriveKLabel.height              = 14
$DriveKLabel.location            = New-Object System.Drawing.Point(150,222)
$DriveKLabel.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$DriveLLabel                     = New-Object system.Windows.Forms.Label
$DriveLLabel.text                = "L"
$DriveLLabel.AutoSize            = $false
$DriveLLabel.width               = 25
$DriveLLabel.height              = 14
$DriveLLabel.location            = New-Object System.Drawing.Point(150,242)
$DriveLLabel.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$DriveSLabel                     = New-Object system.Windows.Forms.Label
$DriveSLabel.text                = "S"
$DriveSLabel.AutoSize            = $false
$DriveSLabel.width               = 25
$DriveSLabel.height              = 14
$DriveSLabel.location            = New-Object System.Drawing.Point(275,222)
$DriveSLabel.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$DriveMLabel                     = New-Object system.Windows.Forms.Label
$DriveMLabel.text                = "M"
$DriveMLabel.AutoSize            = $false
$DriveMLabel.width               = 25
$DriveMLabel.height              = 14
$DriveMLabel.location            = New-Object System.Drawing.Point(150,262)
$DriveMLabel.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$DriveNLabel                     = New-Object system.Windows.Forms.Label
$DriveNLabel.text                = "N"
$DriveNLabel.AutoSize            = $false
$DriveNLabel.width               = 25
$DriveNLabel.height              = 14
$DriveNLabel.location            = New-Object System.Drawing.Point(150,282)
$DriveNLabel.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$DriveOLabel                     = New-Object system.Windows.Forms.Label
$DriveOLabel.text                = "O"
$DriveOLabel.AutoSize            = $false
$DriveOLabel.width               = 25
$DriveOLabel.height              = 14
$DriveOLabel.location            = New-Object System.Drawing.Point(150,302)
$DriveOLabel.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$DrivePLabel                     = New-Object system.Windows.Forms.Label
$DrivePLabel.text                = "P"
$DrivePLabel.AutoSize            = $false
$DrivePLabel.width               = 25
$DrivePLabel.height              = 14
$DrivePLabel.location            = New-Object System.Drawing.Point(150,322)
$DrivePLabel.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$DriveQLabel                     = New-Object system.Windows.Forms.Label
$DriveQLabel.text                = "Q"
$DriveQLabel.AutoSize            = $false
$DriveQLabel.width               = 25
$DriveQLabel.height              = 14
$DriveQLabel.location            = New-Object System.Drawing.Point(150,342)
$DriveQLabel.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$DriveRLabel                     = New-Object system.Windows.Forms.Label
$DriveRLabel.text                = "R"
$DriveRLabel.AutoSize            = $false
$DriveRLabel.width               = 25
$DriveRLabel.height              = 14
$DriveRLabel.location            = New-Object System.Drawing.Point(150,362)
$DriveRLabel.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$DriveTLabel                     = New-Object system.Windows.Forms.Label
$DriveTLabel.text                = "T"
$DriveTLabel.AutoSize            = $false
$DriveTLabel.width               = 25
$DriveTLabel.height              = 14
$DriveTLabel.location            = New-Object System.Drawing.Point(275,242)
$DriveTLabel.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$DriveULabel                     = New-Object system.Windows.Forms.Label
$DriveULabel.text                = "U"
$DriveULabel.AutoSize            = $false
$DriveULabel.width               = 25
$DriveULabel.height              = 14
$DriveULabel.location            = New-Object System.Drawing.Point(275,262)
$DriveULabel.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$DriveVLabel                     = New-Object system.Windows.Forms.Label
$DriveVLabel.text                = "V"
$DriveVLabel.AutoSize            = $false
$DriveVLabel.width               = 25
$DriveVLabel.height              = 14
$DriveVLabel.location            = New-Object System.Drawing.Point(275,282)
$DriveVLabel.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$DriveWLabel                     = New-Object system.Windows.Forms.Label
$DriveWLabel.text                = "W"
$DriveWLabel.AutoSize            = $false
$DriveWLabel.width               = 25
$DriveWLabel.height              = 14
$DriveWLabel.location            = New-Object System.Drawing.Point(275,302)
$DriveWLabel.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$GenerationLabel                 = New-Object system.Windows.Forms.Label
$GenerationLabel.text            = "Generation"
$GenerationLabel.AutoSize        = $false
$GenerationLabel.width           = 115
$GenerationLabel.height          = 20
$GenerationLabel.location        = New-Object System.Drawing.Point(24,104)
$GenerationLabel.Font            = New-Object System.Drawing.Font('Microsoft Sans Serif',12)

$DriveXLabel                     = New-Object system.Windows.Forms.Label
$DriveXLabel.text                = "X"
$DriveXLabel.AutoSize            = $false
$DriveXLabel.width               = 25
$DriveXLabel.height              = 14
$DriveXLabel.location            = New-Object System.Drawing.Point(275,322)
$DriveXLabel.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10,[System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
$DriveXLabel.ForeColor           = [System.Drawing.ColorTranslator]::FromHtml("#d0021b")

$DriveJLabel                     = New-Object system.Windows.Forms.Label
$DriveJLabel.text                = "J"
$DriveJLabel.AutoSize            = $false
$DriveJLabel.width               = 25
$DriveJLabel.height              = 14
$DriveJLabel.location            = New-Object System.Drawing.Point(25,362)
$DriveJLabel.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$DriveYLabel                     = New-Object system.Windows.Forms.Label
$DriveYLabel.text                = "Y"
$DriveYLabel.AutoSize            = $false
$DriveYLabel.width               = 25
$DriveYLabel.height              = 14
$DriveYLabel.location            = New-Object System.Drawing.Point(275,342)
$DriveYLabel.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$DriveZLabel                     = New-Object system.Windows.Forms.Label
$DriveZLabel.text                = "Z"
$DriveZLabel.AutoSize            = $false
$DriveZLabel.width               = 25
$DriveZLabel.height              = 14
$DriveZLabel.location            = New-Object System.Drawing.Point(275,362)
$DriveZLabel.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$VMNameTextBox                   = New-Object system.Windows.Forms.TextBox
$VMNameTextBox.multiline         = $false
$VMNameTextBox.width             = 220
$VMNameTextBox.height            = 10
$VMNameTextBox.location          = New-Object System.Drawing.Point(150,25)
$VMNameTextBox.Font              = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$RAMinGBTextBox                  = New-Object system.Windows.Forms.TextBox
$RAMinGBTextBox.multiline        = $false
$RAMinGBTextBox.text             = "4"
$RAMinGBTextBox.width            = 40
$RAMinGBTextBox.height           = 10
$RAMinGBTextBox.location         = New-Object System.Drawing.Point(149,50)
$RAMinGBTextBox.Font             = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$CPUCountTextBox                 = New-Object system.Windows.Forms.TextBox
$CPUCountTextBox.multiline       = $false
$CPUCountTextBox.text            = "2"
$CPUCountTextBox.width           = 40
$CPUCountTextBox.height          = 10
$CPUCountTextBox.location        = New-Object System.Drawing.Point(150,75)
$CPUCountTextBox.Font            = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$VLANIDTextBox                   = New-Object system.Windows.Forms.TextBox
$VLANIDTextBox.multiline         = $false
$VLANIDTextBox.text              = "165"
$VLANIDTextBox.width             = 40
$VLANIDTextBox.height            = 10
$VLANIDTextBox.location          = New-Object System.Drawing.Point(536,105)
$VLANIDTextBox.Font              = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$CSizeTextBox                    = New-Object system.Windows.Forms.TextBox
$CSizeTextBox.multiline          = $false
$CSizeTextBox.text               = "85"
$CSizeTextBox.width              = 40
$CSizeTextBox.height             = 14
$CSizeTextBox.location           = New-Object System.Drawing.Point(50,221)
$CSizeTextBox.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',7)

$Gen1RadioButton                 = New-Object system.Windows.Forms.RadioButton
$Gen1RadioButton.text            = "Gen 1"
$Gen1RadioButton.AutoSize        = $false
$Gen1RadioButton.width           = 60
$Gen1RadioButton.height          = 20
$Gen1RadioButton.location        = New-Object System.Drawing.Point(11,12)
$Gen1RadioButton.Font            = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Gen2RadioButton                 = New-Object system.Windows.Forms.RadioButton
$Gen2RadioButton.text            = "Gen 2"
$Gen2RadioButton.AutoSize        = $false
$Gen2RadioButton.width           = 60
$Gen2RadioButton.height          = 20
$Gen2RadioButton.location        = New-Object System.Drawing.Point(75,12)
$Gen2RadioButton.Font            = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$DSizeTextBox                    = New-Object system.Windows.Forms.TextBox
$DSizeTextBox.multiline          = $false
$DSizeTextBox.width              = 40
$DSizeTextBox.height             = 14
$DSizeTextBox.location           = New-Object System.Drawing.Point(50,242)
$DSizeTextBox.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',7)

$ESizeTextBox                    = New-Object system.Windows.Forms.TextBox
$ESizeTextBox.multiline          = $false
$ESizeTextBox.width              = 40
$ESizeTextBox.height             = 14
$ESizeTextBox.location           = New-Object System.Drawing.Point(50,262)
$ESizeTextBox.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',7)

$FSizeTextBox                    = New-Object system.Windows.Forms.TextBox
$FSizeTextBox.multiline          = $false
$FSizeTextBox.width              = 40
$FSizeTextBox.height             = 14
$FSizeTextBox.location           = New-Object System.Drawing.Point(50,282)
$FSizeTextBox.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',7)

$GSizeTextBox                    = New-Object system.Windows.Forms.TextBox
$GSizeTextBox.multiline          = $false
$GSizeTextBox.width              = 40
$GSizeTextBox.height             = 14
$GSizeTextBox.location           = New-Object System.Drawing.Point(50,302)
$GSizeTextBox.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',7)

$HSizeTextBox                    = New-Object system.Windows.Forms.TextBox
$HSizeTextBox.multiline          = $false
$HSizeTextBox.width              = 40
$HSizeTextBox.height             = 14
$HSizeTextBox.location           = New-Object System.Drawing.Point(50,322)
$HSizeTextBox.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',7)

$ISizeTextBox                    = New-Object system.Windows.Forms.TextBox
$ISizeTextBox.multiline          = $false
$ISizeTextBox.width              = 40
$ISizeTextBox.height             = 14
$ISizeTextBox.location           = New-Object System.Drawing.Point(50,342)
$ISizeTextBox.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',7)

$JSIzeTextBox                    = New-Object system.Windows.Forms.TextBox
$JSIzeTextBox.multiline          = $false
$JSIzeTextBox.width              = 40
$JSIzeTextBox.height             = 14
$JSIzeTextBox.location           = New-Object System.Drawing.Point(50,362)
$JSIzeTextBox.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',7)

$KSizeTextBox                    = New-Object system.Windows.Forms.TextBox
$KSizeTextBox.multiline          = $false
$KSizeTextBox.width              = 40
$KSizeTextBox.height             = 14
$KSizeTextBox.location           = New-Object System.Drawing.Point(175,222)
$KSizeTextBox.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',7)

$LSizeTextBox                    = New-Object system.Windows.Forms.TextBox
$LSizeTextBox.multiline          = $false
$LSizeTextBox.width              = 40
$LSizeTextBox.height             = 14
$LSizeTextBox.location           = New-Object System.Drawing.Point(175,242)
$LSizeTextBox.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',7)

$MSizeTextBox                    = New-Object system.Windows.Forms.TextBox
$MSizeTextBox.multiline          = $false
$MSizeTextBox.width              = 40
$MSizeTextBox.height             = 14
$MSizeTextBox.location           = New-Object System.Drawing.Point(175,262)
$MSizeTextBox.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',7)

$NSizeTextBox                    = New-Object system.Windows.Forms.TextBox
$NSizeTextBox.multiline          = $false
$NSizeTextBox.width              = 40
$NSizeTextBox.height             = 14
$NSizeTextBox.location           = New-Object System.Drawing.Point(175,282)
$NSizeTextBox.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',7)

$OSizeTextBox                    = New-Object system.Windows.Forms.TextBox
$OSizeTextBox.multiline          = $false
$OSizeTextBox.width              = 40
$OSizeTextBox.height             = 14
$OSizeTextBox.location           = New-Object System.Drawing.Point(175,302)
$OSizeTextBox.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',7)

$PSizeTextBox                    = New-Object system.Windows.Forms.TextBox
$PSizeTextBox.multiline          = $false
$PSizeTextBox.width              = 40
$PSizeTextBox.height             = 14
$PSizeTextBox.location           = New-Object System.Drawing.Point(175,322)
$PSizeTextBox.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',7)

$QSizeTextBox                    = New-Object system.Windows.Forms.TextBox
$QSizeTextBox.multiline          = $false
$QSizeTextBox.width              = 40
$QSizeTextBox.height             = 14
$QSizeTextBox.location           = New-Object System.Drawing.Point(175,342)
$QSizeTextBox.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',7)

$RSizeTextBox                    = New-Object system.Windows.Forms.TextBox
$RSizeTextBox.multiline          = $false
$RSizeTextBox.width              = 40
$RSizeTextBox.height             = 14
$RSizeTextBox.location           = New-Object System.Drawing.Point(175,362)
$RSizeTextBox.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',7)

$SSizeTextBox                    = New-Object system.Windows.Forms.TextBox
$SSizeTextBox.multiline          = $false
$SSizeTextBox.width              = 40
$SSizeTextBox.height             = 14
$SSizeTextBox.location           = New-Object System.Drawing.Point(300,222)
$SSizeTextBox.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',7)

$TSizeTextBox                    = New-Object system.Windows.Forms.TextBox
$TSizeTextBox.multiline          = $false
$TSizeTextBox.width              = 40
$TSizeTextBox.height             = 14
$TSizeTextBox.location           = New-Object System.Drawing.Point(300,242)
$TSizeTextBox.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',7)

$USizeTextBox                    = New-Object system.Windows.Forms.TextBox
$USizeTextBox.multiline          = $false
$USizeTextBox.width              = 40
$USizeTextBox.height             = 14
$USizeTextBox.location           = New-Object System.Drawing.Point(300,262)
$USizeTextBox.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',7)

$VSizeTextBox                    = New-Object system.Windows.Forms.TextBox
$VSizeTextBox.multiline          = $false
$VSizeTextBox.width              = 40
$VSizeTextBox.height             = 14
$VSizeTextBox.location           = New-Object System.Drawing.Point(300,282)
$VSizeTextBox.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',7)

$WSizeTextBox                    = New-Object system.Windows.Forms.TextBox
$WSizeTextBox.multiline          = $false
$WSizeTextBox.width              = 40
$WSizeTextBox.height             = 14
$WSizeTextBox.location           = New-Object System.Drawing.Point(300,302)
$WSizeTextBox.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',7)

$XSizeTextBox                    = New-Object system.Windows.Forms.TextBox
$XSizeTextBox.multiline          = $false
$XSizeTextBox.width              = 40
$XSizeTextBox.height             = 14
$XSizeTextBox.location           = New-Object System.Drawing.Point(300,322)
$XSizeTextBox.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',7)

$YSizeTextBox                    = New-Object system.Windows.Forms.TextBox
$YSizeTextBox.multiline          = $false
$YSizeTextBox.width              = 40
$YSizeTextBox.height             = 14
$YSizeTextBox.location           = New-Object System.Drawing.Point(300,342)
$YSizeTextBox.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',7)

$ZSizeTextBox                    = New-Object system.Windows.Forms.TextBox
$ZSizeTextBox.multiline          = $false
$ZSizeTextBox.width              = 40
$ZSizeTextBox.height             = 14
$ZSizeTextBox.location           = New-Object System.Drawing.Point(300,362)
$ZSizeTextBox.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',7)

$BootISOLabel                    = New-Object system.Windows.Forms.Label
$BootISOLabel.text               = "Boot ISO"
$BootISOLabel.AutoSize           = $true
$BootISOLabel.width              = 25
$BootISOLabel.height             = 10
$BootISOLabel.location           = New-Object System.Drawing.Point(22,140)
$BootISOLabel.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$BootISOTextBox                  = New-Object system.Windows.Forms.TextBox
$BootISOTextBox.multiline        = $false
$BootISOTextBox.width            = 567
$BootISOTextBox.height           = 20
$BootISOTextBox.location         = New-Object System.Drawing.Point(83,140)
$BootISOTextBox.Font             = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$BootISOBrowseButton             = New-Object system.Windows.Forms.Button
$BootISOBrowseButton.text        = "Browse"
$BootISOBrowseButton.width       = 60
$BootISOBrowseButton.height      = 30
$BootISOBrowseButton.location    = New-Object System.Drawing.Point(662,133)
$BootISOBrowseButton.Font        = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$VHDCommentLabel                 = New-Object system.Windows.Forms.Label
$VHDCommentLabel.text            = "Sub Folder will be created based on the VM Name"
$VHDCommentLabel.AutoSize        = $true
$VHDCommentLabel.width           = 25
$VHDCommentLabel.height          = 10
$VHDCommentLabel.location        = New-Object System.Drawing.Point(426,187)
$VHDCommentLabel.Font            = New-Object System.Drawing.Font('Microsoft Sans Serif',8)

$VHDRootTextBox                  = New-Object system.Windows.Forms.TextBox
$VHDRootTextBox.multiline        = $false
$VHDRootTextBox.text             = "D:\Hyper-V"
$VHDRootTextBox.width            = 249
$VHDRootTextBox.height           = 20
$VHDRootTextBox.location         = New-Object System.Drawing.Point(91,183)
$VHDRootTextBox.Font             = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$VHDRootLabel                    = New-Object system.Windows.Forms.Label
$VHDRootLabel.text               = "VHD Root"
$VHDRootLabel.AutoSize           = $true
$VHDRootLabel.width              = 25
$VHDRootLabel.height             = 10
$VHDRootLabel.location           = New-Object System.Drawing.Point(22,183)
$VHDRootLabel.Font               = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$VHDRootBrowseButton             = New-Object system.Windows.Forms.Button
$VHDRootBrowseButton.text        = "Browse"
$VHDRootBrowseButton.width       = 60
$VHDRootBrowseButton.height      = 30
$VHDRootBrowseButton.location    = New-Object System.Drawing.Point(352,177)
$VHDRootBrowseButton.Font        = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$FeelingLuckyButton              = New-Object system.Windows.Forms.Button
$FeelingLuckyButton.text         = "Im Feeling Lucky Create VM"
$FeelingLuckyButton.width        = 359
$FeelingLuckyButton.height       = 70
$FeelingLuckyButton.location     = New-Object System.Drawing.Point(366,311)
$FeelingLuckyButton.Font         = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$FeelingLuckyButton.BackColor    = [System.Drawing.ColorTranslator]::FromHtml("#b8e986")

$DoSomeChecksButton              = New-Object system.Windows.Forms.Button
$DoSomeChecksButton.text         = "Do Some Checks"
$DoSomeChecksButton.width        = 359
$DoSomeChecksButton.height       = 66
$DoSomeChecksButton.location     = New-Object System.Drawing.Point(366,222)
$DoSomeChecksButton.Font         = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$DoSomeChecksButton.BackColor    = [System.Drawing.ColorTranslator]::FromHtml("#b8e986")

$ResultHeadingLabel              = New-Object system.Windows.Forms.Label
$ResultHeadingLabel.text         = "Last Result"
$ResultHeadingLabel.AutoSize     = $true
$ResultHeadingLabel.width        = 25
$ResultHeadingLabel.height       = 10
$ResultHeadingLabel.location     = New-Object System.Drawing.Point(334,403)
$ResultHeadingLabel.Font         = New-Object System.Drawing.Font('Microsoft Sans Serif',12)

$LastResultLabel                 = New-Object system.Windows.Forms.Label
$LastResultLabel.AutoSize        = $false
$LastResultLabel.width           = 700
$LastResultLabel.height          = 59
$LastResultLabel.location        = New-Object System.Drawing.Point(24,429)
$LastResultLabel.Font            = New-Object System.Drawing.Font('Microsoft Sans Serif',19)
$LastResultLabel.BackColor       = [System.Drawing.ColorTranslator]::FromHtml("#b8e986")

$Groupbox1                       = New-Object system.Windows.Forms.Groupbox
$Groupbox1.height                = 36
$Groupbox1.width                 = 149
$Groupbox1.location              = New-Object System.Drawing.Point(149,96)

$SwitchNameComboBox              = New-Object system.Windows.Forms.ComboBox
$SwitchNameComboBox.text         = "Switch Name"
$SwitchNameComboBox.width        = 157
$SwitchNameComboBox.height       = 20
$SwitchNameComboBox.location     = New-Object System.Drawing.Point(537,80)
$SwitchNameComboBox.Font         = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$HyperVVMCreator.controls.AddRange(@($VMNameLabel,$VMRAMinGBLabel,$CPUCountLabel,$SwitchNameLabel,$VLANIDLabel,$DriveCLabel,$DriveDLabel,$DriveELabel,$DriveFLabel,$DriveGLabel,$DriveHLabel,$DriveILabel,$DriveKLabel,$DriveLLabel,$DriveSLabel,$DriveMLabel,$DriveNLabel,$DriveOLabel,$DrivePLabel,$DriveQLabel,$DriveRLabel,$DriveTLabel,$DriveULabel,$DriveVLabel,$DriveWLabel,$GenerationLabel,$DriveXLabel,$DriveJLabel,$DriveYLabel,$DriveZLabel,$VMNameTextBox,$RAMinGBTextBox,$CPUCountTextBox,$VLANIDTextBox,$CSizeTextBox,$DSizeTextBox,$ESizeTextBox,$FSizeTextBox,$GSizeTextBox,$HSizeTextBox,$ISizeTextBox,$JSIzeTextBox,$KSizeTextBox,$LSizeTextBox,$MSizeTextBox,$NSizeTextBox,$OSizeTextBox,$PSizeTextBox,$QSizeTextBox,$RSizeTextBox,$SSizeTextBox,$TSizeTextBox,$USizeTextBox,$VSizeTextBox,$WSizeTextBox,$XSizeTextBox,$YSizeTextBox,$ZSizeTextBox,$BootISOLabel,$BootISOTextBox,$BootISOBrowseButton,$VHDCommentLabel,$VHDRootTextBox,$VHDRootLabel,$VHDRootBrowseButton,$FeelingLuckyButton,$DoSomeChecksButton,$ResultHeadingLabel,$LastResultLabel,$Groupbox1,$SwitchNameComboBox))
$Groupbox1.controls.AddRange(@($Gen1RadioButton,$Gen2RadioButton))

$DoSomeChecksButton.Add_Click({ Run-Checks })
$RAMinGBTextBox.Add_TextChanged({ remove-letters })
$CPUCountTextBox.Add_TextChanged({ remove-letters })
$VLANIDTextBox.Add_TextChanged({ remove-letters })
$CSizeTextBox.Add_TextChanged({ remove-letters })
$DSizeTextBox.Add_TextChanged({ remove-letters })
$ESizeTextBox.Add_TextChanged({ remove-letters })
$FSizeTextBox.Add_TextChanged({ remove-letters })
$GSizeTextBox.Add_TextChanged({ remove-letters })
$HSizeTextBox.Add_TextChanged({ remove-letters })
$ISizeTextBox.Add_TextChanged({ remove-letters })
$JSIzeTextBox.Add_TextChanged({ remove-letters })
$KSizeTextBox.Add_TextChanged({ remove-letters })
$LSizeTextBox.Add_TextChanged({ remove-letters })
$MSizeTextBox.Add_TextChanged({ remove-letters })
$NSizeTextBox.Add_TextChanged({ remove-letters })
$OSizeTextBox.Add_TextChanged({ remove-letters })
$PSizeTextBox.Add_TextChanged({ remove-letters })
$QSizeTextBox.Add_TextChanged({ remove-letters })
$RSizeTextBox.Add_TextChanged({ remove-letters })
$SSizeTextBox.Add_TextChanged({ remove-letters })
$TSizeTextBox.Add_TextChanged({ remove-letters })
$USizeTextBox.Add_TextChanged({ remove-letters })
$VSizeTextBox.Add_TextChanged({ remove-letters })
$WSizeTextBox.Add_TextChanged({ remove-letters })
$XSizeTextBox.Add_TextChanged({ remove-letters })
$YSizeTextBox.Add_TextChanged({ remove-letters })
$ZSizeTextBox.Add_TextChanged({ remove-letters })
$BootISOBrowseButton.Add_Click({ Get-BootISOFileName })
$VHDRootBrowseButton.Add_Click({ Get-VHDRootPath })
$FeelingLuckyButton.Add_Click({ Create-VMs })
$VMNameTextBox.Add_TextChanged({ Remove-Characters })


#Write your logic code here

Write-Host "Script Started ok, Please look for window under this window"

if ($Gen1RadioButton.Checked -eq $False -and $Gen1RadioButton.Checked -eq $False) {$Gen1RadioButton.Checked = $True}

$HyperVVMCreator.top = $True

#Find Host Ram
$HostRam = Get-WMIObject -class Win32_PhysicalMemory | Measure-Object -Property capacity -Sum | % {[Math]::Round(($_.sum / 1GB *0.97),0)-1}

function Test-IsAdmin {
    try {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal -ArgumentList $identity
        return $principal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator )
    } catch {
        throw "Failed to determine if the current user has elevated privileges. The error was: '{0}'." -f $_
    }
}

#Get the name on the HyperV Host
$HostName=hostname

#Check if Admin Rights
if (-not(Test-IsAdmin)) {$LastResultLabel.text = "Please Rerun this Powershell Script with Admin Rights"}
if (Test-IsAdmin) {$LastResultLabel.text = ""}

function Remove-Characters
{
$VMNameTextBox.Text = $VMNameTextBox.Text -replace '[~!@#$%^&*_+{}:"<>()?/.,`;+ ]',''
}

$SwitchList = Get-VMSwitch | Select name
foreach ($switch in $SwitchList) {$SwitchNameComboBox.Items.Add($switch.Name) | out-null }
$SwitchNameComboBox.SelectedIndex = 0

function Run-Checks
{

$VMHostInfo=Get-VMHost

#Paths and Gen Sets    
if ($BootISOTextBox.Text -ne "") {$ISOFilePathValid = test-path $BootISOTextBox.Text}
if ($VHDRootTextBox.Text -ne "") {$VHDBootPathValid = test-path $VHDRootTextBox.Text}
if ($Gen1RadioButton.Checked -eq $True) {$VMGeneration = 1}
if ($Gen2RadioButton.Checked -eq $True) {$VMGeneration = 2}
if ($VMNameTextBox.TextLength -ne 0) {$VMExists = Get-VM -name $VMNameTextBox.Text -ErrorAction SilentlyContinue}

if (-not(Test-IsAdmin)) {$LastResultLabel.text = "Please Rerun this Powershell Script with Admin Rights"}
elseif (-not (Test-Path $VMHostInfo.VirtualMachinePath) ) {$LastResultLabel.text = "Default Virtual Machine path is not valid in HyperV Host Settings"}
elseif (-not (Test-Path $VMHostInfo.VirtualHardDiskPath) ) {$LastResultLabel.text = "Default Virtual Harddisk path is not valid in HyperV Host Settings"}
elseif ($VMExists) {$LastResultLabel.text = "VM with that name already exists"}
elseif ($VMNameTextBox.TextLength -eq 0) {$LastResultLabel.text = "Please Enter VM Name"}
elseif ($SwitchNameComboBox.Text -eq "Switch Name") {$LastResultLabel.text = "Please Select a Switch Name"}
elseif ($ISOFilePathValid -eq $False) {$LastResultLabel.text = "ISO File path in invaild"}
elseif ($VHDRootTextBox.Text -eq "") {$LastResultLabel.text = "VHD Root path is blank.  Please enter a valid path"}
elseif ($VHDBootPathValid -eq $False) {$LastResultLabel.text = "VHD Root path in invaild"}
elseif ($RAMinGBTextBox.TextLength -eq 0) {$LastResultLabel.text = "Please Enter Ram Amount in GB"}
elseif ([int64]$RAMinGBTextBox.Text -lt 1) {$LastResultLabel.text = "Please Enter Ram Amount of at least 1GB"}
elseif ([int64]$RAMinGBTextBox.Text -gt $HostRam) {$LastResultLabel.text = "Please Enter Ram Amount of "+ $HostRam + "GB or bellow"}
elseif ($CPUCountTextBox.TextLength -eq 0) {$LastResultLabel.text = "Please Enter a CPU Count"}
elseif ([int64]$CPUCountTextBox.TextLength -eq 0) {$LastResultLabel.text = "Please Enter a CPU Count"}
elseif ([int64]$CPUCountTextBox.Text -lt 1) {$LastResultLabel.text = "Please Enter a CPU Count of at least 1"}
elseif ([int64]$CPUCountTextBox.Text -gt 64) {$LastResultLabel.text = "Please Enter a CPU Count of 64 or below"}
elseif ([int64]$VLANIDTextBox.Text -gt 999 -or [int64]$VLANIDTextBox.Text -lt 1) {$LastResultLabel.text = "Please Enter VLAN ID between 1 and 999"}
elseif ([int64]$CSizeTextBox.Text -gt 65536) {$LastResultLabel.text = "For C Drive please Enter a Disk Size of 65536 GB or below"}
elseif ([int64]$DSizeTextBox.Text -gt 65536) {$LastResultLabel.text = "For D Drive please Enter a Disk Size of 65536 GB or below"}
elseif ([int64]$ESizeTextBox.Text -gt 65536) {$LastResultLabel.text = "For E Drive please Enter a Disk Size of 65536 GB or below"}
elseif ([int64]$FSizeTextBox.Text -gt 65536) {$LastResultLabel.text = "For F Drive please Enter a Disk Size of 65536 GB or below"}
elseif ([int64]$GSizeTextBox.Text -gt 65536) {$LastResultLabel.text = "For G Drive please Enter a Disk Size of 65536 GB or below"}
elseif ([int64]$HSizeTextBox.Text -gt 65536) {$LastResultLabel.text = "For H Drive please Enter a Disk Size of 65536 GB or below"}
elseif ([int64]$ISizeTextBox.Text -gt 65536) {$LastResultLabel.text = "For I Drive please Enter a Disk Size of 65536 GB or below"}
elseif ([int64]$JSizeTextBox.Text -gt 65536) {$LastResultLabel.text = "For J Drive please Enter a Disk Size of 65536 GB or below"}
elseif ([int64]$KSizeTextBox.Text -gt 65536) {$LastResultLabel.text = "For K Drive please Enter a Disk Size of 65536 GB or below"}
elseif ([int64]$LSizeTextBox.Text -gt 65536) {$LastResultLabel.text = "For K Drive please Enter a Disk Size of 65536 GB or below"}
elseif ([int64]$MSizeTextBox.Text -gt 65536) {$LastResultLabel.text = "For M Drive please Enter a Disk Size of 65536 GB or below"}
elseif ([int64]$NSizeTextBox.Text -gt 65536) {$LastResultLabel.text = "For N Drive please Enter a Disk Size of 65536 GB or below"}
elseif ([int64]$OSizeTextBox.Text -gt 65536) {$LastResultLabel.text = "For O Drive please Enter a Disk Size of 65536 GB or below"}
elseif ([int64]$PSizeTextBox.Text -gt 65536) {$LastResultLabel.text = "For P Drive please Enter a Disk Size of 65536 GB or below"}
elseif ([int64]$QSizeTextBox.Text -gt 65536) {$LastResultLabel.text = "For Q Drive please Enter a Disk Size of 65536 GB or below"}
elseif ([int64]$RSizeTextBox.Text -gt 65536) {$LastResultLabel.text = "For R Drive please Enter a Disk Size of 65536 GB or below"}
elseif ([int64]$SSizeTextBox.Text -gt 65536) {$LastResultLabel.text = "For S Drive please Enter a Disk Size of 65536 GB or below"}
elseif ([int64]$TSizeTextBox.Text -gt 65536) {$LastResultLabel.text = "For T Drive please Enter a Disk Size of 65536 GB or below"}
elseif ([int64]$USizeTextBox.Text -gt 65536) {$LastResultLabel.text = "For U Drive please Enter a Disk Size of 65536 GB or below"}
elseif ([int64]$VSizeTextBox.Text -gt 65536) {$LastResultLabel.text = "For V Drive please Enter a Disk Size of 65536 GB or below"}
elseif ([int64]$WSizeTextBox.Text -gt 65536) {$LastResultLabel.text = "For W Drive please Enter a Disk Size of 65536 GB or below"}
elseif ([int64]$XSizeTextBox.Text -gt 65536) {$LastResultLabel.text = "For X Drive please Enter a Disk Size of 65536 GB or below"}
elseif ([int64]$YSizeTextBox.Text -gt 65536) {$LastResultLabel.text = "For Y Drive please Enter a Disk Size of 65536 GB or below"}
elseif ([int64]$ZSizeTextBox.Text -gt 65536) {$LastResultLabel.text = "For Z Drive please Enter a Disk Size of 65536 GB or below"}
else {$LastResultLabel.text = "Looking Good Man ;)"}
}

function Get-BootISOFileName
{
     $BootISOTextBox.Text = Get-FileName -initialDirectory $BootISOTextBox.Text
}

Function Get-FileName($initialDirectory)
{   
 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.filter = "ISO (*.ISO)| *.ISO"
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
} 


function Get-VHDRootPath
{
     $VHDRootTextBox.Text = Get-Folder
}

Function Get-Folder
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null
    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = "Select a folder"
    $foldername.rootfolder = "MyComputer"
    if($foldername.ShowDialog() -eq "OK")
    {
        $folder += $foldername.SelectedPath
    }
    return $folder
}


function remove-letters
{
$NumberOnly = $VLANIDTextBox,$RAMinGBTextBox,$CPUCountTextBox,$CSizeTextBox,$DSizeTextBox,$ESizeTextBox,$FSizeTextBox,$GSizeTextBox,$HSizeTextBox,$ISizeTextBox,$JSizeTextBox,$KSizeTextBox,$LSizeTextBox,$MSizeTextBox,$NSizeTextBox,$OSizeTextBox,$PSizeTextBox,$QSizeTextBox,$RSizeTextBox,$SSizeTextBox,$TSizeTextBox,$USizeTextBox,$VSizeTextBox,$WSizeTextBox,$XSizeTextBox,$YSizeTextBox,$ZSizeTextBox
Foreach ($i in $NumberOnly)
    {
    # Check if Text contains any non-Digits
        if($i.Text -match '\D'){
            # If so, remove them
            $i.Text = $i.Text -replace '\D'
            # If Text still has a value, move the cursor to the end of the number
            if($i.Text.Length -gt 0){
                $i.Focus()
                $i.SelectionStart = $i.Text.Length
            }
        }
    }
}


function Create-VMs
{
Run-Checks
if ($LastResultLabel.text -eq "Looking Good Man ;)")
{
if ($Gen1RadioButton.Checked -eq $True) {$VMGeneration = 1}
if ($Gen2RadioButton.Checked -eq $True) {$VMGeneration = 2}


#Create VM

try
{
New-VM -Name $VMNameTextBox.Text -MemoryStartupBytes ([int]$RAMinGBTextBox.Text*1073741824) -SwitchName $SwitchNameComboBox.Text -Generation $VMGeneration -ErrorAction Stop
}
catch
{
write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
[System.Windows.MessageBox]::Show($_.Exception.Message)
$VMCrateFailed=$True
$LastResultLabel.text = "VM " + $VMNameTextBox.Text + " Failed to Create :("
}


if (-Not($VMCrateFailed -eq $True))
{


#Set VHD's Path's
$CDriveVHDPath=$VHDRootTextBox.Text+"\"+$VMNameTextBox.Text+"\"+$VMNameTextBox.Text+"-"+$DriveCLabel.text+".vhdx"
$DDriveVHDPath=$VHDRootTextBox.Text+"\"+$VMNameTextBox.Text+"\"+$VMNameTextBox.Text+"-"+$DriveDLabel.text+".vhdx"
$EDriveVHDPath=$VHDRootTextBox.Text+"\"+$VMNameTextBox.Text+"\"+$VMNameTextBox.Text+"-"+$DriveELabel.text+".vhdx"
$FDriveVHDPath=$VHDRootTextBox.Text+"\"+$VMNameTextBox.Text+"\"+$VMNameTextBox.Text+"-"+$DriveFLabel.text+".vhdx"
$GDriveVHDPath=$VHDRootTextBox.Text+"\"+$VMNameTextBox.Text+"\"+$VMNameTextBox.Text+"-"+$DriveGLabel.text+".vhdx"
$HDriveVHDPath=$VHDRootTextBox.Text+"\"+$VMNameTextBox.Text+"\"+$VMNameTextBox.Text+"-"+$DriveHLabel.text+".vhdx"
$IDriveVHDPath=$VHDRootTextBox.Text+"\"+$VMNameTextBox.Text+"\"+$VMNameTextBox.Text+"-"+$DriveILabel.text+".vhdx"
$JDriveVHDPath=$VHDRootTextBox.Text+"\"+$VMNameTextBox.Text+"\"+$VMNameTextBox.Text+"-"+$DriveJLabel.text+".vhdx"
$KDriveVHDPath=$VHDRootTextBox.Text+"\"+$VMNameTextBox.Text+"\"+$VMNameTextBox.Text+"-"+$DriveKLabel.text+".vhdx"
$LDriveVHDPath=$VHDRootTextBox.Text+"\"+$VMNameTextBox.Text+"\"+$VMNameTextBox.Text+"-"+$DriveLLabel.text+".vhdx"
$MDriveVHDPath=$VHDRootTextBox.Text+"\"+$VMNameTextBox.Text+"\"+$VMNameTextBox.Text+"-"+$DriveMLabel.text+".vhdx"
$NDriveVHDPath=$VHDRootTextBox.Text+"\"+$VMNameTextBox.Text+"\"+$VMNameTextBox.Text+"-"+$DriveNLabel.text+".vhdx"
$ODriveVHDPath=$VHDRootTextBox.Text+"\"+$VMNameTextBox.Text+"\"+$VMNameTextBox.Text+"-"+$DriveOLabel.text+".vhdx"
$PDriveVHDPath=$VHDRootTextBox.Text+"\"+$VMNameTextBox.Text+"\"+$VMNameTextBox.Text+"-"+$DrivePLabel.text+".vhdx"
$QDriveVHDPath=$VHDRootTextBox.Text+"\"+$VMNameTextBox.Text+"\"+$VMNameTextBox.Text+"-"+$DriveQLabel.text+".vhdx"
$RDriveVHDPath=$VHDRootTextBox.Text+"\"+$VMNameTextBox.Text+"\"+$VMNameTextBox.Text+"-"+$DriveRLabel.text+".vhdx"
$SDriveVHDPath=$VHDRootTextBox.Text+"\"+$VMNameTextBox.Text+"\"+$VMNameTextBox.Text+"-"+$DriveSLabel.text+".vhdx"
$TDriveVHDPath=$VHDRootTextBox.Text+"\"+$VMNameTextBox.Text+"\"+$VMNameTextBox.Text+"-"+$DriveTLabel.text+".vhdx"
$UDriveVHDPath=$VHDRootTextBox.Text+"\"+$VMNameTextBox.Text+"\"+$VMNameTextBox.Text+"-"+$DriveULabel.text+".vhdx"
$VDriveVHDPath=$VHDRootTextBox.Text+"\"+$VMNameTextBox.Text+"\"+$VMNameTextBox.Text+"-"+$DriveVLabel.text+".vhdx"
$WDriveVHDPath=$VHDRootTextBox.Text+"\"+$VMNameTextBox.Text+"\"+$VMNameTextBox.Text+"-"+$DriveWLabel.text+".vhdx"
$XDriveVHDPath=$VHDRootTextBox.Text+"\"+$VMNameTextBox.Text+"\"+$VMNameTextBox.Text+"-"+$DriveXLabel.text+".vhdx"
$YDriveVHDPath=$VHDRootTextBox.Text+"\"+$VMNameTextBox.Text+"\"+$VMNameTextBox.Text+"-"+$DriveYLabel.text+".vhdx"
$ZDriveVHDPath=$VHDRootTextBox.Text+"\"+$VMNameTextBox.Text+"\"+$VMNameTextBox.Text+"-"+$DriveZLabel.text+".vhdx"

#Create VHD's for Drives
if ([int64]$CSizeTextBox.Text -gt 0) {if (-not (test-path $CDriveVHDPath)) {New-VHD -Path $CDriveVHDPath -SizeBytes (Invoke-Expression ($CSizeTextBox.Text+"GB")) -Dynamic} else {$VHDPathExisted = $true}}
if ([int64]$DSizeTextBox.Text -gt 0) {if (-not (test-path $DDriveVHDPath)) {New-VHD -Path $DDriveVHDPath -SizeBytes (Invoke-Expression ($DSizeTextBox.Text+"GB")) -Dynamic} else {$VHDPathExisted = $true}}
if ([int64]$ESizeTextBox.Text -gt 0) {if (-not (test-path $EDriveVHDPath)) {New-VHD -Path $EDriveVHDPath -SizeBytes (Invoke-Expression ($ESizeTextBox.Text+"GB")) -Dynamic} else {$VHDPathExisted = $true}}
if ([int64]$FSizeTextBox.Text -gt 0) {if (-not (test-path $FDriveVHDPath)) {New-VHD -Path $FDriveVHDPath -SizeBytes (Invoke-Expression ($FSizeTextBox.Text+"GB")) -Dynamic} else {$VHDPathExisted = $true}}
if ([int64]$GSizeTextBox.Text -gt 0) {if (-not (test-path $GDriveVHDPath)) {New-VHD -Path $GDriveVHDPath -SizeBytes (Invoke-Expression ($GSizeTextBox.Text+"GB")) -Dynamic} else {$VHDPathExisted = $true}}
if ([int64]$HSizeTextBox.Text -gt 0) {if (-not (test-path $HDriveVHDPath)) {New-VHD -Path $HDriveVHDPath -SizeBytes (Invoke-Expression ($HSizeTextBox.Text+"GB")) -Dynamic} else {$VHDPathExisted = $true}}
if ([int64]$ISizeTextBox.Text -gt 0) {if (-not (test-path $IDriveVHDPath)) {New-VHD -Path $IDriveVHDPath -SizeBytes (Invoke-Expression ($ISizeTextBox.Text+"GB")) -Dynamic} else {$VHDPathExisted = $true}}
if ([int64]$JSizeTextBox.Text -gt 0) {if (-not (test-path $JDriveVHDPath)) {New-VHD -Path $JDriveVHDPath -SizeBytes (Invoke-Expression ($JSizeTextBox.Text+"GB")) -Dynamic} else {$VHDPathExisted = $true}}
if ([int64]$KSizeTextBox.Text -gt 0) {if (-not (test-path $KDriveVHDPath)) {New-VHD -Path $KDriveVHDPath -SizeBytes (Invoke-Expression ($KSizeTextBox.Text+"GB")) -Dynamic} else {$VHDPathExisted = $true}}
if ([int64]$LSizeTextBox.Text -gt 0) {if (-not (test-path $LDriveVHDPath)) {New-VHD -Path $LDriveVHDPath -SizeBytes (Invoke-Expression ($LSizeTextBox.Text+"GB")) -Dynamic} else {$VHDPathExisted = $true}}
if ([int64]$MSizeTextBox.Text -gt 0) {if (-not (test-path $MDriveVHDPath)) {New-VHD -Path $MDriveVHDPath -SizeBytes (Invoke-Expression ($MSizeTextBox.Text+"GB")) -Dynamic} else {$VHDPathExisted = $true}}
if ([int64]$NSizeTextBox.Text -gt 0) {if (-not (test-path $NDriveVHDPath)) {New-VHD -Path $NDriveVHDPath -SizeBytes (Invoke-Expression ($NSizeTextBox.Text+"GB")) -Dynamic} else {$VHDPathExisted = $true}}
if ([int64]$OSizeTextBox.Text -gt 0) {if (-not (test-path $ODriveVHDPath)) {New-VHD -Path $ODriveVHDPath -SizeBytes (Invoke-Expression ($OSizeTextBox.Text+"GB")) -Dynamic} else {$VHDPathExisted = $true}}
if ([int64]$PSizeTextBox.Text -gt 0) {if (-not (test-path $PDriveVHDPath)) {New-VHD -Path $PDriveVHDPath -SizeBytes (Invoke-Expression ($PSizeTextBox.Text+"GB")) -Dynamic} else {$VHDPathExisted = $true}}
if ([int64]$QSizeTextBox.Text -gt 0) {if (-not (test-path $QDriveVHDPath)) {New-VHD -Path $QDriveVHDPath -SizeBytes (Invoke-Expression ($QSizeTextBox.Text+"GB")) -Dynamic} else {$VHDPathExisted = $true}}
if ([int64]$RSizeTextBox.Text -gt 0) {if (-not (test-path $RDriveVHDPath)) {New-VHD -Path $RDriveVHDPath -SizeBytes (Invoke-Expression ($RSizeTextBox.Text+"GB")) -Dynamic} else {$VHDPathExisted = $true}}
if ([int64]$SSizeTextBox.Text -gt 0) {if (-not (test-path $SDriveVHDPath)) {New-VHD -Path $TDriveVHDPath -SizeBytes (Invoke-Expression ($SSizeTextBox.Text+"GB")) -Dynamic} else {$VHDPathExisted = $true}}
if ([int64]$TSizeTextBox.Text -gt 0) {if (-not (test-path $TDriveVHDPath)) {New-VHD -Path $TDriveVHDPath -SizeBytes (Invoke-Expression ($TSizeTextBox.Text+"GB")) -Dynamic} else {$VHDPathExisted = $true}}
if ([int64]$USizeTextBox.Text -gt 0) {if (-not (test-path $UDriveVHDPath)) {New-VHD -Path $UDriveVHDPath -SizeBytes (Invoke-Expression ($USizeTextBox.Text+"GB")) -Dynamic} else {$VHDPathExisted = $true}}
if ([int64]$VSizeTextBox.Text -gt 0) {if (-not (test-path $VDriveVHDPath)) {New-VHD -Path $VDriveVHDPath -SizeBytes (Invoke-Expression ($VSizeTextBox.Text+"GB")) -Dynamic} else {$VHDPathExisted = $true}}
if ([int64]$WSizeTextBox.Text -gt 0) {if (-not (test-path $WDriveVHDPath)) {New-VHD -Path $WDriveVHDPath -SizeBytes (Invoke-Expression ($WSizeTextBox.Text+"GB")) -Dynamic} else {$VHDPathExisted = $true}}
if ([int64]$XSizeTextBox.Text -gt 0) {if (-not (test-path $XDriveVHDPath)) {New-VHD -Path $XDriveVHDPath -SizeBytes (Invoke-Expression ($XSizeTextBox.Text+"GB")) -Dynamic} else {$VHDPathExisted = $true}}
if ([int64]$YSizeTextBox.Text -gt 0) {if (-not (test-path $YDriveVHDPath)) {New-VHD -Path $YDriveVHDPath -SizeBytes (Invoke-Expression ($YSizeTextBox.Text+"GB")) -Dynamic} else {$VHDPathExisted = $true}}
if ([int64]$ZSizeTextBox.Text -gt 0) {if (-not (test-path $ZDriveVHDPath)) {New-VHD -Path $ZDriveVHDPath -SizeBytes (Invoke-Expression ($ZSizeTextBox.Text+"GB")) -Dynamic} else {$VHDPathExisted = $true}}


Get-VM $VMNameTextBox.Text | Set-VMProcessor -Count $CPUCountTextBox.Text

Get-VM $VMNameTextBox.Text | set-VMNetworkAdapterVlan -Access -vlanId $VLANIDTextBox.Text

if (test-path $CDriveVHDPath) {Add-VMHardDiskDrive -VMName $VMNameTextBox.Text -Path $CDriveVHDPath -ControllerType SCSI -ControllerNumber 0}
if (test-path $DDriveVHDPath) {Add-VMHardDiskDrive -VMName $VMNameTextBox.Text -Path $DDriveVHDPath -ControllerType SCSI -ControllerNumber 0}
if (test-path $EDriveVHDPath) {Add-VMHardDiskDrive -VMName $VMNameTextBox.Text -Path $EDriveVHDPath -ControllerType SCSI -ControllerNumber 0}
if (test-path $FDriveVHDPath) {Add-VMHardDiskDrive -VMName $VMNameTextBox.Text -Path $FDriveVHDPath -ControllerType SCSI -ControllerNumber 0}
if (test-path $GDriveVHDPath) {Add-VMHardDiskDrive -VMName $VMNameTextBox.Text -Path $GDriveVHDPath -ControllerType SCSI -ControllerNumber 0}
if (test-path $HDriveVHDPath) {Add-VMHardDiskDrive -VMName $VMNameTextBox.Text -Path $HDriveVHDPath -ControllerType SCSI -ControllerNumber 0}
if (test-path $IDriveVHDPath) {Add-VMHardDiskDrive -VMName $VMNameTextBox.Text -Path $IDriveVHDPath -ControllerType SCSI -ControllerNumber 0}
if (test-path $JDriveVHDPath) {Add-VMHardDiskDrive -VMName $VMNameTextBox.Text -Path $JDriveVHDPath -ControllerType SCSI -ControllerNumber 0}
if (test-path $KDriveVHDPath) {Add-VMHardDiskDrive -VMName $VMNameTextBox.Text -Path $KDriveVHDPath -ControllerType SCSI -ControllerNumber 0}
if (test-path $LDriveVHDPath) {Add-VMHardDiskDrive -VMName $VMNameTextBox.Text -Path $LDriveVHDPath -ControllerType SCSI -ControllerNumber 0}
if (test-path $MDriveVHDPath) {Add-VMHardDiskDrive -VMName $VMNameTextBox.Text -Path $MDriveVHDPath -ControllerType SCSI -ControllerNumber 0}
if (test-path $NDriveVHDPath) {Add-VMHardDiskDrive -VMName $VMNameTextBox.Text -Path $NDriveVHDPath -ControllerType SCSI -ControllerNumber 0}
if (test-path $ODriveVHDPath) {Add-VMHardDiskDrive -VMName $VMNameTextBox.Text -Path $ODriveVHDPath -ControllerType SCSI -ControllerNumber 0}
if (test-path $PDriveVHDPath) {Add-VMHardDiskDrive -VMName $VMNameTextBox.Text -Path $PDriveVHDPath -ControllerType SCSI -ControllerNumber 0}
if (test-path $QDriveVHDPath) {Add-VMHardDiskDrive -VMName $VMNameTextBox.Text -Path $QDriveVHDPath -ControllerType SCSI -ControllerNumber 0}
if (test-path $RDriveVHDPath) {Add-VMHardDiskDrive -VMName $VMNameTextBox.Text -Path $RDriveVHDPath -ControllerType SCSI -ControllerNumber 0}
if (test-path $SDriveVHDPath) {Add-VMHardDiskDrive -VMName $VMNameTextBox.Text -Path $SDriveVHDPath -ControllerType SCSI -ControllerNumber 0}
if (test-path $TDriveVHDPath) {Add-VMHardDiskDrive -VMName $VMNameTextBox.Text -Path $TDriveVHDPath -ControllerType SCSI -ControllerNumber 0}
if (test-path $UDriveVHDPath) {Add-VMHardDiskDrive -VMName $VMNameTextBox.Text -Path $UDriveVHDPath -ControllerType SCSI -ControllerNumber 0}
if (test-path $VDriveVHDPath) {Add-VMHardDiskDrive -VMName $VMNameTextBox.Text -Path $VDriveVHDPath -ControllerType SCSI -ControllerNumber 0}
if (test-path $WDriveVHDPath) {Add-VMHardDiskDrive -VMName $VMNameTextBox.Text -Path $WDriveVHDPath -ControllerType SCSI -ControllerNumber 0}
if (test-path $XDriveVHDPath) {Add-VMHardDiskDrive -VMName $VMNameTextBox.Text -Path $XDriveVHDPath -ControllerType SCSI -ControllerNumber 0}
if (test-path $YDriveVHDPath) {Add-VMHardDiskDrive -VMName $VMNameTextBox.Text -Path $YDriveVHDPath -ControllerType SCSI -ControllerNumber 0}
if (test-path $ZDriveVHDPath) {Add-VMHardDiskDrive -VMName $VMNameTextBox.Text -Path $ZDriveVHDPath -ControllerType SCSI -ControllerNumber 0}

# 
#  REMOVING NETWORK FROM THE BOOT ORDER

#Set New Boot order
if ($VMGeneration -eq "2")
    {
        $old_boot_order = Get-VMFirmware -VMName $VMNameTextBox.Text -ComputerName $HostName | Select-Object -ExpandProperty BootOrder
        $new_boot_order = $old_boot_order | Where-Object { $_.BootType -ne "Network" }
        Set-VMFirmware -VMName $VMNameTextBox.Text -ComputerName $HostName -BootOrder $new_boot_order
    }


#  ADD DVD Drive with ISO Attached
if ($BootISOTextBox.Text -ne "") {Get-VM $VMNameTextBox.Text | Add-VMDvdDrive -Path $BootISOTextBox.Text}

if ($VHDPathExisted) {$LastResultLabel.text = "VM " + $VMNameTextBox.Text + " Created OK, but at least one VHD already existed and was just reattached"}
else {$LastResultLabel.text = "VM " + $VMNameTextBox.Text + " Created OK"}

}
}
}

[void]$HyperVVMCreator.ShowDialog()