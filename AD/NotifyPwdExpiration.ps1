 ##############################################################################################
  
 #           Password Expiration Notification 
 # 
 # This script is designed to notify users via email of an upcoming password change. 
 # This script requires your forest and domain functional level to be 2008 R2. 
 # You must have active directory client tools installed to run this or run it from a DC.
 #
 # Source: ps1scripting.blogspot.com
 # 
 #
##############################################################################################
 

 # Creating remote PowerShell session to Exchange Online
 $credential = Get-Credential
 Import-Module MsOnline
 Connect-MsolService -Credential $credential
 $exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
 Import-PSSession $exchangeSession -DisableNameChecking


 # Gathering Default Domain and removing unwanted characters
 $TenantDefaultDomain = Get-MsolDomain | Where-Object {$_.IsDefault -eq 'True'} | Select Name
 $TenantDefaultDomain = $TenantDefaultDomain -replace "@{Name="
 $TenantDefaultDomain = $TenantDefaultDomain -replace "}"

  
 #Loads the active directory module to enable AD cmdlets 
 import-module activedirectory
  
 
 #Queries all accounts in AD domain and stores them in username variable 
 $username = get-aduser -filter * | select -ExpandProperty samaccountname
  

 #Foreach loop is run against each account stored in the username variable 
 foreach($user in $username){
  
   #gets current date and stores in now variable
   $now = get-date
  
   #gets date of when password was last set for a user
   $passlastset = get-aduser $user -properties passwordlastset | select -ExpandProperty passwordlastset
  
 
  
   #calculates password expirationdate by adding 90 days to the password last set date
   $passexpirationdate = $passlastset.adddays(90)
  
 
  
   #calculates the number of days until a user's password will expire
   $daystilexpire = $passexpirationdate - $now | select -ExpandProperty days
  
 
  
     #if statement to select only accounts with expiration greater than 0 days
     if($daystilexpire -gt "0"){
  
  
       #if statment to further filter accounts from above if statement. This selects accounts with less than 5 days until expiration.
       if($daystilexpire -le "14"){
  
 
  
         #generates email to user using .net smtpclient to notify them of how many days until their password expires.
         $emailFrom = "emailaddress@yourdomain.com"
         $emailTo = "$user@$TenantDefaultDomain"
         $subject = "Password Expiration Notice"
         $body = "Your password will expire in $daystilexpire days. Please change your password soon to avoid being locked out of your account."
         $smtpServer = "Enter IP address of your SMTP Server Here"
         $smtp = new-object Net.Mail.SmtpClient($smtpServer)
         $smtp.Send($emailFrom, $emailTo, $subject, $body)
  
  
       }
      }
   }