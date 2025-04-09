# ------------------------------------------------------------------------------------
# Scenario Hub-and-Spoke
# ------------------------------------------------------------------------------------
# This script 
#   * imports the root certificate created before
#   * creates a client certificate for use on an Azure Virtual Gateway (VPN)
#       * the client certificate is valid for 1 year
#       * the client certificate is signed with the root certificate
#   * removes the root certificate (no longer needed)
#
# ------------------------------------------------------------------------------------
# Requires Windows PowerShell 5.1  (due to 'cert:')
# ------------------------------------------------------------------------------------



# Import Root Certificate (to sign Client Certificate)
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



# Delete Root Certificate (no longer needed)
# -------------------------------------------------------------------
Remove-Item -Path $rootCertificate.PSPath
dir Cert:/CurrentUser/My
