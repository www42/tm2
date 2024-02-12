# Create a private DNS Zone in Azure
$rgName = 'rg-hub'
$location = 'westeurope'
New-AzPrivateDnsZone -Name 'az.training' -ResourceGroupName $rgName -Location $location 
Get-AzPrivateDnsZone