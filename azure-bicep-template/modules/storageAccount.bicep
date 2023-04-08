@description('storage account location')
param location string

// storage account name
@description('storage account name')
param storageAccountName string = toLower('storage${uniqueString(resourceGroup().id)}')

// storage account type
@description('storage account type')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
])
param storageAccountType string = 'Standard_LRS'

// storage account kind
@description('storage account kind')
@allowed([
  'StorageV2'
])
param storageAccountKind string = 'StorageV2'

// storage account connection string
var storageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'

// definining storage account resource block
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  kind: storageAccountKind
  sku: {
    name: storageAccountType
  }
  properties: {
    accessTier: 'Hot'
    encryption: {
      services: {
        blob: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    allowBlobPublicAccess: false
  }
}

// storage account name and connection string output
output storageAccountName string = storageAccount.name
output storageAccountConnectionString string = storageAccountConnectionString
