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
param skuCount int = 1

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The URL for delegation requests from APIM')
param delegationUrl string

@description('The validation key used for delegation requests from APIM. Default value will generate a new GUID. If deploying to production, consider setting this parameter explicitly to avoid the value being regenerated for new deployments.')
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
      enabled: false
    }
  }
}

resource apimManagedIdentityReaderRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: resourceGroup()
  name: guid(apiManagementService.id, readerRoleId)
  properties: {
    roleDefinitionId: readerRoleId
    principalId: apiManagementService.identity.principalId
  }
}
