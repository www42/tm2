# Download and install VPN Client Software (PowerShell)
# -------------------------------------------------------------------
# see  https://wmatthyssen.com/2022/01/05/azure-powershell-script-configure-a-p2s-vpn-to-an-existing-vnet-using-azure-certificate-authentication/




# Download and install VPN Client Software (Azure CLI)
# -------------------------------------------------------------------
$rgName
$gatewayName

$uri = az network vnet-gateway vpn-client generate `
    --processor-architecture Amd64 `
    --name $gatewayName --resource-group $rgName `
    --output tsv

$vpnZipPath = "$env:HOMEPATH\Downloads"
Invoke-RestMethod -Uri $uri -OutFile $vpnZipPath\VpnClient.zip
dir $vpnZipPath\VpnClient.zip
Expand-Archive -Path $vpnZipPath\VpnClient.zip -DestinationPath $vpnZipPath\VpnClient
dir $vpnZipPath\VpnClient

# Install VPN client manually
& $vpnZipPath\VpnClient\WindowsAmd64\VpnClientSetupAmd64.exe

# Connect VPN
cmd.exe /C "start ms-settings:network-vpn"

# Test connectivity
Get-NetIPConfiguration | Format-Table InterfaceIndex,InterfaceAlias,InterfaceDescription,IPv4Address
Get-NetRoute -AddressFamily IPv4 -DestinationPrefix '10.0.0.0/16','10.1.0.0/16'
Get-NetRoute -AddressFamily IPv4 -DestinationPrefix '10.0.0.0/16','10.1.0.0/16','10.2.0.0/16','10.3.0.0/16'

#   Test 1:   dc1 (10.1.0.200), svr1 (10.3.0.4)
Test-NetConnection 10.1.0.200 -Port 3389
mstsc -v 10.1.0.200    # Remove RD Gateway!


#   Test 2:   private EP storage (10.1.0.4)
Test-NetConnection 10.1.0.4 -Port 443
# DNS --> Does not work
Resolve-DnsName -Name private69118.blob.core.windows.net
Test-NetConnection -ComputerName private69118.blob.core.windows.net -Port 443 -InformationLevel 'Detailed'
Invoke-WebRequest -Uri https://private69118.blob.core.windows.net/web/Hello.html -UseBasicParsing | % content




# Disconnect and remove VPN
cmd.exe /C "start ms-settings:network-vpn"

# Remove VPN Client
Remove-Item -Path $vpnZipPath\VpnClient -Recurse -Force
Remove-Item -Path $vpnZipPath\VpnClient.zip -Force