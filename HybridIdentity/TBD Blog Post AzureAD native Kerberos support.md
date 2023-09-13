# Try out native Kerberos support for Azure AD

1. Synchronize your on-premises AD to Azure AD
2. Join an existing VM to Azure AD, log on with a synchronized user
3. Create an Azure file share, configure native Kerberos support
4. Test it by mounting the file share via Kerberos

## 1. Synchronize your on-premises AD to Azure AD

## 2. Create Azure VM, join VM to Azure AD, log on with a synchronized user

```powershell
```





1. Install VM extension AADLoginForWindows
2. Assign role "Virtual Machine Administrator Login" to Azure AD user
3. Disable NLA in VM
4. Update RDP file

User has to be an hybrid user, ie  synced by Azure AD Connect.

```powershell
$vmName = 'vm-prod-client002'
$rgName = 'rg-compute'

az vm show -g $rgName -n $vmName 

az vm extension set `
    --publisher Microsoft.Azure.ActiveDirectory `
    --name AADLoginForWindows `
    --resource-group $rgName `
    --vm-name $vmName

$username='azureuser@<domain>'

az role assignment create \
    --role "Virtual Machine Administrator Login" \
    --assignee $username \
    --scope $rgName
```

```rdp
full address:s:20.107.70.230:3389
prompt for credentials:i:1
administrative session:i:1
# add
enablecredsspsupport:i:0
authentication level:i:2
username:s:Ludwig@M365x88845287.onmicrosoft.com
```

Put `AzureAD\` in front of the username.
