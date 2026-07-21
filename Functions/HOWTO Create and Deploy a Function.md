# Steps

1. Create a Function App

   Use the Azure Portal or a Bicep template or Azure CLI .
   
   You have to create an App Service plan as well as a storage account too.

   [`Create Azure Function App CLI.ps1`](./Create_Azure_Function_App_CLI.ps1) is a sample CLI script to create the Function App.

2. Use VS Code to deploy functions to the Function App

   [Create and deploy function code to Azure using Visual Studio Code](https://learn.microsoft.com/en-us/azure/azure-functions/how-to-create-function-vs-code?pivot=programming-language-javascript&tabs=go%2Cwindows&pivots=programming-language-powershell)

   Create an empty folder e.g. `func-n8n-5045`

   in top level `.vscode\settings.json` adjust the path to this folder

   ```json
    "azureFunctions.deploySubpath": "Functions\\func-n8n-5045",
   ```
   Go to Azure Function extension and create a new Function.