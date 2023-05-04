<#
    Author: Parveen Hooda
    Email: parveen.hooda@outlook.com
    Please contact in case running into any issues.
#>

# Defining the function
Function FindMissingPatch{

        # Getting the machine names
        $machines = Get-Content C:\Temp\machines.txt
       # Defining patches that need to be searched for in an array. The one used are for WannaCry ransomware.
        $patches = 'KB4012214','KB4012213','KB4012216','KB4012217','KB4012215','KB4012212','KB4012598', 'KB4012606', 'KB4015221', 'KB4013198', 'KB4013429'

       # Loop to cycle the process through each machine
        foreach ($comp in $machines){

            # Print the host name on the console
            Write-Host "Running on the machine with IP $comp"

            $hotfix = @()
            # Checking for the hotfix and matching with the hotfix with the hotfix defined in array
            $hotfix =  Get-HotFix -ComputerName $comp | Where {$patches -contains $_.HotFixID} -ErrorAction SilentlyContinue

                if ($hotfix -eq $null)
                {
                    # Getting the eventlog to check why the Hotfix was not installed.        
                    $log = Get-WinEvent -ComputerName $comp -FilterHashtable @{logname='system'; providername='.Net Runtime'; keywords=36028797018963968;level='2'} | Where {$_.Message -like "*failed*"} | Select MachineName, TimeCreated, Message
	                $log

                    #Saving the report to CSV
	                $log | Export-CSV c:\temp\hotfixmissing.csv -NoTypeInformation -Append

                }
                else 
                {

                    #Printing and Exporting the Hotfix installed report in CSV
                    $hotfix
                    $hotfix | Export-Csv C:\Temp\hotfix.csv -NoTypeInformation -Append
                }
        }
}
#Calling the Function.
FindMissingPatch