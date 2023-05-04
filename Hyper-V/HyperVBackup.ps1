<#
These will come via Template
  $usbdrive = "R:"
  $excludevm = @("[EXV]")
#>

<#
    Added SizeVMs Function to sort large to small so that important servers have a better chance of getting backed up (user data)
    IF we run out of space, clean up continue
        1. Keep track of which have (not) exported
        2. Move Cleanup to a function
    Changed logic so IF exports fail, run Cleanup & try again (Self-Help).
    Fixed issue with Bitlocker. It's not ready for encrypted pw file import. Will get with Production V2.

V2 Thoughts -
    Service-Acct (best practice anyway)
    Store password in that location.
    Block Inherit - Expl only to Service-Acct. [Possibly our Admin Accts]
#>


$Script:GoodWhack = @()
$Script:ListVMs = @()
$Script:NoExport = @()
$Script:NoWhack = @()
$Script:OrigVMs = @()
$Script:TOffVMs = @()
$Files = @()
$GoodExport = @()
$html = @()
$ManualDel = @()
$TB = @()

$Script:ReRun = @{}
$PrettySetup = @{}
$Rank = @{}
$Viewable = @{}

$Script:Attempt = 0
$Script:EmailTomorrowBack = 0
$Script:EmailTodayBack = 0
$Script:FailedExport = 0
$Script:Passes = 1
$Script:Savings = 0
$Script:TomorrowSpace = 0
$Script:TotalWarn = 0
$Script:TotalWhack = 0
$EmailTodayBack = 0
$ExportVMStop = 0
$Free = 0
$FolderSize = 0
$ManDelFree = 0
$SizeMatters = 0
$TomorrowBack = 0
$TotalErrs = 0
$TotalSuccess = 0
$z = 0

$Script:EmailOVMs = "Machine`tStatus"
$Script:Ancillary = ""
$Script:EmailOut = (" " * 15) + "Folder" + (" " * 29) + "Files" + (" " *8) + "Size`n"
$Script:YouDelete = ""
$App = "Bitlocker"
$Body = ""
$ConsistDate = (Get-Date).tostring("yyyy-MM-dd")
$Discrepency = ""
#$emailrecipients = "chris.macke@aleragroup.com" #<Test>
$emailrecipients = "sysadmins@aleragroup.com" #<Prod>
$ErrorActionPreference = "SilentlyContinue"  #<Prod>
$pathExists = Test-Path -Path $usbdrive
$Server = $env:COMPUTERNAME
$SnapResolve = ""
$Status = ""
$Subject = ""
$usbdrive = "R:"

$StopWatch = [System.Diagnostics.Stopwatch]::StartNew()
$usbdriveWMI = Get-WmiObject -Query "Select SystemName, DriveType, DeviceID, Size, FreeSpace from Win32_LogicalDisk Where DriveType =2 or DeviceID = 'R:'"


Function SendErrEmail {

   Send-MailMessage -to $emailrecipients -smtpserver aleragroup-com.mail.protection.outlook.com -from "Rollback <Rollback@aleragroup.com>" -subject "$Subject $(get-date -format MM/dd/yyyy)" -body $Body

}


