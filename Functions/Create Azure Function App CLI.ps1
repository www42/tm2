# Azure Function App
# -------------------

$location = 'westeurope'
$rgName = 'rg-functions'
#$random = Get-Random -Minimum 1000 -Maximum 9999
$random = '5045'
$storage = "stnfuncn8n$random"
$funcApp = "func-n8n-$random"

# ---- Resource Group ----
az group create `
  --name "$rgName" `
  --location "$location"

# ---- Storage Account (von der Function App zwingend benötigt) ----
az storage account create `
  --name "$storage" `
  --resource-group "$rgName" `
  --location "$location" `
  --sku Standard_LRS `
  --allow-blob-public-access false

# ---- Function App (Flex Consumption, Linux, PowerShell 7.4, Managed Identity) ----
az functionapp create `
  --name "$funcApp" `
  --resource-group "$rgName" `
  --storage-account "$storage" `
  --flexconsumption-location "$location" `
  --runtime powershell `
  --runtime-version 7.4 `
  --functions-version 4 `
  --assign-identity '[system]'

# ---- Assign Rbac role to Managed Identity at subscription level ----
$servicePrincipalId = $(az functionapp identity show `
  --name "$funcApp" `
  --resource-group "$rgName" `
  --query principalId `
  --output tsv)
$roleName = 'Contributor'
$subscriptionId = 'fa366244-df54-48f8-83c2-e1739ef3c4f1'

az role assignment create `
  --assignee-object-id "$servicePrincipalId" `
  --assignee-principal-type ServicePrincipal `
  --role "$roleName" `
  --scope "/subscriptions/$subscriptionId"

# ---- Create a folder for function deployment within VS Code ----
New-Item -ItemType Directory -Path ".\Azure Functions\$funcApp" -Force 