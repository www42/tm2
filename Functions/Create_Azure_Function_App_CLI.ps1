# Azure Function App
# -------------------

$location = 'westeurope'
$resourceGroupName = 'rg-functions'
#$random = Get-Random -Minimum 1000 -Maximum 9999
$random = '5045'
$storageAccountName = "stnfuncn8n$random"
$functionAppName = "func-n8n-$random"


# ---- Resource Group ----
az group create `
  --name "$resourceGroupName" `
  --location "$location"

az group show --name $resourceGroupName


# ---- Storage Account (von der Function App zwingend benötigt) ----
az storage account create `
  --name "$storageAccountName" `
  --resource-group "$resourceGroupName" `
  --location "$location" `
  --sku Standard_LRS `
  --allow-blob-public-access false

az storage account show --name $storageAccountName --query "{name:name,hostNames:hostNames[0],kind:kind,sku:sku.name,primaryLocation:primaryLocation,secondaryLocation:secondaryLocation}"


# ---- Function App (Flex Consumption, Linux, PowerShell 7.4, Managed Identity) ----
az functionapp create `
  --name "$functionAppName" `
  --resource-group "$resourceGroupName" `
  --storage-account "$storageAccountName" `
  --flexconsumption-location "$location" `
  --runtime powershell `
  --runtime-version 7.4 `
  --functions-version 4 `
  --assign-identity '[system]'

az functionapp show --name $functionAppName --resource-group $resourceGroupName --query "{name:name,identity:identity.type,kind:kind,defaultHostName:properties.defaultHostName,runtime:properties.functionAppConfig.runtime.name,state:properties.state}"


# ---- At subscription level assign Rbac role 'Contributor' to functions app's Managed Identity ----
$servicePrincipalId = $(az functionapp identity show `
  --name "$functionAppName" `
  --resource-group "$resourceGroupName" `
  --query principalId `
  --output tsv)
$roleName = 'Contributor'
$subscriptionId = 'fa366244-df54-48f8-83c2-e1739ef3c4f1'

az role assignment create `
  --assignee-object-id "$servicePrincipalId" `
  --assignee-principal-type ServicePrincipal `
  --role "$roleName" `
  --scope "/subscriptions/$subscriptionId"

az role assignment list --assignee $servicePrincipalId --query "{scope:[0].scope,roleDefinitionName:[0].roleDefinitionName,principalId:[0].principalId}"

# ---- Create a folder for function deployment within VS Code ----
New-Item -ItemType Directory -Path ".\Functions\$functionAppName" -Force 

dir ".\Functions\$functionAppName"

