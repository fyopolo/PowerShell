<#

Deployment mode: Microsoft Intune Portal

Whenever someone sends an email FROM a Shared Mailbox, that message will be stored in Shared Mailbox's sent items.

Set Shared Folder caching as Disabled. This is to improve Outlook Search in Shared Mailboxes.

#>

Set-ExecutionPolicy -ExecutionPolicy Bypass

$SMRegistryPath = "Registry::HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Outlook\Preferences\"
$Property1 = "DelegateSentItemsStyle"
$PropertyType1 = "DWORD"
$Value1 = "1"

IF (Test-Path $SMRegistryPath){
    New-ItemProperty -Path $SMRegistryPath -Name $Property1 -Value $Value1 -PropertyType $PropertyType1 -Force
}ELSE {
    New-Item -Path $SMRegistryPath
    New-ItemProperty -Path $SMRegistryPath -Name $Property1 -Value $Value1 -PropertyType $PropertyType1 -Force
}

# Disable Shared Folder caching

$OutlookCacheRegistryPath = "Registry::HKEY_CURRENT_USER\Software\Policies\Microsoft\Office\16.0\Outlook\Cached Mode\"

Function New-RecursiveItemProperty ($Path,$Name,$Value,$PropertyType) {
    foreach ($key in $OutlookCacheRegistryPath.split("\")) {
        $CurrentPath += $key + "\"
        if (!(Test-Path $CurrentPath)) {
           New-Item -Path $CurrentPath    
        }
    }
    New-ItemProperty -Path $CurrentPath -Name CacheOthersMail -value "0" -PropertyType "DWORD"
    New-ItemProperty -Path $CurrentPath -Name DownloadSharedFolders -value "0" -PropertyType "DWORD"
}

New-RecursiveItemProperty