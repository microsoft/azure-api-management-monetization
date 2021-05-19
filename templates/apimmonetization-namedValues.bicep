param SubscriptionId string
param ResourceGroupName string
param ApimServiceName string
param AppServiceName string
param artifactsBaseUrl string

resource ApimServiceName_subscriptionId 'Microsoft.ApiManagement/service/properties@2019-01-01' = {
  properties: {
    secret: false
    displayName: 'subscriptionId'
    value: SubscriptionId
  }
  name: '${ApimServiceName}/subscriptionId'
  dependsOn: []
}

resource ApimServiceName_resourceGroupName 'Microsoft.ApiManagement/service/properties@2019-01-01' = {
  properties: {
    secret: false
    displayName: 'resourceGroupName'
    value: ResourceGroupName
  }
  name: '${ApimServiceName}/resourceGroupName'
  dependsOn: []
}

resource ApimServiceName_apimServiceName 'Microsoft.ApiManagement/service/properties@2019-01-01' = {
  properties: {
    secret: false
    displayName: 'apimServiceName'
    value: ApimServiceName
  }
  name: '${ApimServiceName}/apimServiceName'
  dependsOn: []
}

resource ApimServiceName_appServiceName 'Microsoft.ApiManagement/service/properties@2019-01-01' = {
  properties: {
    secret: false
    displayName: 'appServiceName'
    value: AppServiceName
  }
  name: '${AppServiceName}/appServiceName'
  dependsOn: []
}

resource ApimServiceName_monetizationModelsUrl 'Microsoft.ApiManagement/service/properties@2019-01-01' = {
  properties: {
    secret: false
    displayName: 'monetizationModelsUrl'
    value: concat(artifactsBaseUrl, '/payment/monetizationModels.json')
  }
  name: '${ApimServiceName}/monetizationModelsUrl'
  dependsOn: []
}
