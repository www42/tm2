[cmdletbinding()]
param (
    [string]$NIC1IPAddress,
    [string]$NIC2IPAddress,
    [string]$GhostedSubnetPrefix,
    [string]$VirtualNetworkPrefix
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module Subnet -Force

New-VMSwitch -Name "NestedSwitch" -SwitchType Internal

$NIC1IP = Get-NetIPAddress | Where-Object -Property AddressFamily -EQ IPv4 | Where-Object -Property IPAddress -EQ $NIC1IPAddress
$NIC2IP = Get-NetIPAddress | Where-Object -Property AddressFamily -EQ IPv4 | Where-Object -Property IPAddress -EQ $NIC2IPAddress

$NATSubnet = Get-Subnet -IP $NIC1IP.IPAddress -MaskBits $NIC1IP.PrefixLength
$HyperVSubnet = Get-Subnet -IP $NIC2IP.IPAddress -MaskBits $NIC2IP.PrefixLength
$NestedSubnet = Get-Subnet $GhostedSubnetPrefix
$VirtualNetwork = Get-Subnet $VirtualNetworkPrefix

New-NetIPAddress -IPAddress $NestedSubnet.HostAddresses[0] -PrefixLength $NestedSubnet.MaskBits -InterfaceAlias "vEthernet (NestedSwitch)"
New-NetNat -Name "NestedSwitch" -InternalIPInterfaceAddressPrefix "$GhostedSubnetPrefix"

Add-DhcpServerv4Scope -Name "Nested VMs" -StartRange $NestedSubnet.HostAddresses[1] -EndRange $NestedSubnet.HostAddresses[-1] -SubnetMask $NestedSubnet.SubnetMask
Set-DhcpServerv4OptionValue -DnsServer 168.63.129.16 -Router $NestedSubnet.HostAddresses[0]

Install-RemoteAccess -VpnType RoutingOnly
cmd.exe /c "netsh routing ip nat install"
cmd.exe /c "netsh routing ip nat add interface ""$($NIC1IP.InterfaceAlias)"""
cmd.exe /c "netsh routing ip add persistentroute dest=$($NatSubnet.NetworkAddress) mask=$($NATSubnet.SubnetMask) name=""$($NIC1IP.InterfaceAlias)"" nhop=$($NATSubnet.HostAddresses[0])"
cmd.exe /c "netsh routing ip add persistentroute dest=$($VirtualNetwork.NetworkAddress) mask=$($VirtualNetwork.SubnetMask) name=""$($NIC2IP.InterfaceAlias)"" nhop=$($HyperVSubnet.HostAddresses[0])"

Get-Disk | Where-Object -Property PartitionStyle -EQ "RAW" | Initialize-Disk -PartitionStyle GPT -PassThru | New-Volume -FileSystem NTFS -AllocationUnitSize 65536 -DriveLetter F -FriendlyName "Hyper-V"

# --- My supplement --------------------------------------

# Set time zone
Set-TimeZone -Id 'W. Europe Standard Time'

# Create folders
New-Item -ItemType Directory -Path F:\VMs
New-Item -ItemType Directory -Path F:\VHDs

# Disable IE Enhanced Security for Administrators
$RegEntry = 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}'
Set-ItemProperty -Path $RegEntry -Name 'IsInstalled' -Value 0
Stop-Process -Name Explorer

# Disable Try Windows Admin Center
$RegEntry = 'HKLM:\SOFTWARE\Microsoft\ServerManager'
New-ItemProperty -Path $RegEntry -Name 'DoNotPopWACConsoleAtSMLaunch' -Value 1 

# Shortcut on Desktop to Eval Center workaround
$wsShell = New-Object -ComObject WScript.Shell
$shortcut = $wsShell.CreateShortcut("C:\Users\Default\Desktop\EvalCenter.lnk")
$shortcut.TargetPath = "https://techcommunity.microsoft.com/t5/windows-11/accessing-trials-and-kits-for-windows-eval-center-workaround/m-p/3361125"
$shortcut.Save()
