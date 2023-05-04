# Import-Module ActiveDirectory

$OUs = Get-ADOrganizationalUnit -Filter * -SearchScope Subtree -Properties * | Sort CanonicalName
$Array = @()

foreach ($OU in $OUs){

    Write-Host "Searching for users in" $OU -ForegroundColor Cyan
    $UsersInOU = Get-ADUser -Filter * -SearchBase $OU -Properties * -SearchScope Subtree
     
    IF ($UsersInOU.Count -gt 0) {

        foreach ($Item in $UsersInOU) {
        
            IF (-NOT($Array.SamAccountName -contains $Item.SamAccountName)){
            
                IF (-NOT([string]::IsNullOrWhiteSpace($Item.LastLogon) -OR ($Item.lastLogon -like "*null*"))) { $LastLogon = ($(w32tm /ntte $Item.LastLogon) -split " - ",2)[1] } ELSE { $LastLogon = "Never" }
            
                $Hash =  [ordered]@{
                    OU                = ($Item.CanonicalName).TrimEnd($Item.Name).TrimEnd("/").Replace("/"," > ")
                    DisplayName       = $Item.DisplayName
                    UserName          = $Item.Name
                    SamAccountName    = $Item.SamAccountName
                    UserPrincipalName = $Item.UserPrincipalName
                    Enabled           = $Item.Enabled
                    LastLogon         = $LastLogon
                }
    
            $Object = New-Object psobject -Property $Hash
            $Array += $Object

            }
        }
    } ELSE { Write-Host "There are no users in $OU" -ForegroundColor DarkYellow }
}

$Array | Sort OU | Out-GridView