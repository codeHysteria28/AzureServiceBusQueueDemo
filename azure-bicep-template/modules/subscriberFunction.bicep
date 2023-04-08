@description('Location for all resources.')
param location string

@description('Azure Function App name')
param fuctionAppName string = 'fnapp${uniqueString(resourceGroup().id)}'

@description('Azure Function SKU name')
param functionAppPlanName string = 'fnappplan${uniqueString(resourceGroup().id)}'

@description('Azure App Service SKU identificator')
@allowed([
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
])
param functionPlanSkuName string = 'S1'

@description('The language worker runtime to load in the function app')
@allowed([
  'node'
])
param functionAppRuntime string = 'node'

@description('Storage account connection string')
param storageAccountConnectionString string

@description('Output param from service bus module, which will reference connection string to service bus')
param serviceBusConnString string

resource functionAppPlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: functionAppPlanName
  location: location
  sku: {
    name: functionPlanSkuName
  }
  kind: 'windows'
}

resource functionApp 'Microsoft.Web/sites@2022-09-01' = {
  name: fuctionAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: functionAppPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionAppRuntime
        }
        {
          name: 'AzureWebJobsStorage'
          value: storageAccountConnectionString
        }
        {
          name: 'AzureWebJobsServiceBus'
          value: serviceBusConnString
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~16'
        }
      ]
    }
  }
}

// resource ServiceBusFunctionSubscriber 'Microsoft.Web/sites/functions@2022-09-01' = {
//   name: '${fuctionAppName}/subscriber'
//   dependsOn: [
//     functionApp
//   ]
// }
