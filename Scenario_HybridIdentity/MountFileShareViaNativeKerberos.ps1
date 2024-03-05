# Download RDP file
# Add 3 lines to RDP file:

enablecredsspsupport:i:0
authentication level:i:2
username:s:Ludwig@az.training

# Connect to Client VM via RDP
# Add AzureAD\ in front of username e.g. 
AzureAD\Ludwig@trainymotion.com

# Mount file share as decribed in the portal
Test-NetConnection krbadatum.file.core.windows.net -Port 445
New-PSDrive -Name Z -PSProvider FileSystem -Root "\\krbadatum.file.core.windows.net\docs" -Persist
Get-PSDrive