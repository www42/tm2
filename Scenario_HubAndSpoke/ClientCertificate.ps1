# ------------------------------------------------------------------------------------
# Scenario Hub-and-Spoke
# ------------------------------------------------------------------------------------
# This script generates a client certificate and signs it with the root certificate created before
# ------------------------------------------------------------------------------------
# Requires Windows PowerShell 5.1  (due to 'cert:')
# ------------------------------------------------------------------------------------

# Import Root Certificate (needed to sign Client Certificate)
# -------------------------------------------------------------------
dir './Scenario_HubAndSpoke\RootCertificate.pfx'
$password = Get-Content './Scenario_HubAndSpoke\PASSWORDS' | ConvertFrom-Json | % { $_.pfxPassword } | ConvertTo-SecureString
$rootCertificate = Import-PfxCertificate -FilePath './Scenario_HubAndSpoke\RootCertificate.pfx' -CertStoreLocation 'Cert:\CurrentUser\My' -Exportable -Password $password
$rootCertificate | Format-List Thumbprint,FriendlyName,Subject,NotBefore,NotAfter


# Create VPN Client Certificate
# -------------------------------------------------------------------
$friendlyName = 'AZ Training VPN Client Certificate'
$subject = 'cn=AZ Training VPN Client'
$clientCertificate = New-SelfSignedCertificate `
    -FriendlyName $friendlyName `
    -Subject $subject `
    -Type Custom `
    -KeySpec Signature `
    -KeyExportPolicy Exportable `
    -HashAlgorithm sha256 `
    -KeyLength 2048 `
    -Signer $rootCertificate `
    -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2") `
    -CertStoreLocation 'Cert:\CurrentUser\My'

dir $clientCertificate.PSPath | Format-List FriendlyName,Subject,Issuer,NotBefore,NotAfter


# Download and install VPN Client Software (PowerShell)
# -------------------------------------------------------------------
# see  https://wmatthyssen.com/2022/01/05/azure-powershell-script-configure-a-p2s-vpn-to-an-existing-vnet-using-azure-certificate-authentication/

# Download and install VPN Client Software (Azure CLI)
# -------------------------------------------------------------------
$rgName = $templateParams.resourceGroupName
$gatewayName = $templateParams.gatewayName

$uri = az network vnet-gateway vpn-client generate `
    --processor-architecture Amd64 `
    --name $gatewayName --resource-group $rgName `
    --output tsv

$vpnZipPath = "$env:HOMEPATH\Downloads"
Invoke-RestMethod -Uri $uri -OutFile $vpnZipPath\VpnClient.zip
dir $vpnZipPath\VpnClient.zip
Expand-Archive -Path $vpnZipPath\VpnClient.zip -DestinationPath $vpnZipPath\VpnClient

# Install VPN client manually
& $vpnZipPath\VpnClient\WindowsAmd64\VpnClientSetupAmd64.exe

# Connect
cmd.exe /C "start ms-settings:network-vpn"

# Test connectivity
Get-NetIPConfiguration | Format-Table InterfaceIndex,InterfaceAlias,InterfaceDescription,IPv4Address
$hubIpRange = '10.0.0.0/16'
$hybridIpRange = '10.1.0.0/16'
Get-NetRoute -DestinationPrefix $hubIpRange,$hybridIpRange
Test-NetConnection 10.1.0.200 -Port 3389
mstsc -v 10.1.0.200




# Cleanup
# -------------------------------------------------------------------
#Remove-Item -Path $RootCertificate.PSPath
#Remove-Item -Path $ClientCertificate.PSPath
dir Cert:/CurrentUser/My
cmd.exe /C "start ms-settings:network-vpn"
