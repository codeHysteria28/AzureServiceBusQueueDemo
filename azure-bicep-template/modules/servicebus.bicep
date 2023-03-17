@description('The location into which your Azure resources should be deployed')
param location string

@description('The name of Azure Service Bus namespace')
param serviceBusNamespaceName string = uniqueString(resourceGroup().id)

@description('The name of Azure Service Bus queue')
param serviceBusQueueName string = uniqueString(resourceGroup().id)

@description('Messaging units for your service bus premium namespace')
@allowed([
  1
  2
  4
  8
  16
])
param msgUnitsCapacity int = 1

@description('Service bus SKU tier name')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param serviceBusSkuName string = 'Standard'

@description('Service bus SKU tier')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param serviceBusSkuTier string = 'Standard'

var azServiceBusNamespaceName = 'sbn-${serviceBusNamespaceName}'
var azServiceBusQueueName = 'sbq-${serviceBusQueueName}'
var serviceBusEndpoint = '${serviceBusNamespace.id}/AuthorizationRules/RootManageSharedAccessKey'
var serviceBusConnectionString = listKeys(serviceBusEndpoint, serviceBusNamespace.apiVersion).primaryConnectionString

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: azServiceBusNamespaceName
  location: location
  sku: {
    capacity: msgUnitsCapacity
    name: serviceBusSkuName
    tier: serviceBusSkuTier
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
