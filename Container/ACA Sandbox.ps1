# Docs
# [Quickstart: Create your first Azure Container Apps sandbox using the aca CLI | Microsoft Learn](https://learn.microsoft.com/en-us/azure/container-apps/sandboxes-quickstart-cli?tabs=powershell)

# Install CLI
irm https://aka.ms/aca-cli-install-ps | iex
aca --help

# Login
az account show
aca auth status --verbose

# Create resource group
$subscriptionId = az account show --query id -o tsv
$location = 'westeurope'
$resourceGroupName = 'rg-acatest'
az group create --name $resourceGroupName --location $location

# Create sandbox
aca sandbox create --help

# Cleanup
az group delete --name $resourceGroupName --yes