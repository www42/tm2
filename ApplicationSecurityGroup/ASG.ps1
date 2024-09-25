# Application Security Group ASG

$rgName = 'rg-security'
$location = 'westeurope'
$asgName = 'Web-Server'
Get-AzApplicationSecurityGroup | ft Name,ResourceGroupName,Location
New-AzApplicationSecurityGroup  -Name $asgName -ResourceGroupName $rgName -Location $location

# ASG auslesen (Welche VMs haben diese ASG?) --> NetworkInterface

Get-AzNetworkInterface -Name nic-vm-hybrididentity-dc1 | fl *
Get-AzNetworkInterface -Name nic-vm-hybrididentity-dc1 | % IpConfigurations
Get-AzNetworkInterface -Name nic-vm-hybrididentity-dc1 | % IpConfigurations | fl *


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