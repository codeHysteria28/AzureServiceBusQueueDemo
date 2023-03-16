@description('The location into which your Azure resources should be deployed')
param location string = resourceGroup().location

@description('The name of Azure App Service')
param appServiceAppName string

@description('framework to be used by app service')
param windowsFxVersion string = 'node|16-lts'

var appServicePlanSkuName = 'S1'
var appServicePlanName = toLower('AppServicePlan-${location}-${appServiceAppName}')
var repoUrl = 'https://github.com/codeHysteria28/AzureServiceBusQueueDemo'

module serviceBus 'servicebus.bicep' = {
  name: 'serviceBus'
  params: {
    location: location
  }
}

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
          value: serviceBus.outputs.serviceBusNamespaceConnectionString
        }
        {
          name: 'service_bus_queue_name'
          value: serviceBus.outputs.serviceBusQueueName
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
