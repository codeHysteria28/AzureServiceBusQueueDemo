@description('The location into which your Azure resources should be deployed')
param location string = resourceGroup().location

@description('The name of Azure App Service')
param appServiceAppName string = 'wapp${uniqueString(resourceGroup().id)}x'
module appServiceApp 'modules/appservice.bicep' = {
  name: 'appService'
  params: {
    location: location
    appServiceAppName: appServiceAppName
  }
}
