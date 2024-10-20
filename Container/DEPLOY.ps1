# --- Login --------------------------------------------------------------------------
Get-AzContext -ListAvailable | Format-List Name,Account,Tenant,Subscription
$tenantId       = '819ebf55-0973-4703-b006-581a48f25961'          # az.training
$subscriptionId = 'fa366244-df54-48f8-83c2-e1739ef3c4f1'          # Visual Studio Enterprise Subscription
#$subscriptionId = '4072ef16-4983-440e-af57-d3afa9a6ea96'          # Pay-As-You-Go Dev/Test
Login-AzAccount -Tenant $tenantId -Subscription $subscriptionId

Get-AzContext | Format-List Name,Account,Tenant,Subscription
Set-AzContext -Subscription $subscriptionId

# --- Set passwords ------------------------------------------------------------------
$acrPassword = Read-Host -Prompt 'ACR password' -AsSecureString | ConvertFrom-SecureString
@{'acrPassword' = $acrPassword} | ConvertTo-Json | Out-File "./Container/PASSWORDS"



# --- Parameters ---------------------------------------------------------------------
$rgName             = 'rg-container'
$location           = 'westeurope'
$containerGroupName = 'supermariogroup'
$containerName      = 'supermario'
$acrName            = 'whalewatch'
$acrUsername        = $acrName
$acrPassword        = Get-Content "./Container/PASSWORDS" | ConvertFrom-Json | % { $_.acrPassword } | ConvertTo-SecureString
$imageName          = 'supermario:v1'
$containerPort      = '8080'
$containerGroupPort = $containerPort
$dnsNameLabel       = 'supermario'


# Unklar was dieser Test bedeutet
Test-AzDnsAvailability -DomainNameLabel $dnsNameLabel -Location $location

$templateParams = @{
    location           = $location
    containerGroupName = $containerGroupName
    containerName      = $containerName
    acrName            = $acrName
    acrUsername        = $acrUsername
    acrPassword        = $acrPassword
    imageName          = $imageName
    containerPort      = $containerPort
    containerGroupPort = $containerGroupPort
    dnsNameLabel       = $dnsNameLabel
}
$templateFile    = './templates/containerGroup.bicep'


# --- Resource group -----------------------------------------------------------------
New-AzResourceGroup -Name $rgName -Location $location -Force

Get-AzResourceGroup | Sort-Object ResourceGroupName | ft ResourceGroupName,Location,ProvisioningState
Get-AzResource -ResourceGroupName $rgName | Sort-Object ResourceType | Format-Table Name,ResourceType,Location

# New-AzResourceGroupDeployment -Name 'TabulaRasa' -ResourceGroupName $rgName -Mode Complete -Force -TemplateUri 'https://raw.githubusercontent.com/www42/arm/master/templates/empty.json' -AsJob
# Remove-AzResourceGroup -Name $rgName -Force -AsJob


# --- Template Deployment: ContainerGroup --------------------------------------------
$templateParams
dir $templateFile
New-AzResourceGroupDeployment -Name 'ContainerGroup' -TemplateFile $templateFile -ResourceGroupName $rgName -Location $location @templateParams 

Get-AzResourceGroupDeployment -ResourceGroupName $rgName | Sort-Object Timestamp -Descending | ft DeploymentName,ProvisioningState,Timestamp



# --- ContainerGroup -----------------------------------------------------------------
Get-AzContainerGroup -ResourceGroupName $rgName | Sort-Object Name | Format-Table Name,Location,ResourceGroupName,RestartPolicy,OsType
$containerGroup = Get-AzContainerGroup -Name $containerGroupName -ResourceGroupName $rgName 
$containerGroup | Remove-AzContainerGroup | Out-Null