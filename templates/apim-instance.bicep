@description('The API Management instance service name')
param serviceName string

@description('The email address of the owner of the service')
param publisherEmail string

@description('The name of the owner of the service')
param publisherName string

@description('The pricing tier of this API Management service')
@allowed([
  'Developer'
  'Standard'
  'Premium'
])
param sku string = 'Developer'

@description('The instance size of this API Management service.')
@maxValue(2)
param skuCount int = 1

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The URL for delegation requests from APIM')
param delegationUrl string

@description('The validation key used for delegation requests from APIM. Default value will generate a new GUID.')
param delegationValidationKeyRaw string = newGuid()

var readerRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')

resource apiManagementService 'Microsoft.ApiManagement/service@2020-12-01' = {
  name: serviceName
  location: location
  sku: {
    name: sku
    capacity: skuCount
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
  }

  resource masterSubscription 'subscriptions' existing = {
    name: 'master'
  }
}

resource apiManagementServiceDelegation 'Microsoft.ApiManagement/service/portalsettings@2021-01-01-preview' = {
  parent: apiManagementService
  name: 'delegation'
  properties: {
    url: delegationUrl
    validationKey: base64(delegationValidationKeyRaw)
    subscriptions: {
      enabled: true
    }
    userRegistration: {
      enabled: true
    }
  }
}

resource apimManagedIdentityReaderRole 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: resourceGroup()
  name: guid(apiManagementService.id, readerRoleId)
  properties: {
    roleDefinitionId: readerRoleId
    principalId: apiManagementService.identity.principalId
  }
}

output gatewayUrl string = apiManagementService.properties.gatewayUrl
output managementUrl string = apiManagementService.properties.managementApiUrl
output developerPortalUrl string = apiManagementService.properties.developerPortalUrl
output adminSubscriptionKey string = apiManagementService::masterSubscription.properties.primaryKey
output delegationValidationKey string = apiManagementServiceDelegation.properties.validationKey
