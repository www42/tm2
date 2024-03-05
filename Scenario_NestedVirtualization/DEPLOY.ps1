# --- Scenario Nested Virtualization -------------------------------------------------
#
# This deploys a Hyper-V host for nested virtualization scenario


# --- Login --------------------------------------------------------------------------
Login-AzAccount
Get-AzContext | Format-List Name,Account,Tenant,Subscription


# --- Set passwords ------------------------------------------------------------------
$localAdminPassword = Read-Host -Prompt 'LocalAdmin password' -AsSecureString | ConvertFrom-SecureString
@{'localAdminPassword' = $localAdminPassword} | ConvertTo-Json | Out-File "./Scenario_NestedVirtualization/PASSWORDS"



# --- Parameters ---------------------------------------------------------------------
$rgName             = 'rg-nestedvirtualization'
$location           = 'westeurope'
$virtualNetworkName = 'vnet-nestedvirtualization'
$_artifactsLocation = 'https://heidelberg.fra1.digitaloceanspaces.com/NestedVirtualization/'
$localAdminPassword = Get-Content "./Scenario_NestedVirtualization/PASSWORDS" | ConvertFrom-Json | % { $_.localAdminPassword } | ConvertTo-SecureString
$templateFile       = 'Scenario_NestedVirtualization/templates/main.bicep'

$templateParams = @{
    resourceGroupName  = $rgName
    location           = $location
    virtualNetworkName = $virtualNetworkName 
    _artifactsLocation = $_artifactsLocation
    HostAdminUsername  = 'LocalAdmin'
    HostAdminPassword  = $localAdminPassword
}


# --- Resource group -----------------------------------------------------------------
New-AzResourceGroup -Name $rgName -Location $location

Get-AzResourceGroup | Sort-Object ResourceGroupName | ft ResourceGroupName,Location,ProvisioningState
Get-AzResource -ResourceGroupName $rgName | Sort-Object ResourceType | Format-Table Name,ResourceType,Location

# New-AzResourceGroupDeployment -Name 'TabulaRasa' -ResourceGroupName $rgName -Mode Complete -Force -TemplateUri 'https://raw.githubusercontent.com/www42/arm/master/templates/empty.json' -AsJob
# Remove-AzResourceGroup -Name $rgName -Force -AsJob


# --- Template Deployment: Nested Virtualization -------------------------------------
$templateParams
dir $templateFile
New-AzResourceGroupDeployment -Name 'Scenario-NestedVirtualization' -TemplateFile $templateFile -ResourceGroupName $rgName -Location $location @templateParams 

Get-AzResourceGroupDeployment -ResourceGroupName $rgName | Sort-Object Timestamp -Descending | ft DeploymentName,ProvisioningState,Timestamp

# Problem with artifacts location
# _artifactsLocation = 'https://github.com/www42/TrainyMotion/tree/master/NestedVirtualization'   # Error downloading https://github.com/www42/TrainyMotion/tree/master/dsc/dscinstallwindowsfeatures.zip after 17 attempts
# _artifactsLocation = 'https://github.com/www42/TrainyMotion/tree/master/NestedVirtualization/'  # Error: The DSC Extension failed to execute: Error unpacking 'dscinstallwindowsfeatures.zip'; verify this is a valid ZIP package.
#
# Try    https://raw.githubusercontent.com/www42/TrainyMotion/tree/master/NestedVirtualization/
