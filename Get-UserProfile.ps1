$Profiles = Get-CimInstance -ClassName Win32_UserProfile -Filter "Special=False" |
    Add-Member -MemberType ScriptProperty -Name UserName -Value { (New-Object System.Security.Principal.SecurityIdentifier($this.Sid)).Translate([System.Security.Principal.NTAccount]).Value } -PassThru | 
    Select UserName, SID, LastUseTime, LocalPath, Loaded | Sort UserName

$ProfileDetails = @()

foreach ($folder in $Profiles){
    
    $A = Get-Item -Path $folder.LocalPath
    # $A.CreationTime
    # $A.Parent


    $Hash =  [ordered]@{
            UserName      = $folder.UserName
            SID           = $folder.SID
            LastUseTime   = $folder.LastUseTime
            LocalPath     = $folder.LocalPath
            Loaded        = $folder.Loaded
            CreationTime  = $A.CreationTime
            ModifiedDate  = $A.LastWriteTime
        
    }

    $Object = New-Object psobject -Property $Hash
    $ProfileDetails += $Object

}

$ProfileDetails | Out-GridView

$Count = 0
$Flag = 0

foreach ($Item in $Profiles){
    IF ([string]::IsNullOrWhiteSpace($Item.UserName)){
    $Count ++
    $Flag = 1
    }
}

IF ($Flag -eq 1) {
    Write-Host ""
    Write-Warning "There are $Count Unknown profiles in $env:COMPUTERNAME"
    Write-Host ""
}


$Selected = $Profiles | Out-GridView -PassThru -Title "Select User Profile"

$UnknownProfiles = @()
$KnownProfiles = @()

foreach ($Item in $Selected){
    IF (-NOT(Test-Path ($Item.LocalPath))){
        Write-Warning "Path '$($Item.LocalPath)' does not exist. Delete this profile entry from the Registry"
        }

    ELSE {
        $Size = Get-ChildItem -Path $($Item.LocalPath) -Recurse -Force -ErrorAction SilentlyContinue
        $ProfileSizeGB = "{0:N2} GB" -f (($Size | Measure-Object -Property Length -Sum).Sum / 1GB)
        $ProfileSizeMB = "{0:N2} MB" -f (($Size | Measure-Object -Property Length -Sum).Sum / 1MB)

        IF ([string]::IsNullOrWhiteSpace($Item.UserName)) {
            
            $Hash1 =  [ordered]@{
                UserName       = $Item.UserName
                SID            = $Item.SID
                LastUseTime    = $Item.LastUseTime
                LocalPath      = $Item.LocalPath
                ProfileSizeGB  = $ProfileSizeGB
                ProfileSizeMB  = $ProfileSizeMB
                Loaded         = $Item.Loaded
            }
        
            $NewObject1 = New-Object psobject -Property $Hash1
            $UnknownProfiles += $NewObject1

        } IF (-NOT([string]::IsNullOrWhiteSpace($Item.UserName))) {

            $Hashknown =  [ordered]@{
                UserName       = $Item.UserName
                SID            = $Item.SID
                LastUseTime    = $Item.LastUseTime
                LocalPath      = $Item.LocalPath
                ProfileSizeGB  = $ProfileSizeGB
                ProfileSizeMB  = $ProfileSizeMB
                Loaded         = $Item.Loaded
            }

            $NewObject2 = New-Object psobject -Property $Hashknown
            $KnownProfiles += $NewObject2

        }
    }
}

Write-Host""

IF ($UnknownProfiles.Count -gt 0){
    Write-Host "Selected Unknown Profiles" -ForegroundColor Cyan
    $UnknownProfiles | Sort LocalPath | ft -AutoSize | Out-Host
}

IF ($KnownProfiles.Count -gt 0){
    Write-Host "Selected Known Profiles" -ForegroundColor Cyan
    $KnownProfiles | Sort UserName | ft -AutoSize | Out-Host
}