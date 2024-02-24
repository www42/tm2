# --- Scenario Security --------------------------------------------------------------
# 
# This scenario deploys
#  - a storage account with system-assigned managed identity


# --- Login --------------------------------------------------------------------------
Login-AzAccount
Get-AzContext | Format-List Name,Account,Tenant,Subscription



# --- Parameters ---------------------------------------------------------------------
$rgName         = 'rg-security'
$location       = 'westeurope'
$storageAccountNamePrefix = 'sec'
$templateFile   = 'Security/main.bicep'

$templateParams = @{
    location = $location
    storageAccountNamePrefix = $storageAccountNamePrefix
}




# --- Resource group -----------------------------------------------------------------
New-AzResourceGroup -Name $rgName -Location $location -Force

Get-AzResourceGroup | Sort-Object ResourceGroupName | ft ResourceGroupName,Location,ProvisioningState
Get-AzResource -ResourceGroupName $rgName | Sort-Object ResourceType | Format-Table Name,ResourceType,Location

# New-AzResourceGroupDeployment -Name 'TabulaRasa' -ResourceGroupName $rgName -Mode Complete -Force -TemplateUri 'https://raw.githubusercontent.com/www42/arm/master/templates/empty.json' -AsJob
# Remove-AzResourceGroup -Name $rgName -Force -AsJob



# --- Template Deployment ------------------------------------------------------------

$templateParams
New-AzResourceGroupDeployment -Name 'Scenario-Security' -TemplateFile $templateFile -ResourceGroupName $rgName -Location $location @templateParams 

Get-AzResourceGroupDeployment -ResourceGroupName $rgName | Sort-Object Timestamp -Descending | ft DeploymentName,ProvisioningState,Timestamp


# --- Storage account system managed identity ----------------------------------------
Get-AzStorageAccount -ResourceGroupName $rgName | Select-Object StorageAccountName,Identity 
Get-AzStorageAccount -ResourceGroupName $rgName -Name 'secxyuhd35ptmsei' | % Identity | fl *