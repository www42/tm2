$templateFile = 'Twingate\twingate-connector-aci.bicep'
$deploymentName = 'Twingate-Connector-Aci-Deployment-3'
$resourceGroupName = 'rg-prod'

$params = @{
    containerName = 'twingate-connector-azure'
    location = 'westeurope'
    vnetName = 'vnet-prod'
    subnetName = 'Containers'
    connectorImage = 'timmy-eff6h7g6ckc2aze0.azurecr.io/connector:1'
    arcLoginServer = 'timmy-eff6h7g6ckc2aze0.azurecr.io'
    acrUsername = 'timmy'
    acrPassword = ConvertTo-SecureString '' -AsPlainText -Force
    twingateNetwork = 'yellowlion9566'
    twingateAccessToken = ConvertTo-SecureString '' -AsPlainText -Force
    twingateRefreshToken = ConvertTo-SecureString '' -AsPlainText -Force
}

New-AzResourceGroupDeployment -Name $deploymentName -ResourceGroupName $resourceGroupName -TemplateFile $templateFile @params

Get-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName |
    Sort-Object Timestamp -Descending |
    Format-Table DeploymentName,ProvisioningState,Timestamp
