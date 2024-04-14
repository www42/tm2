# Application Security Group ASG

$rgName = 'rg-security'
$location = 'westeurope'
$asgName = 'Web-Server'
New-AzApplicationSecurityGroup  -Name $asgName -ResourceGroupName $rgName -Location $location
Get-AzApplicationSecurityGroup | ft Name,ResourceGroupName,Location


Get-AzApplicationSecurityGroup -Name Web-Server -ResourceGroupName rg-monitoring 

# ASG auslesen (Welche VMs haben diese ASG?) --> NetworkInterface

Get-AzNetworkInterface -Name vm-hybididentity-client001-Nic | fl *
Get-AzNetworkInterface -Name vm-hybididentity-client001-Nic | % IpConfigurations
Get-AzNetworkInterface -Name vm-hybididentity-client001-Nic | % IpConfigurations
Get-AzNetworkInterface -Name vm-hybididentity-client001-Nic | % IpConfigurations | fl *


function Get-MyAzNetworkInterface {

    Get-AzNetworkInterface | ForEach-Object {
        $nic = $_.Name
        Write-Host "NIC: $nic"

        $vm  = $_.VirtualMachine | % Id
        if ($vm) {$vmText = $vm.Split('/')[-1]} else {$vmText = 'not connected to any VM'}
        Write-Host "       connected to VM:  $vmText"

        $asg = $_.IpConfigurations | % ApplicationSecurityGroupsText | ConvertFrom-Json | % Id
        if ($asg) {$asgText = $asg.Split('/')[-1]} else {$asgText = 'not connected to any ASG'}
        Write-Host "       connected to ASG: $asgText"

        Write-Host
    }
}
Get-MyAzNetworkInterface


# Remove-AzApplicationSecurityGroup -Name Web-Server -ResourceGroupName rg-monitoring