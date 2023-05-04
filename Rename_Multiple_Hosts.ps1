# References:
# https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.management/rename-computer


# Ask and store credentials (avoid asking them for every item within the matrix)
$credential = Get-Credential


# Load hostnames matrix into a variable
$a = Import-Csv Rename_Computer_Names.csv -Header OldName, NewName


# Loop the matrix and make the rename. Restart has been commented for avoiding computer restart accidentally.
# Uncoment it if you need it.

Foreach ( $Server in $a ) {
    Rename-Computer -ComputerName $Server.OldName -NewName $Server.NewName -DomainCredential $credential -Force # -Restart
    }