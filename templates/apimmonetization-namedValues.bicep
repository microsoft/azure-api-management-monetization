param apimServiceName string
param subscriptionId string
param resourceGroupName string
param appServiceName string
param artifactsBaseUrl string

resource apiManagementService 'Microsoft.ApiManagement/service@2020-12-01' existing = {
  name: apimServiceName
}

resource subscriptionIDProperty 'Microsoft.ApiManagement/service/properties@2019-01-01' = {
  parent: apiManagementService
  name: 'subscriptionId'
  properties: {
    secret: false
    displayName: 'subscriptionId'
    value: subscriptionId
  }
}

resource resourceGroupNameProperty 'Microsoft.ApiManagement/service/properties@2019-01-01' = {
  parent: apiManagementService
  name: 'resourceGroupName'
  properties: {
    secret: false
    displayName: 'resourceGroupName'
    value: resourceGroupName
  }
}

resource apimServiceNameProperty 'Microsoft.ApiManagement/service/properties@2019-01-01' = {
  parent: apiManagementService
  name: 'apimServiceName'
  properties: {
    secret: false
    displayName: 'apimServiceName'
    value: apimServiceName
  }
}

resource appServiceNameProperty 'Microsoft.ApiManagement/service/properties@2019-01-01' = {
  parent: apiManagementService
  name: 'appServiceName'
  properties: {
    secret: false
    displayName: 'appServiceName'
    value: appServiceName
  }
}

resource monetizationModelsUrlProperty 'Microsoft.ApiManagement/service/properties@2019-01-01' = {
  parent: apiManagementService
  name: 'monetizationModelsUrl'
  properties: {
    secret: false
    displayName: 'monetizationModelsUrl'
    value: '${artifactsBaseUrl}/payment/monetizationModels.json'
  }
}
