## Template reference

| Template                               | called by scenario |
| -------------------------------------- | ------------------ |
| `automationAccount.bicep`              | HybridIdentity     |
| `azureMonitoringAgent.bicep`           | Monitoring         |
| `bastionHost.bicep`                    | HubAndSpoke        |
| `containerGroup.bicep`                 | Container          |
| `dataCollectionRule.bicep`             | Monitoring         |
| `dataCollectionRuleAssociation.bicep`  | Monitoring         |
| `domainController.bicep`               | HybridIdentity     |
| `kustoCluster.bicep`                   | none               |
| `logAnalyticsWorkspace.bicep`          | Monitoring         |
| `storageAccount.bicep`                 | HybridIdentity     |
| `virtualGateway.bicep`                 | HubAndSpoke        |
| `virtualMachine.bicep`                 | Monitoring  <br/> foo  <br/> bar |
| `virtualNetwork.bicep`                 | *none*             |
| `windowsClient.bicep`                  | HybridIdentity     |