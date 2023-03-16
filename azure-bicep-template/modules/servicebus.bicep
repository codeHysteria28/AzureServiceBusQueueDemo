@description('The location into which your Azure resources should be deployed')
param location string = resourceGroup().location

@description('The name of Azure Service Bus namespace')
param serviceBusNamespaceName string = uniqueString(resourceGroup().id)

@description('The name of Azure Service Bus queue')
param serviceBusQueueName string = uniqueString(resourceGroup().id)

var azServiceBusNamespaceName = 'sbn-${serviceBusNamespaceName}'
var azServiceBusQueueName = 'sbq-${serviceBusQueueName}'
var serviceBusEndpoint = '${serviceBusNamespace.id}/AuthorizationRules/RootManageSharedAccessKey'
var serviceBusConnectionString = listKeys(serviceBusEndpoint, serviceBusNamespace.apiVersion).primaryConnectionString

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: azServiceBusNamespaceName
  location: location
  sku: {
    capacity: 1
    name: 'Standard'
    tier: 'Standard'
  }
}

resource serviceBusQueue 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = {
  name: azServiceBusQueueName
  parent: serviceBusNamespace
  properties: {
    enableBatchedOperations: true
    status: 'Active'
  }
}

output serviceBusNamespaceConnectionString string = serviceBusConnectionString
output serviceBusQueueName string = serviceBusQueue.name
