# ------------------------------------------------------------------------------------
# Scenario Hub-and-Spoke
# ------------------------------------------------------------------------------------
# This script creates root certificate 
#   * for use on an Azure Virtual Gateway (VPN)
#   * valid for 2 year
#   * root certificate's public data has to be copied into bicep template
#   * root certificate is exported as 'RootCertificate.pfx' to sign a client vpn certificate later
# ------------------------------------------------------------------------------------

$friendlyName = 'Atropos Root Certificate'
$subject = 'cn=Atropos AG'
$pfxPassword = Read-Host -Prompt 'pfx password'

$rootCertificate = New-SelfSignedCertificate `
    -FriendlyName $friendlyName `
    -Subject $subject `
    -Type Custom `
    -KeySpec Signature `
    -KeyExportPolicy Exportable `
    -HashAlgorithm sha256 `
    -KeyLength 2048 `
    -KeyUsageProperty Sign `
    -KeyUsage CertSign `
    -NotAfter (Get-Date).AddYears(2) `
    -CertStoreLocation 'Cert:\CurrentUser\My'

dir $rootCertificate.PSPath | Format-List FriendlyName,Subject,NotBefore,NotAfter

# Public certificate data to be copied into Bicep template (or into Azure Portal)
[System.Convert]::ToBase64String($rootCertificate.RawData) | clip 
#  -->  $rootCertificateData  in DEPLOY.ps1

# Export root certificate
$rootCertificate | Export-PfxCertificate -FilePath './Scenario_HubAndSpoke/Atropos__RootCertificate.pfx' -Password $($pfxPassword | ConvertTo-SecureString -AsPlainText)

# Remove root certificate (We have a pfx exported) 
Remove-Item -Path $rootCertificate.PSPath
dir 'Cert:\CurrentUser\My'
