# ------------------------------------------------------------------------------------
# Hybrid Identity
# ------------------------------------------------------------------------------------
# This script adds a server to the onprem AD domain.
# Run this script on SVR1 (Azure Portal --> Run command)
# ------------------------------------------------------------------------------------

$User = 'trainymotion\DomainAdmin'
$Pw = ''
$SecPw = ConvertTo-SecureString $Pw -AsPlainText -Force

$DomainCred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User,$SecPw

Add-Computer -DomainName 'trainymotion.com' -Credential $DomainCred -Restart -Force -PassThru