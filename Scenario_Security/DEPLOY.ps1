# --- Scenario Security --------------------------------------------------------------
# 
# This scenario deploys
#  - a storage account with system-assigned managed identity and with Microsoft-managed keys (default)
#  - a key vault with an access policy "Paul Drude darf alles"
#  - a RSA key named 'app-key' in the key vault
#
# Dieses Scenario ist geeignet für Demo von Applied Skills AZ-1003 (Storage for app1)
#  - Beim Storage Account ändern von Microsoft-managed Keys auf Customer-managed Keys.
#  - Dabei den Key Vault angeben und den Key 'app-key'.
#  - Dadurch entsteht eine weitere Access Policy, und es wird Purge Protection aktiviert.



# --- Login --------------------------------------------------------------------------
Login-AzAccount
Get-AzContext | Format-List Name,Account,Tenant,Subscription



# --- Parameters ---------------------------------------------------------------------
$rgName         = 'rg-security'
$location       = 'westeurope'
$keyVaultName   = "kv-$(Get-Random)"
$storageAccountNamePrefix = 'security'
$templateFile   = 'Scenario_Security/main.bicep'

$templateParams = @{
    location     = $location
    keyVaultName = $keyVaultName
    storageAccountNamePrefix = $storageAccountNamePrefix
}


# --- Resource group -----------------------------------------------------------------
New-AzResourceGroup -Name $rgName -Location $location -Force

Get-AzResourceGroup | Sort-Object ResourceGroupName | ft ResourceGroupName,Location,ProvisioningState
Get-AzResource -ResourceGroupName $rgName | Sort-Object ResourceType | Format-Table Name,ResourceType,Location
# Remove-AzResourceGroup -Name $rgName -Force -AsJob


# --- Template Deployment: Key vault, storage account --------------------------------
dir $templateFile
$templateParams
New-AzResourceGroupDeployment -Name 'Scenario-Security' -TemplateFile $templateFile -ResourceGroupName $rgName -Location $location @templateParams 

Get-AzResourceGroupDeployment -ResourceGroupName $rgName | Sort-Object Timestamp -Descending | ft DeploymentName,ProvisioningState,Timestamp
# New-AzResourceGroupDeployment -Name 'TabulaRasa' -ResourceGroupName $rgName -Mode Complete -Force -TemplateUri 'https://raw.githubusercontent.com/www42/arm/master/templates/empty.json' -AsJob


# --- Storage account system managed identity ----------------------------------------
Get-AzStorageAccount -ResourceGroupName $rgName | Select-Object StorageAccountName,Identity 
Get-AzStorageAccount -ResourceGroupName $rgName -Name 'securityxyuhd35ptmsei' | % Identity | fl *


# --- Key Vaults not deleted ---------------------------------------------------------------------
Get-AzKeyVault | Format-Table VaultName,Location,ResourceGroupName   # Unklar, wie man mit cmdlet Purge Protection ausliest --> Azure CLI
az keyvault show --name 'kv-1242598629' --query "{name:name,softDeleteRetentionInDays:properties.softDeleteRetentionInDays,enablePurgeProtection:properties.enablePurgeProtection}"

# Remove key vault
Remove-AzKeyVault -VaultName 'kv-1038687057'  -Location 'West Europe' -Force


# --- Key Vaults soft deleted ------------------------------------------------
az keyvault list-deleted --query "[].{name:name,deletionDate:properties.deletionDate,scheduledPurgeDate:properties.scheduledPurgeDate,purgeProtectionEnabled:properties.purgeProtectionEnabled}" --output table

# Purge soft deleted key vault
Remove-AzKeyVault -VaultName 'kv69118' -InRemovedState -Location 'westeurope' -Force