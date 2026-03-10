# Auf jedem Session Host ausführen

$profilesParentKey = 'HKLM:\SOFTWARE\FSLogix'
$profilesChildKey = 'Profiles'
$storageAccountName = 'adds69118'
$fileShareName = 'profiles'
New-Item -Path $profilesParentKey -Name $profilesChildKey -Force
New-ItemProperty -Path $profilesParentKey\$profilesChildKey -Name 'Enabled' -PropertyType DWord -Value 1
New-ItemProperty -Path $profilesParentKey\$profilesChildKey -Name 'VHDLocations' -PropertyType MultiString -Value "\\$storageAccountName.file.core.windows.net\$fileShareName"

lusrmgr.msc
regedit.exe