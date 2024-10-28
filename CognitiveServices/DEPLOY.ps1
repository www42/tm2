# --- Login --------------------------------------------------------------------------
Login-AzAccount
Get-AzContext | Format-List Name,Account,Tenant,Subscription
Get-AzContext -ListAvailable | Format-List Name,Account,Tenant,Subscription
Set-AzContext -Subscription 'fa366244-df54-48f8-83c2-e1739ef3c4f1'


# --- Parameters ---------------------------------------------------------------------
$accountName = 'contentsafety69118'
$rgName = 'rg-cognitiveservices'
$location = 'westeurope'

$accountName = 'openAI-69118'
$rgName = 'rg-openai'
$location = 'westeurope'


# --- Resource group -----------------------------------------------------------------
New-AzResourceGroup -Name $rgName -Location $location -Force
Get-AzResource -ResourceGroupName $rgName | Sort-Object ResourceType | Format-Table Name,ResourceType,Location


# --- Cognitive Services Account -----------------------------------------------------
Get-AzCognitiveServicesAccountType | Measure-Object | % Count   # Es gibt 23 verschiedene Account-Typen
Get-AzCognitiveServicesAccountType 

Get-AzCognitiveServicesAccount | Measure-Object | % count
Get-AzCognitiveServicesAccount | Sort-Object AccountName | Format-Table AccountName,ResourceGroupName,Location,AccountType,ProvisioningState

Get-AzCognitiveServicesAccount -Name $accountName -ResourceGroupName $rgName | % Properties | % Endpoint
Get-AzCognitiveServicesAccountKey -Name $accountName -ResourceGroupName $rgName 
Get-AzCognitiveServicesAccountKey -Name $accountName -ResourceGroupName $rgName | % Key1




# andere Baustelle:
# --- Log Analytics Workspace --------------------------------------------------------
Get-AzOperationalInsightsWorkspace | Measure-Object | % Count
Get-AzOperationalInsightsWorkspace | Sort-Object Name | Format-Table Name,ResourceGroupName,Location

$workspaceName = 'log-monitoring'
$rgName = 'rg-monitoring'
$workspaceId = Get-AzOperationalInsightsWorkspace -Name $workspaceName -ResourceGroupName $rgName | % CustomerId | % Guid
# Welche VMs sind mit dem Workspace verbunden?
#  a) MMA (legacy) 
Get-AzVMExtension -VMName 'vm-hybrididentity-dc1' -ResourceGroupName 'rg-hybrididentity' -Name 'MicrosoftMonitoringAgent' | % PublicSettings | ConvertFrom-Json | % workspaceId
#  b) AMA
Get-AzVMExtension -VMName 'vm-monitoring-svr1'    -ResourceGroupName 'rg-monitoring'     -Name 'AzureMonitorWindowsAgent' | % PublicSettings # null
#     Wozu ist dieses cmdlet gut?
Get-AzOperationalInsightsDataSource -WorkspaceName $workspaceName -ResourceGroupName $rgName -Kind WindowsPerformanceCounter  # no result - but no error

#     Fall b) muss man über die DCR auflösen:
Get-AzDataCollectionRule | Format-Table Name,Kind,ResourceGroupName,Location

$dcrName = 'dcr-windowsperf'
$rgName = 'rg-monitoring'
$dcr = Get-AzDataCollectionRule -Name $dcrName -ResourceGroupName $rgName

$dcr.DataFlow
$dcr.DataFlow.Destination
$dcr.DataSourcePerformanceCounter.CounterSpecifier
$dcr.DestinationLogAnalytic.WorkspaceId
$dcr.Id

$vm = Get-AzVM -Name 'vm-monitoring-svr1'
Get-AzDataCollectionRuleAssociation -ResourceUri $vm.Id 

# Hurra, Fall b) gelöst! Die Ids stimmen überein:
(Get-AzDataCollectionRuleAssociation -ResourceUri $vm.Id).DataCollectionRuleId
(Get-AzDataCollectionRule -Name $dcrName -ResourceGroupName $rgName).Id