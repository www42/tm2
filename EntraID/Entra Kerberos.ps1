# Entra Kerberos
# ====================================

# https://learn.microsoft.com/en-us/azure/storage/files/storage-files-identity-auth-hybrid-identities-enable


# --- Enable Microsoft Entra Kerberos authentication ---------------------------------

# auf Domain Controller
#  $domainInformation = Get-ADDomain
#  $domainGuid = $domainInformation.ObjectGUID.ToString()
#  $domainName = $domainInformation.DnsRoot

$domainGuid = '67179b7e-4654-42cd-9683-a8c75629bacc'
$domainName = 'az.training'

$storageAccountName = 'fslogix69118'
$rgName = 'rg-hybrididentity'

Set-AzStorageAccount `
-StorageAccountName $storageAccountName `
-ResourceGroupName $rgName `
-EnableAzureActiveDirectoryKerberosForFile $true `
-ActiveDirectoryDomainName $domainName `
-ActiveDirectoryDomainGuid $domainGuid

Get-AzStorageAccount -StorageAccountName $storageAccountName -ResourceGroupName $rgName | % AzureFilesIdentityBasedAuth | 
ForEach-Object {
    $DirectoryServiceOptions = $_.DirectoryServiceOptions
    $ActiveDirectoryProperties = $_.ActiveDirectoryProperties
    $a = $ActiveDirectoryProperties.AccountType
    $b = $ActiveDirectoryProperties.AzureStorageSid
    $c = $ActiveDirectoryProperties.DomainGuid
    $d = $ActiveDirectoryProperties.DomainName
    $e = $ActiveDirectoryProperties.DomainSid
    $f = $ActiveDirectoryProperties.ForestName
    $g = $ActiveDirectoryProperties.NetBiosDomainName
    $h = $ActiveDirectoryProperties.SamAccountName
    
    $DefaultSharePermission = $_.DefaultSharePermission
    Write-Host "DirectoryServiceOptions: $DirectoryServiceOptions"
    Write-Host "ActiveDirectoryProperties:"
    Write-Host "   AccountType      : $a"
    Write-Host "   AzureStorageSid  : $b"
    Write-Host "   DomainGuid       : $c"
    Write-Host "   DomainName       : $d"
    Write-Host "   DomainSid        : $e"
    Write-Host "   ForestName       : $f"
    Write-Host "   NetBiosDomainName: $g"
    Write-Host "   SamAccountName   : $h"
    Write-Host "DefaultSharePermission: $DefaultSharePermission"
}

# --- Grant admin consent to the new service principal -------------------------------

# Admin consent im Portal (Powershell?)

# Abfragen der genehmigten Permissions (Admin Consent)
$app = Get-MgApplication | Where-Object DisplayName -Like "*$storageAccountName*"
$appId = $app.AppId

$sp = Get-MgServicePrincipalByAppId -AppId $appId
$spId = $sp.Id

$grants = Get-MgServicePrincipalOauth2PermissionGrant -ServicePrincipalId $spId | Where-Object {$_.ConsentType -EQ 'AllPrincipals'}
$grants | fl *
($grants | % Scope).split(' ') | Sort-Object
