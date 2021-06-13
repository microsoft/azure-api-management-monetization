@description('The API Management instance service name')
param apimServiceName string

@description('The email address of the owner of the APIM service')
param apimPublisherEmail string

@description('The name of the owner of the APIM service')
param apimPublisherName string

@allowed([
  'Developer'
  'Standard'
  'Premium'
])
@description('The pricing tier of this API Management service')
param apimSku string = 'Developer'

@maxValue(2)
@description('The instance size of this API Management service.')
param apimSkuCount int = 1

@description('The App Service hosting plan name')
param appServiceHostingPlanName string

@description('The App Service name')
param appServiceName string

@description('The pricing tier of the App Service to deploy, defaults to Free')
param appServiceSkuName string = 'F1'

@minValue(1)
param appServiceSkuCapacity int = 1

@allowed([
  'Stripe'
  'Adyen'
])
@description('The payment provider - Adyen or Stripe')
param paymentProvider string

@secure()
@description('The Stripe secret API key - required if using Stripe')
param stripeApiKey string = ''

@description('The Stripe publishable key - required if using Stripe')
param stripePublicKey string = ''

@secure()
@description('The Adyen API key - required if using Adyen')
param adyenApiKey string = ''

@description('The Adyen client key - required if using Adyen')
param adyenClientKey string = ''

@description('The Adyen merchant account ID - required if using Adyen')
param adyenMerchantAccount string = ''

@description('The container image to deploy to the app service. By default is retrieved from Github')
param appServiceContainerImage string = 'ghcr.io/microsoft/azure-api-management-monetization/app:latest'

@description('Port for the App Service container')
param appServiceContainerPort int = 8000

@description('The client ID of the service principal that the Web App uses to manage APIM')
param servicePrincipalClientId string

@description('The object ID of the service principal that the Web App uses to manage APIM')
param servicePrincipalObjectId string

@description('The client secret for the service principal')
@secure()
param servicePrincipalClientSecret string

@description('The AAD tenant in which the service principal resides')
param servicePrincipalTenantId string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The base URL for artifacts used in deployment.')
param artifactsBaseUrl string = 'https://raw.githubusercontent.com/microsoft/azure-api-management-monetization/main'

var contributorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions/', 'b24988ac-6180-42a0-ab88-20f7382dd24c')

module apimInstance './apim-instance.bicep' = {
  name: 'apimInstanceDeploy'
  params: {
    serviceName: apimServiceName
    publisherEmail: apimPublisherEmail
    publisherName: apimPublisherName
    sku: apimSku
    skuCount: apimSkuCount
    location: location
    delegationUrl: 'https://${appServiceName}.azurewebsites.net/apim-delegation'
  }
}

module apimAddressApi './apimmonetization-apis-address.bicep' = {
  name: 'apimAddressApiDeploy'
  params: {
    apimServiceName: apimServiceName
    serviceUrl: {
      address: 'https://api.microsoft.com/address'
    }
    artifactsBaseUrl: artifactsBaseUrl
  }
  dependsOn: [
    apimInstance
  ]
}

module apimBillingApi './apimmonetization-apis-billing.bicep' = {
  name: 'apimBillingApiDeploy'
  params: {
    apimServiceName: apimServiceName
    serviceUrl: {
      billing: 'https://api.microsoft.com/billing'
    }
    artifactsBaseUrl: artifactsBaseUrl
  }
  dependsOn: [
    apimInstance
    apimInstanceNamedValues
  ]
}

module apimProducts './apimmonetization-products.bicep' = {
  name: 'apimProductsDeploy'
  params: {
    apimServiceName: apimServiceName
    artifactsBaseUrl: artifactsBaseUrl
  }
  dependsOn: [
    apimAddressApi
    apimBillingApi
  ]
}

module apimProductsApis './apimmonetization-productAPIs.bicep' = {
  name: 'apimProductsApisDeploy'
  params: {
    apimServiceName: apimServiceName
  }
  dependsOn: [
    apimProducts
  ]
}

module apimProductsGroups './apimmonetization-productGroups.bicep' = {
  name: 'apimProductsGroupsDeploy'
  params: {
    apimServiceName: apimServiceName
  }
  dependsOn: [
    apimProducts
  ]
}

module apimInstanceNamedValues './apimmonetization-namedValues.bicep' = {
  name: 'apimInstanceNamedValuesDeploy'
  params: {
    subscriptionId: subscription().subscriptionId
    resourceGroupName: resourceGroup().name
    apimServiceName: apimServiceName
    appServiceName: appServiceName
    artifactsBaseUrl: artifactsBaseUrl
  }
  dependsOn: [
    apimInstance
  ]
}

module apimGlobalServicePolicy './apimmonetization-globalServicePolicy.bicep' = {
  name: 'apimGlobalServicePolicyDeploy'
  params: {
    apimServiceName: apimServiceName
    artifactsBaseUrl: artifactsBaseUrl
  }
  dependsOn: [
    apimInstance
  ]
}

module appService 'app-service.bicep' = {
  name: 'appServiceDeploy'
  params: {
    hostingPlanName: appServiceHostingPlanName
    webSiteName: appServiceName
    skuName: appServiceSkuName
    apimServiceName: apimServiceName
    apimAdminSubscriptionKey: apimInstance.outputs.adminSubscriptionKey
    apimGatewayUrl: apimInstance.outputs.gatewayUrl
    apimManagementUrl: apimInstance.outputs.managementUrl
    apimDeveloperPortalUrl: apimInstance.outputs.developerPortalUrl
    apimDelegationValidationKey: apimInstance.outputs.delegationValidationKey
    stripeApiKey: stripeApiKey
    stripePublicKey: stripePublicKey
    containerImage: appServiceContainerImage
    containerPort: appServiceContainerPort
    servicePrincipalClientId: servicePrincipalClientId
    servicePrincipalClientSecret: servicePrincipalClientSecret
    servicePrincipalTenantId: servicePrincipalTenantId
    paymentProvider: paymentProvider
    adyenApiKey: adyenApiKey
    adyenClientKey: adyenClientKey
    adyenMerchantAccount: adyenMerchantAccount
  }
}

resource servicePrincipalContributorRole 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, servicePrincipalObjectId, contributorRoleId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: contributorRoleId
    principalId: servicePrincipalObjectId
  }
}
