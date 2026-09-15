$params = @{
    location = 'westeurope'
}

$deploymentName = ''
$resourceGroupName = ''
$templateFile = ''

New-AzResourceGroupDeployment -Name $deploymentName -ResourceGroupName $resourceGroupName -TemplateFile $templateFile @params

Get-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName |
    Sort-Object Timestamp -Descending |
    Format-Table DeploymentName,ProvisioningState,Timestamp
