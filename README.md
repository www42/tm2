## Template reference

| Template                               | called by scenario |
| -------------------------------------- | ------------------ |
| `automationAccount.bicep`              | HybridIdentity     |
| `azureMonitoringAgent.bicep`           | Monitoring         |
| `bastionHost.bicep`                    | HubAndSpoke        |
| `dataCollectionRule.bicep`             | Monitoring         |
| `dataCollectionRuleAssociation.bicep`  | Monitoring         |
| `domainController.bicep`               | HybridIdentity     |
| `logAnalyticsWorkspace.bicep`          | Monitoring         |
| `storageAccount.bicep`                 | HybridIdentity     |
| `virtualGateway.bicep`                 | HubAndSpoke        |
| `virtualMachine.bicep`                 | Monitoring  <br/> foo  <br/> bar |
| `virtualNetwork.bicep`                 | *none*             |
| `windowsClient.bicep`                  | HybridIdentity     |