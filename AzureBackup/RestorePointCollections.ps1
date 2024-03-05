
# Backup Azure VM --> RecoveryServiceVault
# ----------------------------------------

# Eine *RestorePointCollection* ist eine Collection von RestorePonts🤓, Abkürzung: RPC
Get-AzRestorePointCollection -Name AzureBackup_vm-hybrididentity-dc1_1847425825568022036 -ResourceGroupName AzureBackupRG_westeurope_1 | fl *

# Die VM, deren RestorePoints in der RPC gesammelt sind, steht mit ihrer Resource ID in der Property *Source* 
Get-AzRestorePointCollection -Name AzureBackup_vm-hybrididentity-dc1_1847425825568022036 -ResourceGroupName AzureBackupRG_westeurope_1 | % Source

# ... und ein oder mehrere *RestorePoints*
Get-AzRestorePointCollection `
    -Name AzureBackup_vm-hybrididentity-dc1_1847425825568022036 `
    -ResourceGroupName AzureBackupRG_westeurope_1 `
    | % RestorePoints

# Ein RestorePoint hat *SourceMetadata* mir diversen Angaben, was gespeichert wurde
Get-AzRestorePoint `
    -Name AzureBackup_20240229_041712 `
    -RestorePointCollectionName AzureBackup_vm-hybrididentity-dc1_1847425825568022036 `
    -ResourceGroupName AzureBackupRG_westeurope_1 `
    | % SourceMetadata | % StorageProfile | % OsDisk

Get-AzVM -Name vm-hybrididentity-dc1 -ResourceGroupName rg-hybrididentity | % VmId

Get-AzRecoveryServicesVault
Get-AzRecoveryServicesVault -Name Backup-Westeurope | % Properties
Get-AzRecoveryServicesVault -Name Backup-Westeurope | % Properties | % RestoreSettings 
Get-AzRecoveryServicesVault -Name Backup-Westeurope | % Properties | % RestoreSettings | % CrossSubscriptionRestoreSettings

# https://learn.microsoft.com/en-us/azure/backup/quick-backup-vm-bicep-template
# https://learn.microsoft.com/en-us/azure/virtual-machines/virtual-machines-create-restore-points-powershell