Function Send-Email {

   $TotalSuccess = $Script:GoodExport.Count
   $TotalErrs = $Script:NoExport.Count
   IF($TotalErrs -eq 0){ $ThisStatus = "Success" } ELSE { $ThisStatus = "Some Errors" }
   IF(($Script:EmailTomorrowBack - $Script:TomorrowSpace) -lt 1.0) { $TomorrowWarning = "SPACE WARNING: Only $Drivefree TB left, and there is $Script:TomorrowSpace needed" }
   ELSE { $TomorrowWarning = $EmailSpaceNeedTomorrow }
   
   #Line up numbers!
   
   IF($TotalErrs.length -lt 2) { $TotalErrs = " $TotalErrs" }
   IF($TotalSuccess.length -lt 2) { $TotalSuccess = " $TotalSuccess" }
   IF($Script:TotalWarn.length -lt 2) { $Script:TotalWarn = " $Script:TotalWarn" }
   IF($Script:TotalWhack.length -lt 2) { $Script:TotalWhack = " $Script:TotalWhack" }
   
   $TotalStop = ("{0:D2}" -f ($StopWatch.Elapsed).Hours + ":" +  "{0:D2}" -f ($StopWatch.Elapsed).Minutes)
   $StopWatch.Stop()
   $EM_CleanupStop = $Script:CleanupStop
   $EM_NoExport = $Script:NoExport
   $EM_TlWarn = $Script:TotalWarn
   $EM_NoWhack = $Script:NoWhack
   $EM_TlWhack = $Script:TotalWhack
   $EM_GdWhack = $Script:GoodWhack
   $EM_EMOut = $Script:EmailOut
   $EM_EMOVMs = $Script:EmailOVMs.Split("|")[0] + "`t" + $Script:EmailOVMs.Split("|")[1]
   $Today = "{0:yyyy-MM-dd}" -f (Get-Date)
   
   $smtpSettings = @{
      To = $emailrecipients
      From = "Rollback@AleraGroup.com"
      Subject = "$ThisStatus - $env:COMPUTERNAME Rollback Report for {0:MMM dd,yyyy}" -f (Get-Date)
      SMTPServer = "aleragroup-com.mail.protection.outlook.com"
   }

   $Message = New-Object System.Net.Mail.MailMessage $smtpSettings.From, $smtpSettings.To 
   $SMTPServer = "aleragroup-com.mail.protection.outlook.com"
   $Message = New-Object System.Net.Mail.MailMessage $smtpSettings.From, $smtpSettings.To 
   $Message.Subject = $smtpSettings.Subject
   $Message.Body = "Statistics for Today's Backups (Passes:$Script:Passes)`n" +'-' *50 + "`n`n`t       Machines Failing($TotalErrs):`n $EM_NoExport`n `
            `n`t   Machines Successful($TotalSuccess):`n $Script:GoodExport`n`n********** Cleanup *********`
            `n  Folders with Removal Errors: $EM_TLWarn`n$EM_NoWhack`n$Script:YouDelete`n`n  Successfully Removed Images: $EM_TlWhack`
            `n       Images Removed:`n $EM_GdWhack`n`n********** Images  *********`n`n$Script:EmailOut`n`n***** BitLocker/Dedupe ***** `
            `n$Script:Ancillary`n`n***** Powered Off VMs ******`n$EM_EMOVMs`n`n********* Stats *********`nSpace Used today: $EmailTodayBack TB`
            `n$TomorrowWarning`n`n$Discrepency`n`n$EmailSpaceNeedBody`n`n$SnapResolve`nDedupe: $Savings`n`nTimes (HH:MM) - `
            `n      Exports:" + (" " * (7 - $ExportVMStop.Length) + $ExportVMStop) + "`n      Cleanup:" + (" " * (7 - $EM_CleanupStop.Length) + $EM_CleanupStop) `
            + "`nTomorrow Info:" + (" " * (7 - $SizesStop.Length) + $SizesStop) + "`n        Total:" + (" " * (7 - $TotalStop.Length) + $TotalStop) `
            + "$EmailSpaceNeedTomorrow"
   $SMTP = New-Object Net.Mail.SMTPClient($SMTPServer)
   $SMTP.Send($Message)

}


Function Dedupe {

   Write-Host "Dedupe"
   Get-WmiObject -ComputerName $Server -Class Win32_OptionalFeature | Where-Object { $_.Name -imatch "FS-Data-Deduplication" }
   Add-WindowsFeature -Name FS-Data-Deduplication -IncludeAllSubFeature
   Enable-DedupVolume -Volume $USBDrive -UsageType Backup 
   Set-DedupVolume -Volume $USBDrive -MinimumFileAgeDays 1
   $Script:Ancillary = $Script:Ancillary + "Volume Deduplication added & Enabled`n"

}


Function BitLockerGood {

   Write-Host "BitLocker"
   $Status = Get-WmiObject -Class Win32_OptionalFeature | Where-Object { $_.Caption -imatch "bitlocker Drive Encryption" -and $_.Caption -inotmatch "Remote" }
   IF($Status.InstallState -eq 1) { $Script:Ancillary = $Script:Ancillary + "Bitlocker added, but REQUIRES A REBOOT!`n" }
   ELSE { $Script:Ancillary = $Script:Ancillary + "Bitlocker is Status: " + $Status.InstallState }

}


