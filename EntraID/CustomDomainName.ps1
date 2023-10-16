# ----------------------------------
# Tenant
#    --> Add custom domain name
# ----------------------------------
# Requires Windows PowerShell 5.1  (due to Module 'AzureAD')
$PSVersionTable


# --- Login --------------------------------------------------------------------------
Connect-AzureAD
Get-AzureADTenantDetail | Format-List DisplayName, `
@{n="TenantId";e={$_.ObjectId}}, `
@{n="VerifiedDomains";e={$_.VerifiedDomains.Name}} 

# Disconnect-AzureAD


# --- Add new Domain Name ------------------------------------------------------------
$domainName = 'trainymotion.com'
# $domainName = 'contoso.training'

New-AzureADDomain -Name $domainName
Get-AzureADDomain | Format-Table Name, IsVerified, IsDefault

# Get DNS verification TXT record (only RecordType Txt is significant, RecordType MX is dropped)
$verificationDnsRecord = Get-AzureADDomainVerificationDnsRecord -Name $domainName | Where-Object RecordType -EQ 'Txt'
$verificationDnsRecord  | Format-List Label, RecordType, Ttl, Text


# --- Go Daddy -----------------------------------------------------------------------
$apiKey    = Read-Host -Prompt 'Go Daddy API Key'
$apiSecret = Read-Host -Prompt 'Go Daddy API Secret'
@{'godaddyApiKey' = $apiKey; 'godaddyApiSecret' = $apiSecret} | ConvertTo-Json  | Out-File "./EntraID/GODADDY_API"

$apiKey    = Get-Content "./EntraID/GODADDY_API" | ConvertFrom-Json | % {$_.godaddyApiKey}
$apiSecret = Get-Content "./EntraID/GODADDY_API" | ConvertFrom-Json | % {$_.godaddyApiSecret}
$godaddyUrl = 'https://api.godaddy.com/v1/domains'
$headers = @{Authorization = "sso-key $($apiKey):$($apiSecret)"}

# List all active domains
(Invoke-RestMethod -Method GET -Uri $godaddyUrl -Headers $headers) | Where-Object status -EQ 'ACTIVE' | Format-Table domain,status,expires

# List all TXT records
Invoke-RestMethod -Method GET -Headers $headers -Uri "$godaddyUrl/$domainName/records/TXT"

# Delete *all* TXT records with name `@´
Invoke-RestMethod -Method DELETE -Headers $Headers -Uri "$godaddyUrl/$domainName/records/TXT/@"

# Create DNS verification TXT record
$bodyArray = @{
    name = "@"
    data = "$($verificationDnsRecord.Text)"
    ttl  =  $($verificationDnsRecord.Ttl)
    type = 'TXT'
}
$body = ConvertTo-Json @( $bodyArray)

$params = @{
    Method = "PATCH"
    Headers = $headers
    Body = $body
    Uri = "$godaddyUrl/$domainName/records"
    ContentType = "application/json"
}

Invoke-RestMethod @params

# Is the TXT record resolvable on public Internet?
Resolve-DnsName -Name $domainName -Type TXT 


# --- Verify new Domain Name ---------------------------------------------------------
Confirm-AzureADDomain -Name $domainName
Get-AzureADDomain | Format-Table Name, IsVerified, IsDefault

# --- Set new Domain Name as Primary Domain Name -------------------------------------
Set-AzureADDomain -Name $domainName -IsDefault $true
Get-AzureADDomain | Format-Table Name, IsVerified, IsDefault



# ==============================================================
#                  Remove custom domain
# ==============================================================

# Azure AD - set initial domain primary (in order to delete custom domain)
Get-AzureADDomain | Format-Table Name, IsVerified, IsDefault
$InitialDomain = (Get-AzureADDomain | Where-Object IsInitial -eq $true).Name
$InitialDomain | Set-AzureADDomain -IsDefault $true

# Get all objects referencing to custom domain
Get-AzureADDomainNameReference -Name $domainName

# List all Global Administrators
$GlobalAdministrator = Get-AzureADDirectoryRole | Where-Object DisplayName -eq 'Global Administrator'
Get-AzureADDirectoryRoleMember -ObjectId $GlobalAdministrator.ObjectId

# Dirty: Rename user's UPN to initial domain name
Get-AzureADDomainNameReference -Name $domainName | Where-Object ObjectType -EQ 'User' | ForEach-Object {
    $Name = $_.UserPrincipalName.split('@')[0]
    Set-AzureADUser -ObjectId $_.ObjectId -UserPrincipalName "$Name@$InitialDomain"
}

# Dirty: Delete Groups
Get-AzureADDomainNameReference -Name $domainName | Where-Object ObjectType -EQ 'Group' | ForEach-Object {
    Remove-AzureADGroup -ObjectId $_.ObjectId
}

# Azure AD - custom domain - delete
Remove-AzureADDomain -Name $domainName