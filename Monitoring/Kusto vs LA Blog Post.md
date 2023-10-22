


#### SC-200 Learning Path 4 Lab 1

```
https://ade.loganalytics.io/subscriptions/<subscriptionID>/resourcegroups/<resourceGroupName>/providers/microsoft.operationalinsights/workspaces/<workspaceName>/search?query=SecurityEvent | where EventID == 4624 | where AccountType == "User" | where LogonType == "2" | where TimeGenerated > ago(1d) | summarize count() by Account, Computer, LogonType | sort by count_ desc
```




```powershell
Get-AzKustoCluster | ft Name,Location,State,Uri

$rgName = 'rg-monitoring'
$clusterName = 'adecluster69118'

Get-AzKustoDatabase -ClusterName $clusterName -ResourceGroupName $rgName
```



[Basic searching and string operators | Kusto King](https://www.kustoking.com/basic-searching-and-string-operators/)

[Polyglot Notebooks: JavaScript LangChain Azure OpenAI — Helmbergers](https://www.helmbergers.com/2023-07-12-polyglot-notebooks-javascript-langchain-azure-openai)

[Helmbergers Let's Code](https://www.unicular.com/helmbergers/)

[REST API overview - Azure Data Explorer | Microsoft Learn](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/api/rest/)

[Azure Data Explorer documentation - Azure Data Explorer | Microsoft Learn](https://learn.microsoft.com/en-us/azure/data-explorer/)

[Query data in Azure Monitor with Azure Data Explorer - Azure Data Explorer | Microsoft Learn](https://learn.microsoft.com/en-us/azure/data-explorer/query-monitor-data)