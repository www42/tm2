# Get Started With the Microsoft MCP Server for Enterprise - Microsoft Graph
# https://learn.microsoft.com/en-us/graph/mcp-server/get-started?tabs=powershell%2Cvscode%2Chttp


# Prerequisites
# -------------
Get-Module -ListAvailable -Name Microsoft.Entra.Beta
# >= 1.0.13

Get-EntraContext  | % Scopes | Sort-Object
# Application.ReadWrite.All
# Directory.Read.All 
# DelegatedPermissionGrant.ReadWrite.All