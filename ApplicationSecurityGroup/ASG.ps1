
$asgName = 'Web-Server'
$rgName = 'rg-networksecurity'
$location = 'westeurope'
New-AzApplicationSecurityGroup  -Name $asgName -ResourceGroupName $rgName -Location $location
Get-AzApplicationSecurityGroup | ft Name,ResourceGroupName,Location


Get-AzApplicationSecurityGroup -Name Web-Server -ResourceGroupName rg-monitoring 

# ASG auslesen (Welche VMs haben diese ASG?)

function Get-MyAzNetworkInterface {

    Get-AzNetworkInterface | ForEach-Object {
        $nic = $_.Name
        Write-Host "NIC: $nic"

        $vm  = $_.VirtualMachine | % Id
        if ($vm) {$vmText = $vm.Split('/')[-1]} else {$vmText = 'Not Connected to any VM'}
        Write-Host "VM:  $vmText"

        $asg = $_.IpConfigurations | % ApplicationSecurityGroupsText | ConvertFrom-Json | % Id
        if ($asg) {$asgText = $asg.Split('/')[-1]} else {$asgText = 'Not Connected to any ASG'}
        Write-Host "ASG: $asgText"

        Write-Host
    }
}
Get-MyAzNetworkInterface


# Remove-AzApplicationSecurityGroup -Name Web-Server -ResourceGroupName rg-monitoring