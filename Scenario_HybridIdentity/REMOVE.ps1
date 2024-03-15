# --- Login --------------------------------------------------------------------------
Login-AzAccount
Get-AzContext | Format-List Name,Account,Tenant,Subscription


# --- Remove Client VMs Client001 etc. -----------------------------------------------

function Remove-ClientComputer {
    param(
        [string]$clientComputerName,
        [string]$rgName = 'rg-hybrididentity'
    )
    $client = Get-AzVM -ResourceGroupName $rgName -Name $clientComputerName
    if ($client) {
        Remove-AzVM                   -Name           $clientComputerName  -ResourceGroupName $rgName -Force
        Remove-AzNetworkInterface     -Name      "nic-$clientComputerName" -ResourceGroupName $rgName -Force
        Remove-AzDisk                 -DiskName "disk-$clientComputerName" -ResourceGroupName $rgName -Force
        Remove-AzNetworkSecurityGroup -Name      "nsg-$clientComputerName" -ResourceGroupName $rgName -Force
        Remove-AzPublicIpAddress      -Name      "pip-$clientComputerName" -ResourceGroupName $rgName -Force
    }
}

Remove-ClientComputer 'vm-hybrididentity-client001'
