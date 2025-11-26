# List all private DNS Zones
Get-AzPrivateDnsZone | Sort-Object Name | ft Name,ResourceGroupName, NumberOfRecordSets, NumberOfVirtualNetworkLinks
Get-AzPrivateDnsZone | Where-Object ResourceGroupName -ne 'rg-aifoundry' | Sort-Object Name | ft Name,ResourceGroupName, NumberOfRecordSets, NumberOfVirtualNetworkLinks

# Create a private DNS Zone
$dnsZoneName = 'az.training'
$resourceGroupName = 'rg-hub'
New-AzPrivateDnsZone -Name $dnsZoneName -ResourceGroupName $resourceGroupName 

$privateDnsZone = Get-AzPrivateDnsZone -Name $dnsZoneName

# Remove a private DNS Zone
Remove-AzPrivateDnsZone -PrivateZone $privateDnsZone
Remove-AzPrivateDnsZone -Name $dnsZoneName -ResourceGroupName $resourceGroupName



# Private DNS Zones for Private EPs
function CreatePrivateDnsZones {
    param (
        $resourceGroupName = 'rg-hub'
    )
    
    $dnsZones = @(
        # Storage Services
        "privatelink.blob.core.windows.net",
        "privatelink.file.core.windows.net",
        #    "privatelink.queue.core.windows.net",
        #    "privatelink.table.core.windows.net",
        #    "privatelink.dfs.core.windows.net",
        
        # Databases
        "privatelink.database.windows.net",
        "privatelink.documents.azure.com",
        #   "privatelink.sql.azuresynapse.net",
        #    "privatelink.mysql.database.azure.com",
        #    "privatelink.postgres.database.azure.com",
        #    "privatelink.mariadb.database.azure.com",
        
        # Container & Web
        "privatelink.azurecr.io",
        "privatelink.azurewebsites.net",
        
        # Key Vault
        "privatelink.vaultcore.azure.net"
        
        # Analytics & AI
        #    "privatelink.datafactory.azure.net",
        #    "privatelink.adf.azure.com",
        #    "privatelink.cognitiveservices.azure.com",
        #    "privatelink.openai.azure.com",
        
        # Messaging & Events
        #    "privatelink.servicebus.windows.net",
        #    "privatelink.azure-devices.net",
        #    "privatelink.eventgrid.azure.net",
        
        # Monitoring
        #    "privatelink.monitor.azure.com",
        #    "privatelink.oms.opinsights.azure.com",
        #    "privatelink.ods.opinsights.azure.com"
)

    $vnetNames = @(
        'vnet-hub',
        'vnet-hybrididentity',
        'vnet-monitoring',
        'vnet-nestedvirtualization'
    )

    foreach ($zone in $dnsZones) {
        Write-Host "Creating DNS zone  $zone" -ForegroundColor Cyan -NoNewline
        try {
            New-AzPrivateDnsZone `
            -Name $zone -ResourceGroupName $resourceGroupName `
            -ErrorAction Stop | Out-Null

            Write-Host " ✅ Created successfully" -ForegroundColor Green
        }
        catch {
            if ($_.Exception.Message -like "*exists already*") {
                Write-Host " ❗ Already exists" -ForegroundColor Yellow
            }
            else {
            Write-Host " ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }

    Write-Host "`nDone! Number of DNS zones processed: $($dnsZones.Count)" -ForegroundColor Green

}

CreatePrivateDnsZones


# Links to  Virtual Networks


foreach ($vnetName in $vnetNames) {
    Write-Host "Linking DNS zone $dnsZoneName to VNet $vnetName" -ForegroundColor Cyan
    
    $vnet = Get-AzVirtualNetwork -Name $vnetName 

    try {
        New-AzPrivateDnsVirtualNetworkLink -ZoneName $dnsZoneName `
            -ResourceGroupName $resourceGroupName `
            -VirtualNetworkId $vnet.Id `
            -Name "link-to-$vnetName" `
            -EnableRegistration $true `
            -ErrorAction Stop | Out-Null

        Write-Host "✓ Linked successfully $dnsZoneName to $vnetName" -ForegroundColor Green
    }
    catch {
        if ($_.Exception.Message -like "*already exists*") {
            Write-Host "❌ Link already exists between $dnsZoneName and $vnetName" -ForegroundColor Yellow
        }
        else {
            Write-Host "✗ Error linking $dnsZoneName to $vnetName : $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}
$vnet = Get-AzVirtualNetwork -Name $vnetName 

New-AzPrivateDnsVirtualNetworkLink -ZoneName $dnsZoneName `
    -ResourceGroupName $resourceGroupName `
    -VirtualNetworkId $vnet.Id `
    -Name "link-to-$vnetName" `
    -EnableRegistration $true