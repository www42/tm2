# --- Scenario Security --------------------------------------------------------------
# 
# This scenario deploys
#  - a storage account with system-assigned managed identity



# --- Applied Skills AZ-1003 issue (Storage for app1) --------------------------------
# https://trainingsupport.microsoft.com/en-us/mcp/forum/all/applied-skills-lab-error/530da8ad-66d3-4da0-934e-dd635c357241



# --- Login --------------------------------------------------------------------------
Login-AzAccount
Get-AzContext | Format-List Name,Account,Tenant,Subscription



# --- Parameters ---------------------------------------------------------------------
$rgName         = 'rg-security'
$location       = 'westeurope'
$keyVaultName   = 'kv69118'
$storageAccountNamePrefix = 'sec'
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

# New-AzResourceGroupDeployment -Name 'TabulaRasa' -ResourceGroupName $rgName -Mode Complete -Force -TemplateUri 'https://raw.githubusercontent.com/www42/arm/master/templates/empty.json' -AsJob
# Remove-AzResourceGroup -Name $rgName -Force -AsJob


# --- Template Deployment: Key vault, storage account --------------------------------
$templateParams
dir $templateFile
New-AzResourceGroupDeployment -Name 'Scenario-Security' -TemplateFile $templateFile -ResourceGroupName $rgName -Location $location @templateParams 

Get-AzResourceGroupDeployment -ResourceGroupName $rgName | Sort-Object Timestamp -Descending | ft DeploymentName,ProvisioningState,Timestamp


# --- Storage account system managed identity ----------------------------------------
Get-AzStorageAccount -ResourceGroupName $rgName | Select-Object StorageAccountName,Identity 
Get-AzStorageAccount -ResourceGroupName $rgName -Name 'secxyuhd35ptmsei' | % Identity | fl *