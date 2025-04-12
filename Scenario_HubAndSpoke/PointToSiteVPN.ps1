# Download and install VPN Client Software (PowerShell)
# -------------------------------------------------------------------
# see  https://wmatthyssen.com/2022/01/05/azure-powershell-script-configure-a-p2s-vpn-to-an-existing-vnet-using-azure-certificate-authentication/




# Download and install VPN Client Software (Azure CLI)
# -------------------------------------------------------------------
# Should be 
#   $rgName = 'rg-hub'
#   $gatewayName = 'vgw-hub'
$rgName
$gatewayName

$uri = az network vnet-gateway vpn-client generate `
    --processor-architecture Amd64 `
    --name $gatewayName --resource-group $rgName `
    --output tsv

$vpnZipPath = "$env:HOMEPATH\Downloads"
# Remove the old VPN client
Remove-Item -Path $vpnZipPath\VpnClient -Recurse -Force
Remove-Item -Path $vpnZipPath\VpnClient.zip -Force
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
Get-NetRoute -AddressFamily IPv4 -DestinationPrefix '10.0.0.0/16','10.1.0.0/16','10.2.0.0/16','10.3.0.0/16'

#   Test  dc1 (10.1.0.200), svr1 (10.3.0.4)
Test-NetConnection 10.1.0.200 -Port 3389
mstsc -v 10.1.0.200    # Remove RD Gateway!


# Clean up
# -------------------------------------------------------------------
# Disconnect and remove VPN
cmd.exe /C "start ms-settings:network-vpn"

# Remove VPN Client
Remove-Item -Path $vpnZipPath\VpnClient -Recurse -Force
Remove-Item -Path $vpnZipPath\VpnClient.zip -Force




# Access Private EP 10.1.0.4 connected to blob service of storage account 'private69118'
# --------------------------------------------------------------------------------------

#   *** From dc1 *****
# We are in the same Vnet as the private EP [10.1.0.200]
Get-NetIPConfiguration

# Is Private EP reachable by IP address? [Yes]
Test-NetConnection -ComputerName 10.1.0.4 -Port 443

# Is blob accessible by IP address? [No, certificate error]
Invoke-WebRequest -Uri https://10.1.0.4/txt/Hello.txt -UseBasicParsing | % content

# Name resolution private69118.blob.core.windows.net --> 10.1.0.4 available? [Yes via linked private DNS zone]
Resolve-DnsName -Name private69118.blob.core.windows.net -Type A

# -------------------------------------------------------
# Private EP is already integrated with private DNS zone.
# -------------------------------------------------------

# Blob is accessible
Test-NetConnection -ComputerName private69118.blob.core.windows.net -Port 443
Invoke-WebRequest -Uri https://private69118.blob.core.windows.net/txt/Hello.txt -UseBasicParsing | % content




#   *** From svr1 *****
# We are in a different Vnet as the private EP [10.3.0.4]
Get-NetIPConfiguration

# Is Private EP reachable by IP address? [Yes]
Test-NetConnection -ComputerName 10.1.0.4 -Port 443

# Is blob accessible by IP address? [No, certificate error]
Invoke-WebRequest -Uri https://10.1.0.4/txt/Hello.txt -UseBasicParsing | % content

# Name resolution private69118.blob.core.windows.net --> 10.1.0.4 available? 
#   [No, there is no linked private DNS zone, public DNS yields public IP address]
Resolve-DnsName -Name private69118.blob.core.windows.net -Type A

# --------------------------------
# Link Vnet to private DNS zone!
# --------------------------------

# Now it works
Resolve-DnsName -Name private69118.blob.core.windows.net -Type A
Test-NetConnection -ComputerName private69118.blob.core.windows.net -Port 443
Invoke-WebRequest -Uri https://private69118.blob.core.windows.net/txt/Hello.txt -UseBasicParsing | % content




#   *** From Notebook VPN Client *****
Test-NetConnection -ComputerName 10.1.0.4 -Port 443
Resolve-DnsName -Name private69118.blob.core.windows.net -Type A

# -------------------------------------------------------------
# Edit c:\windows\system32\drivers\etc\hosts   as Administrator
#      10.1.0.4  private69118.blob.core.windows.net
# --------------------------------------------------------------

# Now it works
Resolve-DnsName -Name private69118.blob.core.windows.net -Type A
Test-NetConnection -ComputerName private69118.blob.core.windows.net -Port 443
Invoke-WebRequest -Uri https://private69118.blob.core.windows.net/txt/Hello.txt -UseBasicParsing | % content

