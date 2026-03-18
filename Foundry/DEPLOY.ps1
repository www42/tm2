# Project Oxford
# ===============

# Account
# ----------
Get-AzCognitiveServicesAccountType | Measure-Object | % Count   # Es gibt 22 verschiedene Account-Typen
Get-AzCognitiveServicesAccountType
# "Microsoft.CognitiveServices/accounts/"         Type AIServices wird angezeigt als "Foundry"
# "Microsoft.CognitiveServices/accounts/projects"                 wird angezeigt als "Foundry project"

Get-AzCognitiveServicesAccount | Sort-Object AccountType | Format-Table AccountName,AccountType,ResourceGroupName,Location

$accountName = 'chatbot-3512-project-resource'
$rgName = 'rg-foundry'
$location = 'swedencentral'

Get-AzCognitiveServicesAccount -Name $accountName -ResourceGroupName $rgName 
Get-AzCognitiveServicesAccount -Name $accountName -ResourceGroupName $rgName | % Endpoint
Get-AzCognitiveServicesAccount -Name $accountName -ResourceGroupName $rgName | % Properties

Get-AzCognitiveServicesAccountKey -Name $accountName -ResourceGroupName $rgName 
Get-AzCognitiveServicesAccountKey -Name $accountName -ResourceGroupName $rgName | % Key1

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
    -ResourceGroupName $rgName `
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
    -ResourceGroupName $rgName `
    -TemplateFile '.\templates\foundryProjectInExistingResource.bicep' `
    @params    


# Remove Account
# ----------------
$accountName = 'chatbot-3512-project-resource'
Remove-AzCognitiveServicesAccount -Name $accountName -ResourceGroupName $rgName 
# --> soft deleted (48 h)

# List Soft deleted Accounts
Get-AzCognitiveServicesAccount -InRemovedState | Format-Table AccountName,AccountType,ResourceType
# Purge in Azure Portal 
#       --> https://portal.azure.com/#view/Microsoft_Azure_ProjectOxford/CognitiveServicesHub/~/AIServices
# Purge mit PowerShell
Remove-AzCognitiveServicesAccount -InRemovedState -Name $accountName -ResourceGroupName $rgName -Location $location
