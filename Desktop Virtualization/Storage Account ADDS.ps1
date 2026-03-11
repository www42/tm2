# Enable Active Directory Domain Services (ADDS) authentication for Azure file shares
# ===================================================================================
#
# https://learn.microsoft.com/en-us/azure/storage/files/storage-files-identity-ad-ds-enable?tabs=azure-portal
#
# Das entspricht AZ-140 Lab 22
# https://microsoftlearning.github.io/AZ-140-Configuring-and-Operating-Microsoft-Azure-Virtual-Desktop/Instructions/Labs_Legacy/LAB_02L02_Implement_and_manage_storage_for_AVD_ADDS.html
#
#
# ------------------------------------------------------------------------------------------------
# Wichtig: Muss auf einem Domain Joined Computer ausgeführt werden. Gerne auf Domain Controller.
# Funktioniert mit Windows PowerShell 5.
# ------------------------------------------------------------------------------------------------

# Variables
$location = 'westeurope'
$rgName = 'rg-avd'
$storageAccountName = 'adds69118'
$fileShareName = 'profiles'

# Module Az.* aktualisieren
Get-Module -ListAvailable -Name Az.Accounts | Update-Module -Force
Get-Module -ListAvailable -Name Az.Resources | Update-Module -Force
Update-AzConfig -EnableLoginByWam $false

# Anmelden an Azure
Connect-AzAccount

# Task 1: Create an Azure Storage account
New-AzStorageAccount `
    -Name $storageAccountName `
    -Location $location `
    -ResourceGroupName $rgName `
    -SkuName Standard_LRS `
    -Kind StorageV2 `
    -AccessTier Hot

# Task 2: Create an Azure Files share
$context = (Get-AzStorageAccount -ResourceGroupName $rgName -Name $storageAccountName).Context
New-AzStorageShare -Name $fileShareName -Context $context


# Task 3: Enable AD DS authentication for the Azure Storage account
$subscriptionId = (Get-AzContext).Subscription.Id

# PowerShell Module downloaden und laden
Invoke-WebRequest `
-Uri 'https://github.com/Azure-Samples/azure-files-samples/releases/download/v0.3.2/AzFilesHybrid.zip' `
-OutFile "$env:TEMP\AzFilesHybrid.zip"

Expand-Archive `
-Path "$env:TEMP\AzFilesHybrid.zip" `
-DestinationPath "$env:TEMP\AzFilesHybrid" `
-Force

Push-Location "$env:TEMP\AzFilesHybrid"
.\CopyToPSPath.ps1   # kopiert ins PS-Modulverzeichnis
Import-Module AzFilesHybrid
Pop-Location

# Computer Account anlegen für Storage Account
Join-AzStorageAccountForAuth `
    -ResourceGroupName $rgName `
    -StorageAccountName $StorageAccountName `
    -DomainAccountType 'ComputerAccount' `
    -OrganizationalUnitDistinguishedName 'OU=AVDInfra,DC=az,DC=training'

# Test
$storageaccount = Get-AzStorageAccount -ResourceGroupName $rgName -Name $storageAccountName
$storageAccount.AzureFilesIdentityBasedAuth.ActiveDirectoryProperties
$storageAccount.AzureFilesIdentityBasedAuth.DirectoryServiceOptions


# Task 4: Configure the Azure Files RBAC-based permissions
#         AVDUsers --> Storage File Data SMB Share Contributor --> Profiles
#         AVDAdmins --> Storage File Data SMB Share Elevated Contributor --> Profiles


# Task 5: Configure the Azure Files file system permissions
$storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $rgName -Name $storageAccountName).Value[0]
net use Z: "\\$storageAccountName.file.core.windows.net\$fileShareName" /u:AZURE\$storageAccountName $storageAccountKey
icacls Z:

icacls Z: /inheritance:r

icacls Z: /grant:r "Creator Owner:(OI)(CI)(IO)(M)"
# $permissions = 'Creator Owner'+':(OI)(CI)(IO)(M)'
# cmd /c icacls Z: /grant $permissions

icacls Z: /grant:r "AZ\AVDUsers:(M)"
# $permissions = 'AZ\AVDUsers'+':(M)'
# cmd /c icacls Z: /grant $permissions

icacls Z: /grant:r "AZ\AVDAdmins:(F)"
# $permissions = 'AZ\AVDAdmins'+':(F)'
# cmd /c icacls Z: /grant $permissions

icacls Z: /remove 'Authenticated Users'
icacls Z: /remove 'Builtin\Users'

net use z: /delete
