@description('The location into which your Azure resources should be deployed')
param location string

@description('The name of Azure App Service')
param appServiceAppName string

@description('Azure App Service SKU identificator')
@allowed([
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
])
param appServicePlanSkuName string = 'S1'

@description('framework to be used by app service')
@allowed([
  'node|14-lts'
  'node|16-lts'
  'node|18-lts'
])
param windowsFxVersion string = 'node|16-lts'

@description('Output param from service bus module, which will reference connection string to service bus')
param serviceBusConnString string

@description('Output param from service bus module, which will references service bus queue name')
param serviceBusQueueName string

var appServicePlanName = toLower('AppServicePlan-${location}-${appServiceAppName}')
var repoUrl = 'https://github.com/codeHysteria28/AzureServiceBusQueueDemo'

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSkuName
  }
  kind: 'windows'
}

resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      windowsFxVersion: windowsFxVersion
      appSettings: [
        {
          name: 'service_bus_conn_string'
          value: serviceBusConnString
        }
        {
          name: 'service_bus_queue_name'
          value: serviceBusQueueName
        }
      ]
    }
  }
}

resource srcControls 'Microsoft.Web/sites/sourcecontrols@2022-03-01' = {
  name: 'web'
  parent: appServiceApp
  properties: {
    repoUrl: repoUrl
    branch: 'main'
    isManualIntegration: true
  }
}

resource appConfig 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'web'
  parent: appServiceApp
  properties: {
    alwaysOn: true
  }
}

resource loggingConfig 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'logs'
  parent: appServiceApp
  properties: {
    applicationLogs: {
      fileSystem: {
        level: 'Information'
      }
    }
    detailedErrorMessages: {
      enabled: true
    }
    failedRequestsTracing: {
      enabled: true
    }
    httpLogs: {
      fileSystem: {
        enabled: true
        retentionInDays: 1
      }
    }
  }
}
