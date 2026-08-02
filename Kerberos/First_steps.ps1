
$subscriptionId = (Get-AzContext).Subscription.Id
$location          = 'westeurope'
$resourceGroupName = 'rg-hybrididentity'
$vmName            = 'vm-hybrididentity-server1'

# VM
Get-AzVM -Name $vmName -Status | Format-List Name,Location,HardwareProfile,PowerState
Start-AzVM -Name $vmName -ResourceGroupName $resourceGroupName

# Install VM extension
Set-AzVMExtension `
	-ResourceGroupName $resourceGroupName `
    -VMName $vmName `
    -Name "AADLoginForWindows" `
    -Publisher "Microsoft.Azure.ActiveDirectory" `
    -ExtensionType "AADLoginForWindows" `
    -TypeHandlerVersion "1.0" `
    -Location $location

Get-AzVMExtension -ResourceGroupName $resourceGroupName -VMName $vmName | Format-Table Name,Publisher,ExtensionType

# Role assignment
$roleName = 'Virtual Machine Administrator Login'
$userDisplayName = 'Wilhelm Leibniz'
$userId = Get-AzADUser -DisplayName $userDisplayName | % Id

New-AzRoleAssignment `
	-ObjectId $userId `
	-RoleDefinitionName $roleName `
	-Scope "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Compute/virtualMachines/$vmName"

# Disable NLA für Remote Desktop Connections
$script = @'
    # 0 - no NLA required
    # 1 - NLA required
    (Get-WmiObject -class "Win32_TSGeneralSetting" -Namespace root\cimv2\terminalservices -Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(0)
'@

Invoke-AzVMRunCommand -ResourceGroupName $resourceGroupName -VMName $vmName -CommandId "RunPowerShellScript" -ScriptString $script

# Enable Kerberos Tocket Retrieval
$script = @'
    New-ItemProperty `
    -Path HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters `
    -Name CloudKerberosTicketRetrievalEnabled `
    -Value 1 `
    -PropertyType DWord `
    -Force
'@
Invoke-AzVMRunCommand -ResourceGroupName $resourceGroupName -VMName $vmName -CommandId "RunPowerShellScript" -ScriptString $script

# Assign public ip
# Allow rdp
# Modify rdp file
# Connect