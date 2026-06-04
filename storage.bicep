param storageAccountName string
param location string = resourceGroup().location
param sku string = 'Standard_LRS'
param containerName string = 'mycontainer'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: sku
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  parent: storageAccount
  name: 'default'
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  parent: blobService
  name: containerName
}

output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
output containerName string = blobContainer.name
