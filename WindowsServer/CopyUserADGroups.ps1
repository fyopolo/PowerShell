$SourceUser = Read-Host "Type SamAccountName of SOURCE User"
$TargetUser = Read-Host "Type SamAccountName of TARGET User"

Import-Module ActiveDirectory

$SourceGroups = Get-ADUser $SourceUser -Properties * | Select -ExpandProperty MemberOf | Sort
$TargetGroups = Get-ADUser $TargetUser -Properties * | Select -ExpandProperty MemberOf | Sort

# Get-ADGroup
# Get-ADGroupMember fyopolo

#### use admin-vhegde as SOURCE SAM or mbalgure
#### use fyopolo as TARGET SAM

Function Compare-ADUsers(){


}

$SourceUserTable = @()

foreach ($Group in $SourceGroups){

    $Hash = [ordered]@{
    SourceUser = $SourceUser
    MemberOf = $($Group.Split(",")[0]).Replace("CN=","")

    }

    $TableObject = New-Object psobject -Property $Hash
    $SourceUserTable += $TableObject

}

Write-Host "User $SourceUser is member of $($SourceUserTable.Count) security groups" -ForegroundColor Cyan
$SourceUserTable | Out-Host


$TargetUserTable = @()

foreach ($Group in $TargetGroups){

    $Hash = [ordered]@{
    TargetUser = $TargetUser
    MemberOf   = $($Group.Split(",")[0]).Replace("CN=","")

    }

    $TableObject = New-Object psobject -Property $Hash
    $TargetUserTable += $TableObject

}

Write-Host "User $TargetUser is member of $($TargetUserTable.Count) security groups" -ForegroundColor Cyan
$TargetUserTable | Out-Host


IF ($TargetUserTable.Count -gt $SourceUserTable.Count){

    Write-Warning "Target user is member of more groups than source user. Terminating script execution"
    Exit
    
    ELSE{
        Write-Host "Count comparison is valid. Source user belongs to more groups than target user"
        Write-Host "Storing difference. Please stand by..." -ForegroundColor Green

    }

}

# $Mix = $SourceUserTable + $TargetUserTable


$UsersComparison = Compare-Object -ReferenceObject $AliasList -DifferenceObject $($UsersOBJ.SearchingFor) -IncludeEqual -ExcludeDifferent | Sort-Object InputObject
$MatchingUsers = $UsersOBJ | Where-Object {$UsersComparison.InputObject -eq $_.SearchingFor}

$GroupComparison = Compare-Object -ReferenceObject $($SourceUserTable.MemberOf) -DifferenceObject $($TargetUserTable.MemberOf) -PassThru | Sort-Object InputObject

$GroupComparison = Compare-Object -ReferenceObject $($SourceUserTable.MemberOf) -DifferenceObject $($TargetUserTable.MemberOf) -PassThru | Sort-Object InputObject

$GroupComparison = Compare-Object -ReferenceObject $SourceUserTable.MemberOf -DifferenceObject $TargetUserTable.MemberOf -IncludeEqual | Sort-Object InputObject


Write-Host 
$MatchingGroups = $Mix | Where-Object {$GroupsComparison.InputObject -eq $_.MemberOf}

$GroupComparison.target


$GroupComparison