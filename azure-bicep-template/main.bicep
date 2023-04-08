@description('The location into which your Azure resources should be deployed')
param location string = resourceGroup().location

@description('The name of Azure App Service')
param appServiceAppName string = 'wapp${uniqueString(resourceGroup().id)}x'

@description('Deploy subscriber function and storage account')
param deployFnSubStorAcc bool = false

module storageAccount 'modules/storageaccount.bicep' = if(deployFnSubStorAcc) {
  name: 'storageAccount'
  params: {
    location: location
  }
}

module serviceBus 'modules/servicebus.bicep' = {
  name: 'serviceBus'
  params: {
    location: location
  }
}

module appServiceApp 'modules/appservice.bicep' = {
  name: 'appService'
  params: {
    location: location
    appServiceAppName: appServiceAppName
    serviceBusConnString: serviceBus.outputs.serviceBusNamespaceConnectionString
    serviceBusQueueName: serviceBus.outputs.serviceBusQueueName
  }
  dependsOn: [
    serviceBus
  ]
}

module functionApp 'modules/subscriberFunction.bicep' = if(deployFnSubStorAcc) {
  name: 'functionApp'
  params: {
    location: location
    storageAccountConnectionString: storageAccount.outputs.storageAccountConnectionString
    serviceBusConnString: serviceBus.outputs.serviceBusNamespaceConnectionString
    serviceBusQueueName: serviceBus.outputs.serviceBusQueueName
    APPINSIGHTS_INSTRUMENTATIONKEY: appServiceApp.outputs.appInsightsInstrumentationKey
  }
  dependsOn: [
    storageAccount
    serviceBus
    appServiceApp
  ]
}
