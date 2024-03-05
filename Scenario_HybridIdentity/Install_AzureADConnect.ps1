# ------------------------------------------------------------------------------------
# Scenario Hybrid Identity
# ------------------------------------------------------------------------------------
# This script installs Azure AD Connect and manages sync
# Run this script on the domain controller VM.
# ------------------------------------------------------------------------------------

# Install Azure AD Connect
Invoke-WebRequest -UseBasicParsing `
                  -Uri https://download.microsoft.com/download/B/0/0/B00291D0-5A83-4DE7-86F5-980BC00DE05A/AzureADConnect.msi `
                  -OutFile $HOME\Desktop\AzureADConnect.msi

# Run Azure AD Connect setup manually
Start-Process $HOME\Desktop\AzureADConnect.msi

# AzureAD Connect installs module ADSync (and MSOnline as well)
Import-Module -Name "C:\Program Files\Microsoft Azure AD Sync\Bin\ADSync\ADSync.psd1"
Get-Module -Name ADSync

Get-ADSyncAADCompanyFeature
Get-ADSyncConnector | ft Name,Type
Get-ADSyncScheduler

Start-ADSyncSyncCycle -PolicyType Delta

# Troubleshooting
Get-Service -Name "ADSync"
