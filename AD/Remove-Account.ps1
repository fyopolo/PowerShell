datecutoff = (Get-Date).AddDays(-120)

Get-ADComputer -Properties LastLogonDate -Filter {LastLogonDate -lt $datecutoff} | Sort LastLogonDate | FT Name, LastLogonDate -Autosize

Get-ADComputer -Properties LastLogonDate -Filter {LastLogonDate -lt $datecutoff} | Set-ADComputer -Enabled $false -whatif


Get-ADUser -Properties LastLogonDate -Filter {LastLogonDate -lt $datecutoff} | Sort LastLogonDate | FT Name, LastLogonDate -Autosize
Get-ADUser -Properties LastLogonDate -Filter {LastLogonDate -lt $datecutoff} | Set-ADUser -Enabled $false -whatif