Function SizeVMs {

   Write-Host "Size VMs"
   $ExcludeVM = ""
   $Rank = @{}
   $GetVMs = Get-VM | Where-Object { $_.Name -notlike $excludevm -and $_.State -inotmatch "Off" }
   $Script:TOffVMs = Get-VM | Where-Object{ $_.State -imatch "Off" }
   ForEach($NeedBackup in $GetVMs) {
      $VHDXDrivePath = (Get-VMHardDiskDrive $NeedBackup).Path
      ## There are issues with pulling data because for some servers drives exist in dIFferent locations (folders).
      ## Not worth trying to put that much logic into it.
      IF($VHDXDrivePath.Count -gt 1) {
         IF($VHDXDrivePath[0].IndexOf($NeedBackup.Name) -ge 0) {
            $StartSearch = $VHDXDrivePath[0].IndexOf($NeedBackup.Name)             
            $SearchString = $VHDXDrivePath[0].Substring($StartSearch)
            $VMFolderName = $SearchString.IndexOf("\")
            $Keeper = $VHDXDrivePath[0].SubString(0,($StartSearch + $VMFolderName))
         }
      }
      ELSE {
         IF($VHDXDrivePath.IndexOf($NeedBackup.Name) -ge 0) {
            $StartSearch = $VHDXDrivePath.IndexOf($NeedBackup.Name)             
            $SearchString = $VHDXDrivePath.Substring($StartSearch)
            $VMFolderName = $SearchString.IndexOf("\")
            $Keeper = $VHDXDrivePath.SubString(0,($StartSearch + $VMFolderName))
         }
      }

      $DownSize = [math]::Round(((Get-ChildItem $Keeper -Recurse -Force | Where-Object { $_.psIsContainer -EQ $false } | Measure-Object -Property Length -Sum).sum/1gb),2)
      $Rank.Add($NeedBackup.Name,$DownSize)
      $DownSize = 0
   }

   $Script:ListVMs = $Rank.GetEnumerator() | Sort-Object Value -Descending
   Write-Host "Leaving SizeVMs"

}


Function Exporter {

   Write-Host "Exporter"
   ForEach($IndVM in $Script:ListVMs) {
      IF($Script:Attempt -lt 1) {
         IF($IndVM.Length -gt 0) {
            $Error.Clear()
            Export-VM $IndVM.name -Path ($RootPath + "\" + $foldername)
            IF($Error[0].Length -gt 0) {  
               IF($Error[0].Exception.Message.Contains("not enough disk space")) {
                  $Script:NoExport += ($IndVM.Name + " (not enough disk space)`n")
               }
               ELSEIF($Error[0].Exception.Message.Contains("already exists"))# -or $Error[0].Exception.Message.Contains("directory already exists")) 
               {
                  $Script:NoExport += ($IndVM.Name + " (" + $Error[0].exception.Message.Split("`n")[0] + ")") #Why was it 3? Testing??
               }
               ELSE { $Script:NoExport += ($IndVM.Name + " (" + $Error[0].Exception.Message.Split("`n")[0] + ")`n") }
               
               $Script:FailedExport++
               $Script:ReRun.Add($IndVM.Name,$IndVM.Downsize)

            } ELSE { $Script:GoodExport += ($IndVM.Name + "`n") }
         }
      } ELSE {
         $Error.Clear()
         IF($Script:GoodExport.IndexOf($IndVM.Name)-lt 0) {
            Export-VM $IndVM.name -Path ($RootPath + "\" + $foldername)
            IF($Error[0].Length -eq 0) {

               $Script:GoodExport += ($IndVM.Name + " (" + $Error[0].Exception.Message + ") Second Attempt (Adj count)`n")
               $Script:FailedExport--

            }
         }
         ELSE {
            IF(!(Get-ChildItem($RootPath + "\" + $foldername + "\" + $IndVM) -Recurse -File | Measure-Object -Property length -Sum).sum -gt 0) {  
               $Error.Clear()
               Export-VM $IndVM.name -Path ($RootPath + "\" + $foldername)
               IF($Error[0].Length -gt 0) {  
                  $Script:NoExport += ($IndVM.Name + " (" + $Error[0].Exception.Message.Split("`n")[0] + ") SECOND Attempt failed`n") #Added .Split("`n")[0]
               } ELSE {
                  $Script:GoodExport += ($IndVM.Name + " (" + $Error[0].Exception.Message.Split("`n")[0] + ") Second Attempt (Adj count)`n") #Added .Split("`n")[0]
                  $Script:FailedExport--
               }
            }
         }
      }
   }
   
   $Script:Attempt++
   Write-Host "Leaving Exporter"

}


Function Cleanup {

   #Clean up Images
   Write-Host "Cleanup"
   $CleanupStart = [System.Diagnostics.Stopwatch]::StartNew()
   $Whack = Get-ChildItem $RootPath -Directory | Where-Object { $_.LastAccessTime -lt ((Get-Date).AddDays(-5)) }
   ForEach($Folder in $Whack) {
      $Error.Clear()
      Remove-Item $Folder.FullName -Recurse -Force
      IF($Error[0].Length -gt 0) { $Script:NoWhack += $Error[0].InvocationInfo.InvocationName }
      ELSE { $Script:GoodWhack += (("$Folder Removed ") + "(" + ($Folder.LastWriteTime).ToShortDateString() + ")`n") #Making sure before Whacking - 
      }
   }

   $Script:TotalWarn =  $NoWhack.Count
   $Script:TotalWhack = $GoodWhack.Count
   $Script:CleanupStop = ("{0:D2}" -f ($CleanupStart.Elapsed).Hours + ":" +  "{0:D2}" -f ($CleanupStart.Elapsed).Minutes) 
   $CleanupStart.Stop()

}


Start-Transcript -path c:\scripts\hyperbackup_temp1.txt
IF($usbdriveWMI.DeviceID -imatch $usbdrive) { $RootPath = $usbdrive + "\RollBack\" }
ELSE { $RootPath = $usbdriveWMI + "\RollBack\" }

#Install Deduplication
DEDUPE
#Install BitLocker
BITLOCKERGOOD
Clear-Host

IF (!($pathExists)) {

<#
   $Error.Clear()
   $bitlockercode = ConvertTo-SecureString "Wh1t3night!5341" -AsPlainText -Force
   #$bitlockercode = "Wh1t3night!5341"
   #$BitLockerCode = Get-Content "$Home\$App.txt" |ConvertTo-SecureString
   Unlock-BitLocker -MountPoint $usbdrive -Password $bitlockercode
   IF($Error[0].CategoryInfo.Activity -eq "Write-error")
   {  
      $Subject = "ERROR - $env:COMPUTERNAME"
      $Body = $Error[0].InvocationInfo.InvocationName + "`n`t" + $Error[0].ErrorDetails.Message + "`nExiting Script!"
      SENDERREMAIL
      Exit
   }
#>

}

   $folderName = (Get-Date).tostring("yyyy-MM-dd")
   $RootDrive = "  "          
   $Error.Clear()
   #Daily Folder Setup
   IF(!(Test-Path $RootPath)) {
      New-Item -itemType Directory -Path ($RootPath[0]) -Name "Rollback"
      IF($Error[0].Length -gt 0) {
         $Subject = "ERROR - $env:COMPUTERNAME"
         $Body = $Error[0].InvocationInfo.InvocationName + "`n`t" + $Error[0].ErrorDetails.Message + "`nExiting Script!"
         SENDERREMAIL
         Exit
      }
   }
   
   #Create Folder Structure
   $Error.Clear()
   IF(!(Test-Path "$RootPath\$folderName")) {
      New-Item -itemType Directory -Path $RootPath -Name $ConsistDate
      IF($Error[0].Length -gt 0) {
         $Subject = "ERROR - $env:COMPUTERNAME"
         $Body = "Could not create Rollback folder`n`t$RootPath" + (Get-Date -UFormat "%Y-%m-%d") + "`nExiting Script!"
         SENDERREMAIL
         Exit
      }
   }
   $ExportStart = [System.Diagnostics.Stopwatch]::StartNew()
   $Status = "$usbdrive`:\Rollback\{0:%Y-%m-%d}" -f (Get-Date)
   
   SIZEVMS
   
   IF($Script:TOffVMs.Count -gt 0) {
      ForEach($ShutdwnVM in $Script:TOffVMs) {
         $Script:EmailOVMs = $Script:EmailOVMs + "`n" + $ShutdwnVM.Name + "|" + $ShutdwnVM.State
      }
   }
   ELSE { $Script:EmailOVMs = "No VMs are powered off`n" }
   
   $FirstRun = $True
   $Fail = 0
   EXPORTER
   $FirstRun = $False
   
   IF($Script:FailedExport -gt 0) {
      CLEANUP
      $Script:OrigVMs = $Script:ListVMs
      $Script:ListVMs = $Script:ReRun
      
      EXPORTER
      
      $Script:Passes = 2
   }

   $ExportVMStop = ("{0:D2}" -f ($ExportStart.Elapsed).Hours + ":" +  "{0:D2}" -f ($ExportStart.Elapsed).Minutes) #.ToString()
   $ExportStart.Stop()

#FolderSizes
   $SizesStart = [System.Diagnostics.Stopwatch]::StartNew()
   $directoryItems = Get-ChildItem "$RootPath\$foldername" | Where-Object { $_.PSIsContainer -eq $true } | Sort-Object
#For Tomorrow
   $SubFolderSize = [math]::Round(((Get-ChildItem "$RootPath" -Recurse | Where-Object { $_.psIsContainer -EQ $false } | Measure-Object -Property Length -Sum).sum/1tb),2)
   $TodayBackupFolder = $RootPath + "\" + $foldername 
   $TodayBackup = [math]::Round(((Get-ChildItem "$TodayBackupFolder" -Recurse | Where-Object { $_.psIsContainer -EQ $false } | Measure-Object -Property Length -Sum).sum/1tb),2)
   
   IF($FailCleanup = Get-ChildItem "$RootPath" |Where-Object{$_.LastWriteTime -lt ((Get-Date).AddDays(-4))}) {
      
      ForEach($FailFolder in $FailCleanup) {
         
         $ManualValue = [math]::Round(((Get-ChildItem $FailFolder.FullName -Recurse | Where-Object { $_.psIsContainer -EQ $false } | Measure-Object -Property Length -Sum).sum/1tb),2) +"`n"
         $ManualDel += $FailFolder.FullName + "`t" + "$ManualValue`n"
         IF($ManualDelStr.Length -gt 0) { $ManualDelStr = "$ManualDelStr`n   " + $FailFolder.FullName + "`t" + "$ManualValue" }
         ELSE { $ManualDelStr = "`n   " + $FailFolder.FullName + "`t" + "$ManualValue" }  ## Possible
         
         $ManDelFree = $ManDelFree + $ManualValue
      }

      $Script:YouDelete = "Folders Requiring manual deletion & size$ManualDelStr"
      $Free = get-wmiobject -query "Select DriveType, DeviceId, Size, FreeSpace from win32_logicaldisk where DeviceID='R:'"
      $WouldHave = ($SubFolderSize - $ManualDel.Split("`t")[1])      #All Rollbacks
      $SpaceNeedHdr = "Free Sp `tAll Used`t(Man Del)`tNeed(Est)`tImages to be removed/Size"
      $TomorrowNeed = [math]::Round(((($Free.FreeSpace/1TB) - $SubFolderSize) + ($WouldHave - $TodayBackup)),2)
      
      IF($WillRecoupe = Get-ChildItem "$RootPath" |Where-Object{$_.LastWriteTime -lt ((Get-Date).AddDays(-3)) -and $_.LastWriteTime -gt (Get-Date).AddDays(-4)}) {
         $GainTomorrow = $WillRecoupe.FullName + "`t" + [math]::Round(((Get-ChildItem $FailFolder.FullName -Recurse `
           | Where-Object{ $_.psIsContainer -EQ $false } | Measure-Object -Property Length -Sum).sum/1tb),2)
      }

      $DriveFree =  [math]::Round($Free.FreeSpace /1TB,2)
      $SpaceNeedBody = "$DriveFree`t`t$SubFolderSize`t`t$ManDelFree`t`t$TomorrowNeed`t`t$GainTomorrow"
      $EmailSpaceNeedBody = "`n$SpaceNeedHdr`n$SpaceNeedBody"

   }

   ForEach ($i in $directoryItems) {
      $SubFolderItems = Get-ChildItem $i.FullName -recurse -force | Where-Object { $_.PSIsContainer -eq $false } | Measure-Object -property Length -sum | Select-Object Sum
      $SubFileCount = (Get-ChildItem $i.FullName -Recurse -Force -File).count
      $Stage = $i.FullName
      
      $PrettySetup = @{
         Folder = $i.FullName;
         Files = $SubFileCount;
         Size = "{0:N2}" -f ($subFolderItems.sum / 1GB) + " GB"
      }

      $RunningFiles = $RunningFiles + $SubFileCount
      $Files += $SubFileCount
      $Align1 = (50 - ($i.FullName.Length)) #Account for space in Header + Header
      $Align2 = (10 - ($PrettySetup.Files.Length)).ToString().PadLeft(3)
      $Align3 = ($PrettySetup.Size.PadLeft(10))
      $PrettySetup.Folder = ($PrettySetup.Folder + (" "*$Align1))
      $PrettySetup.Files = ($PrettySetup.Files.ToString() + (" " * $Align2))
      $PrettySetup.Size = ($Align3)
      $Script:EmailOut = $Script:EmailOut + (($PrettySetup.Folder) + ($PrettySetup.Files) + ($PrettySetup.Size) + "`n")
      $TB += (($SubFolderItems.Sum)/1TB)
      $z++
   }

   ForEach($amount in $TB) { $TomorrowBack = ($TomorrowBack + $amount) }
   $TomorrowBack = [math]::round($TomorrowBack,2)

   #Snapshots?
   $Snaps = Get-ChildItem "$RootPath\$foldername" -Recurse -Force | Where-Object { $_.PSIsContainer -eq $true } | Where-Object{ $_.Name -ilike "*Snapshot*" }
   ForEach($SnapFolder in $Snaps) {
     $SnapFileCount = (Get-ChildItem $SnapFolder.FullName -Recurse -Force -File).count
     IF($SnapFileCount -gt 0) { $SnapResolve = $SnapResolve + ($SnapFolder.FullName + "`t$SnapFileCount Snapshots`n") }
   }

   #Now compare file counts
   $Yest = Get-ChildItem "$RootPath" | Where-Object { $_.Name -imatch ("{0:yyyy-MM-dd}" -f (get-date).AddDays(-1)) }
   $YestFiles = (Get-ChildItem "$RootPath\$Yest" -Recurse -Force -file).count
   IF($RunningFiles - $YestFiles -gt 5) { $Discrepency = "RESEARCH!!! Todays File count " + $RunningFiles + " Yesterday's $YestFiles" }
   $DriveSpace = get-wmiobject -query "Select DriveType, DeviceId, Size, FreeSpace from win32_logicaldisk where DeviceID='R:'"
   $Script:EmailTodayBack = [math]::Round(($SubFolderItems.Sum)/1TB,2)
   $Script:EmailTomorrowBack = [math]::Round(($TomorrowNeed),2)
   $Script:TomorrowSpace = [math]::Round((($DriveSpace.FreeSpace)/1TB - ($SubFolderItems.Sum)/1TB),2)
   $Script:SizesStop = ("{0:D2}" -f ($SizesStart.Elapsed).Hours + ":" +  "{0:D2}" -f ($SizesStart.Elapsed).Minutes) 
   $SizesStart.Stop()
   $SavingsAll = Get-DedupStatus -Volume "r:"
   $SaveFree = [math]::round($SavingsAll.FreeSpace/1TB,2)
   $SaveSaved = [math]::round($SavingsAll.SavedSpace/1TB,2)
   $SaveOpt = [math]::round($SavingsAll.OptimizedFilesSize/1TB,2)
   $SaveInPol = $SavingsAll.InPolicyFilesCount
   $SavingsHdr = "`nFree`t`tSaved`t`tOptimized`t`tInPolicy`n"
   $Script:Savings = $SavingsHdr + $SaveFree + " TB`t" + $SaveSaved + " TB`t" + $SaveOpt + " TB`t`t" + $SaveInPol
   
   Stop-Transcript
 
   $File = "C:\Scripts\hyperbackup_temp.txt"
   Get-Content $File | Select-Object -Skip 18 | Set-Content "$File-temp"
   Move-Item "$File-temp" $File -Force
   $TransInfo = Get-Content $File
   
   SEND-EMAIL
   #Remove-Item c:\scripts\hyperbackup_temp.txt