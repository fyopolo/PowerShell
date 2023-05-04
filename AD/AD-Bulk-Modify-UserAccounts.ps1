Import-Module ActiveDirectory

$ErrorActionPreference = "SilentlyContinue"
$ADUsers = Import-Csv "D:\Scripts\PowerShell\AD\bulk_users2.csv"

foreach ($User in $ADUsers){

Set-ADUser -Identity $($User.SamAccountName) `
    -SamAccountName $User.SamAccountName `
    -DisplayName $User.DisplayName `
    -GivenName $User.FirstName `
    -Initials $User.MiddleInitial `
    -Surname $User.LastName `
    -EmailAddress $User.email `
    -UserPrincipalName $User.UPN `
    -StreetAddress $User.StreetAddress `
    -City $User.City `
    -PostalCode $User.ZipCode `
    -State $User.State `
    -Country $User.Country `
    -Department $User.Department `
    -OfficePhone $User.OfficePhone `
    -MobilePhone $User.MobilePhone `
    -Title $User.JobTitle `
    -Company $User.Company `
    -PasswordNotRequired `
    -Enabled $true

Get-ADUser -Identity ($User.SamAccountName) | Rename-ADObject -NewName $User.DisplayName

}

<# EXPLICACION

$ErrorActionPreference
    Dado que algunas celdas del Excel no tienen información, el Set-ADUser da error cuando se encuentra
    con esta situación. Por eso uso la variable (nativa de PS) para el manejo de errores.

Set-ADUser
    No puede modificar la propiedad FULL NAME del objeto. Por tal motivo
    incluyo el cmdlet RENAME-ADOBJECT.
    Porqué hice esto? Porque si alguien de RRHH te modifica el DisplayName, FirstName ó LastName
    vos vas a querer que el full name sea una combinación de DisplayName y FullName (a menos que
    las políticas de tu AD sean LastName y FullName.

En conclusión:
    La información que esté en el CSV es la que va a comandar lo que veas en ADUC.

#>