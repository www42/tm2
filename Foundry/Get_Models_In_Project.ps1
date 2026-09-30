# Achtung! Irrtum: Models werden in die 'Foundry Resource' deployed, nicht in das 'Foundry Project'.
# Alle 'Foundry Projects' in diese Resource teilen sich die Models.

# Foundry Resource = Cognitive Services Account (Type AIServices)

# Alle Cognitive Services Account auflisten (alle Typen):
Get-AzCognitiveServicesAccount | Select AccountName,AccountType,@{n='Sku';e={$_.Sku.Name}},Location | 
    Sort-Object AccountType, AccountName | Format-Table

$CognitiveServicesAccount = 'project-103-resource'
$CognitiveServicesAccount = 'project-102-resource'
$CognitiveServicesAccount = 'kevin-handschrift-resource'

$resourceGroupName = 'rg-foundry'

# Jetzt die Models auflisten, die in diesen Account ( = 'Foundry Resource') deployes sind:
(Get-AzCognitiveServicesAccountDeployment -ResourceGroupName $resourceGroupName -AccountName $CognitiveServicesAccount) | 
    Select-Object -Property Name, @{n='Sku';e={$_.Sku.Name}} | 
    Sort-Object Name
