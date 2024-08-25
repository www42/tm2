# Backup Item löschen in einem Recovery Service Vault
# ----------------------------------------------------

# Recovery Service Vault
$vaults = Get-AzRecoveryServicesVault
$vaults | Format-Table -Property Name, ResourceGroupName, Location
$vaultName = 'rsv-backup-westeurope'
$resourceGroupName = 'rg-hybrididentity'
$vault = Get-AzRecoveryServicesVault -ResourceGroupName $resourceGroupName -Name $vaultName

# Backup Container
$containers = Get-AzRecoveryServicesBackupContainer -VaultId $vault.ID -ContainerType "AzureVM"
$containers | Format-Table FriendlyName, ContainerType, BackupManagementType, Status
$containerFriendlyName = 'vm-hybrididentity-dc1'
$container = Get-AzRecoveryServicesBackupContainer -FriendlyName $containerFriendlyName -ContainerType "AzureVM" -VaultId $vault.ID 

# Backup Item
$backupItem = Get-AzRecoveryServicesBackupItem -VaultId $vault.ID -Container $container -WorkloadType AzureVM
$backupItem | Format-List Name, ProtectionState, ProtectionStatus, LastBackupStatus, LastBackupTime

# Remove Backup Item forever (it takes some time)
Disable-AzRecoveryServicesBackupProtection -Item $backupItem -RemoveRecoveryPoints -VaultId $vault.ID -Force
