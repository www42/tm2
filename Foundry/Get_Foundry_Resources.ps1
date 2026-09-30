# Project Oxford
# ===============

# Cognitive Services Account
# --------------------------
# Eine 'Foundry Resource' ist in ARM (Azure Resource Manager) ein 'Microsoft.CognitiveServices/accounts/' vom Type 'AIServices'
Get-AzCognitiveServicesAccountType | Measure-Object | % Count   # Es gibt 22 verschiedene Account-Typen
Get-AzCognitiveServicesAccountType
# "Microsoft.CognitiveServices/accounts/"         Type AIServices wird angezeigt als "Foundry"
# "Microsoft.CognitiveServices/accounts/projects"                 wird angezeigt als "Foundry Project"

Get-AzCognitiveServicesAccount | Sort-Object AccountType | Format-Table AccountName,AccountType,ResourceGroupName,Location

$accountName = 'project-103-resource'
$resourceGroupName = 'rg-foundry'
$location = 'swedencentral'

Get-AzCognitiveServicesAccount -Name $accountName -ResourceGroupName $resourceGroupName 
Get-AzCognitiveServicesAccount -Name $accountName -ResourceGroupName $resourceGroupName | % Endpoint
Get-AzCognitiveServicesAccount -Name $accountName -ResourceGroupName $resourceGroupName | % Properties
Get-AzCognitiveServicesAccount -Name $accountName -ResourceGroupName $resourceGroupName | % Properties | % Endpoints

Get-AzCognitiveServicesAccountKey -Name $accountName -ResourceGroupName $resourceGroupName 
Get-AzCognitiveServicesAccountKey -Name $accountName -ResourceGroupName $resourceGroupName | % Key1

# Create Account
# ----------------
#
# Foundry Resource (Parent)
#       - Project 1 (Child)
#       - Project 2 (Child)
#
# Foundry Resource ist 'Microsoft.CognitiveServices/accounts/  Type ('Kind' in Template): AIServices

# Deployment Foundry Resource and Project 1
$params = @{
    location = $location
    foundryAccountName = 'chatbots-resource2'
    projectName = 'chatbot-project-3517'
}
New-AzResourceGroupDeployment `
    -Name 'New-Foundry-Project' `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile '.\templates\foundryResourceAndProject.bicep' `
    @params

    
# Deployment additional project
$params = @{
    location = $location
    foundryAccountName = 'chatbots-resource2'
    projectName = 'chatbot-project-3518'
}
New-AzResourceGroupDeployment `
    -Name 'New-Foundry-Project' `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile '.\templates\foundryProjectInExistingResource.bicep' `
    @params    


# Remove Account
# ----------------
$accountName = 'chatbot-3512-project-resource'
Remove-AzCognitiveServicesAccount -Name $accountName -ResourceGroupName $resourceGroupName 
# --> soft deleted (48 h)

# List Soft deleted Accounts
Get-AzCognitiveServicesAccount -InRemovedState | Format-Table AccountName,AccountType,ResourceType
# Purge in Azure Portal 
#       --> https://portal.azure.com/#view/Microsoft_Azure_ProjectOxford/CognitiveServicesHub/~/AIServices
# Purge mit PowerShell
Remove-AzCognitiveServicesAccount -InRemovedState -Name $accountName -ResourceGroupName $resourceGroupName -Location $location
