# Configure existing NSG for Windows Admin Center
# -----------------------------------------------
#   2 Outbound rules
#   1 Inbound rule

# Existing NSG
$nsg = Get-AzNetworkSecurityGroup -Name nsg-vm-monitoring-svr1 -ResourceGroupName rg-monitoring

# Allow Windows Admin Center (Outbound)
$nsg | Add-AzNetworkSecurityRuleConfig `
        -Name "PortForWACService"  `
        -Access Allow `
        -Protocol Tcp `
        -Direction Outbound `
        -Priority 100 `
        -DestinationAddressPrefix WindowsAdminCenter `
        -SourcePortRange * `
        -SourceAddressPrefix * `
        -DestinationPortRange 443

$nsg | Set-AzNetworkSecurityGroup

# Allow Azure AD (Outbound)
$nsg | Add-AzNetworkSecurityRuleConfig `
        -Name "PortForAADService"  `
        -Access Allow `
        -Protocol Tcp `
        -Direction Outbound `
        -Priority 101 `
        -DestinationAddressPrefix AzureActiveDirectory `
        -SourcePortRange * `
        -SourceAddressPrefix * `
        -DestinationPortRange 443

$nsg | Set-AzNetworkSecurityGroup

# Allow Windows Admin Center (Inbound)
$myIp = Invoke-WebRequest -uri "https://api.ipify.org/" | % Content

$nsg | Add-AzNetworkSecurityRuleConfig `
        -Name "WacAllowForMe"  `
        -Access Allow `
        -Protocol Tcp `
        -Direction Inbound `
        -Priority 100 `
        -DestinationAddressPrefix * `
        -SourcePortRange * `
        -SourceAddressPrefix "$myIp/32" `
        -DestinationPortRange 6516

$nsg | Set-AzNetworkSecurityGroup