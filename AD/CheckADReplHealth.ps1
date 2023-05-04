﻿## Active Directory Replication Health Check Script (PowerShell) 
## Script uses repadmin to generate HTML report and sends it to admin e-mail 

#Variables
$report_path = "C:\Temp"
$date = Get-Date -Format "yyyy-MM-dd"
$array = @()
 
#Powershell Function to delete files older than a certain age
$intFileAge = 8  #age of files in days
$strFilePath = $report_path #path to clean up
 
#create filter to exclude folders and files newer than specified age

Filter Select-FileAge {

    param($days)
    If ($_.PSisContainer) {}
    # Exclude folders from result set
    ElseIf ($_.LastWriteTime -lt (Get-Date).AddDays($days * -1))
    {$_}

}
#get-Childitem -recurse $strFilePath | Select-FileAge $intFileAge 'CreationTime' | Remove-Item
 
Function send_mail([string]$message,[string]$subject) {

    $emailFrom = "ADReplHealth@aleragroup.com"
    $emailTo = "sysadmins@aleragroup.com"
    $smtpServer = "aleragroup-com.mail.protection.outlook.com"

    Send-MailMessage -SmtpServer $smtpServer -To $emailTo -From $emailFrom -Subject $subject -Body $message -BodyAsHtml

}

###Test all forest 
#$myForest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
#$dclist = $myforest.Sites | % { $_.Servers }
###

###Test specific AD domain
$Domain = "corp.aleragroup.com"
$dclist = (Get-ADDomain $Domain -Server $Domain).ReplicaDirectoryServers
###

$html_head = "<style type='text/css'>
table {font-family:verdana,arial,sans-serif;font-size:12px;color:#333333;border-width: 1px;border-color: #729ea5;border-collapse: collapse;}
th {font-family:verdana,arial,sans-serif;font-size:12px;background-color:#acc8cc;border-width: 1px;padding: 8px;border-style: solid;border-color: #729ea5;text-align:left;}
tr {font-family:verdana,arial,sans-serif;background-color:#d4e3e5;}
td {font-family:verdana,arial,sans-serif;font-size:12px;border-width: 1px;padding: 8px;border-style: solid;border-color: #729ea5;}
</style>"
 
foreach ($dcname in $dclist){
    
    ###Test all forest
    #$source_dc_fqdn = ($dcname.name).tolower()
    ###

    ###Test specific domain
    $source_dc_fqdn = ($dcname).ToUpper()
    ###

    $ad_partition_list = repadmin /showrepl $source_dc_fqdn | select-string "dc="

    foreach ($ad_partition in $ad_partition_list) {
        [Array]$NewArray=$NULL
        $result = repadmin /showrepl $source_dc_fqdn $ad_partition
        $result = $result | where { ([string]::IsNullOrEmpty(($result[$_]))) }
        $index_array_dst = 0..($result.Count - 1) | Where { $result[$_] -like "*via RPC" }

        foreach ($index in $index_array_dst){
            $dst_dc = ($result[$index]).trim()
            $next_index = [array]::IndexOf($index_array_dst,$index) + 1
            $next_index_msg = $index_array_dst[$next_index]
            $msg = ""

            IF ($index -lt $index_array_dst[-1]){
                $last_index = $index_array_dst[$next_index]
            } ELSE { $last_index = $result.Count }
 
            for ($i=$index+1;$i -lt $last_index; $i++){
                IF (($msg -eq "") -and ($result[$i])) {
                    $msg += ($result[$i]).trim()
                } ELSE {
                $msg += " / " + ($result[$i]).trim()
                }
            }
    
            $Properties = @{Source_DC=$source_dc_fqdn;NC=$ad_partition;Destination_DC=$dst_dc;Repl_Status=$msg}
            $Newobject = New-Object PSObject -Property $Properties
            $array +=$newobject
    
        }
    }
}
 
$status_repl_ko = "<br><br><font face='Calibri' color='black'><i><b>Active Directory Replication Problem :</b></i><br>"
$status_repl_ok = "<br><br><font face='Calibri' color='black'><i><b>Active Directory Replication OK :</b></i><br>"
$subject = "Active Directory Replication status : "+$date
$message = "<br><br><font face='Calibri' color='black'><i>The full Active Directory Replication report is available <a href=" + $report_path + "\ad_repl_status_$date.html>here</a></i><br>"
$message += $status_repl_ko
 
IF ($array | where {$_.repl_status -notlike "*successful*"}){
    $message += $array | where {$_.repl_status -notlike "*successful*"} | select Source_DC,NC,Destination_DC,Repl_Status | ConvertTo-Html -Head $html_head -Property Source_DC,NC,Destination_DC,Repl_Status
    send_mail $message $subject
} ELSE {
    $message += "<table style='color:gray;font-family:verdana,arial,sans-serif;font-size:11px;'>No problem detected</table>"
}
 
$message += $status_repl_ok
$message += $array | where {$_.repl_status -like "*successful*"} | select Source_DC,NC,Destination_DC,Repl_Status | ConvertTo-Html -Head $html_head -Property Source_DC,NC,Destination_DC,Repl_Status
$message | Out-File "$report_path\ad_repl_status_$date.html"