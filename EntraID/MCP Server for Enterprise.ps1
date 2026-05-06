# Get Started With the Microsoft MCP Server for Enterprise - Microsoft Graph
# https://learn.microsoft.com/en-us/graph/mcp-server/get-started?tabs=powershell%2Cvscode%2Chttp

# Provision the MCP Server and VS Code (only required once per tenant)
# ---------------------------------------------------------------------
# Prerequisites
Get-Module -ListAvailable -Name Microsoft.Entra.Beta
    # >= 1.0.13

Get-EntraContext  | % Scopes | Sort-Object
    # Application.ReadWrite.All
    # Directory.Read.All 
    # DelegatedPermissionGrant.ReadWrite.All

# Register the Microsoft MCP Server for Enterprise in your tenant and grant all permissions to Visual Studio Code
Grant-EntraBetaMCPServerPermission -ApplicationName VisualStudioCode


# Confirm the MCP server registration
# -----------------------------------
# Verify that both applications exist
    # DisplayName                           ClientID
    # Microsoft MCP Server for Enterprise   e8c77dc2-69b3-43f4-bc51-3213c9d915b4
    # Visual Studio Code                    aebc6443-996d-45c2-90f0-388ff96faa56
Get-MgServicePrincipal -Property "id,appId,displayName" `
    -Filter "appId in('e8c77dc2-69b3-43f4-bc51-3213c9d915b4','aebc6443-996d-45c2-90f0-388ff96faa56')"

# Validate the Microsoft MCP Server permissions that were granted to each MCP client
    # Service Principal Object-IDs ermitteln
$mcpServer = Get-MgServicePrincipal -Filter "appId eq 'e8c77dc2-69b3-43f4-bc51-3213c9d915b4'"
$mcpClient = Get-MgServicePrincipal -Filter "appId eq 'aebc6443-996d-45c2-90f0-388ff96faa56'"

Get-MgOauth2PermissionGrant -Property "id,clientId,resourceId,scope" `
    -Filter "clientId eq '$($mcpClient.Id)' and resourceId eq '$($mcpServer.Id)'" `
    | Format-List ClientId,ResourceId,Scope


# Connect your MCP client to the MCP Server
# -----------------------------------------
# Register MCP server in mcp.json
#   a) Single Folder  -->  .vscode/mcp.json
{
    "servers": {
        "Microsoft MCP Server for Enterprise": {
            "type": "http",
            "url": "https://mcp.svc.cloud.microsoft/enterprise"
        }
    }
}
#   b) Workspace  -->  <workspace>.code-workspace
{
	"folders": [
		{
			"path": "tm2"
		},
		{
			"path": "Contoso"
		},
	],
	"settings": {
		"powershell.cwd": "tm2",
		"mcp": {
			"servers": {
				"Microsoft MCP Server for Enterprise": {
					"type": "http",
					"url": "https://mcp.svc.cloud.microsoft/enterprise"
				}
			}
		}
	}
}

# Open Copilot Chat in Agent mode and ask a tenant-specific question such as "How many users are in my tenant?"


# View supported MCP Server scopes
# --------------------------------

# TBD


# Get more information
# -----------------------
#   [Add and manage MCP servers in VS Code](https://code.visualstudio.com/docs/copilot/customization/mcp-servers)
#   [Explore Microsoft Graph - Training | Microsoft Learn](https://learn.microsoft.com/en-us/training/modules/microsoft-graph/)