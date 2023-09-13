# ------------------------------------------------------------------------------------
# Scenario Hybrid Identity
# ------------------------------------------------------------------------------------
# This script adds an computer account to onprem AD. 
# Computer account represents a file server. 
# In Azure file server is a simple storage account.
#
# Run this script at domain controller (Azure Portal --> Run command)
# ------------------------------------------------------------------------------------

Install-Module -Name Az -Force

# PowerShell module 'AzFilesHybrid'
Start-Process https://github.com/Azure-Samples/azure-files-samples/releases
# download and extract to $folder 
$folder = 'C:\temp\AzFilesHybrid'
dir $folder -File | Unblock-File
cd $folder
Import-Module -Name ./AzFilesHybrid.psd1

Connect-AzAccount
$subscriptionId = (Get-AzContext).Subscription.Id

Get-AzStorageAccount | ft StorageAccountName,ResourceGroupName,Location
$storageAccountName = 'fs69118'
$resourceGroupName = 'Storage-RG'
$ou = 'OU=Classical Physics,DC=az,DC=training'

Join-AzStorageAccountForAuth `
   -ResourceGroupName $resourceGroupName `
   -StorageAccountName $storageAccountName `
   -OrganizationalUnitDistinguishedName $ou `
   -DomainAccountType 'ComputerAccount'

# List computer accounts
Import-Module -Name activedirectory
Get-ADComputer