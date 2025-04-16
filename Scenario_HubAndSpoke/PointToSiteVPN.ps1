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




# Access Private Endpoint 'pep-storage'
# ------------------------------------------------------

#  * Private Endpoint 'pep-storage' is connected to blob service of Storage Account 'private69118'.
#  * Private Endpoint 'pep-storage' has ip address 10.1.0.4 from 'Subnet0' in 'vnet-hybrididentity'. This is a "normal" IP address accessible from the Vnet, via default routing or UDR.
#  * You cannot use the IP address to access the Storage Account 'private69118' bacause the certificate is not valid for the IP address. 
Invoke-WebRequest -Uri https://10.1.0.4/txt/Hello.txt -UseBasicParsing | % content  # Certificate error
#  * You need to use the DNS name 'private69118.blob.core.windows.net'.
#
#  How to translate 'private69118.blob.core.windows.net' to '10.1.0.4'?  DNS of course!
#
#  private69118.blob.core.windows.net             CNAME     private69118.privatelink.blob.core.windows.net
#                                                                        ^^^^^^^^^^^
#  private69118.privatelink.blob.core.windows.net  A        10.1.0.4
#
#  The A record is in the Private DNS zone 'privatelink.blob.core.windows.net'.
#  The CNAME record is in the Public DNS zone 'blob.core.windows.net'.
#
#
#  Let's have a look to three cases:
#   a) Client is on the Vnet as the Private Endpoint               --> Private DNS zone is already linked to Vnet (default in Azure Portal)
#   b) Client is on a different Vnet as the Private Endpoint       --> Link the Private DNS zone to the Vnet!
#   c) Client is on prem connectet to Azure via point-to-site VPN  --> Create your own on prem DNS solution, e.g. etc/hosts file


#  Name Resolution
#    a)
Get-AzPrivateDnsZone -ResourceGroupName 'rg-hybrididentity' -Name 'privatelink.blob.core.windows.net' | fl Name,ResourceGroupName,NumberOfRecordSets,NumberOfVirtualNetworkLinks



# Test from a client 
#   a) dc1
#   b) svr1
#   c) Laptop (VPN)
Get-NetIPConfiguration
Test-NetConnection -ComputerName 10.1.0.4 -Port 443
Resolve-DnsName -Name private69118.blob.core.windows.net -Type A
Invoke-WebRequest -Uri https://private69118.blob.core.windows.net/txt/Hello.txt -UseBasicParsing | % content




# -------------------------------------------------------------
# Edit c:\windows\system32\drivers\etc\hosts   as Administrator
#      10.1.0.4  private69118.blob.core.windows.net
# --------------------------------------------------------------

$rgName = 'rg-hybrididentity'
$zoneName = 'privatelink.blob.core.windows.net'
Get-AzPrivateDnsZone -Name $zoneName | fl Name,ResourceGroupName,NumberOfRecordSets,NumberOfVirtualNetworkLinks
Get-AzPrivateDnsRecordSet -ZoneName $zoneName -ResourceGroupName $rgName -Name 'private69118' -RecordType A | fl Name,RecordType,Records
Get-AzPrivateDnsVirtualNetworkLink -ZoneName $zoneName -ResourceGroupName $rgName | fl Name,VirtualNetworkId,EnableRegistration,VirtualNetworkLinkState

# Link private DNS zone to VNet
$virtualNetworkId = '/subscriptions/fa366244-df54-48f8-83c2-e1739ef3c4f1/resourceGroups/rg-nestedvirtualization/providers/Microsoft.Network/virtualNetworks/vnet-nestedvirtualization'
$linkName = 'nestedvirtualizationLink'
New-AzPrivateDnsVirtualNetworkLink -Name $linkName -ResourceGroupName $rgName -ZoneName $zoneName -VirtualNetworkId $virtualNetworkId -EnableRegistration:$false

# Remove link
$link = Get-AzPrivateDnsVirtualNetworkLink -ZoneName $zoneName -ResourceGroupName $rgName -Name $linkName
$link.ResourceId
Remove-AzPrivateDnsVirtualNetworkLink -ResourceId $link.ResourceId

# For each service
# ----------------
# see https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns
$zoneName = privatelink.blob.core.windows.net
$zoneName = privatelink.file.core.windows.net
$zoneName = privatelink.web.core.windows.net
$zoneName = privatelink.vaultcore.azure.net
$zoneName = privatelink.azurewebsites.net
$zoneName = privatelink.azurecr.io

# 2. Private DNS zone
# see https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns-integration
New-AzPrivateDnsZone -Name $zoneName -ResourceGroupName $rgName -ZoneType Private -Force


# 3. Link private DNS zone - VNet

# For each Private Endpoint
# -------------------------
# 4. Private Endpoint
# 5. A-Record