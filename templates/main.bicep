@description('The API Management instance service name')
param apimServiceName string

@description('The email address of the owner of the APIM service')
param apimPublisherEmail string

@description('The name of the owner of the APIM service')
param apimPublisherName string

@description('The pricing tier of this API Management service')
@allowed([
  'Developer'
  'Standard'
  'Premium'
])
param apimSku string = 'Developer'

@description('The instance size of this API Management service.')
@maxValue(2)
param apimSkuCount int = 1

@description('The authority URL for the Azure Active Directory B2C Tenant.')
param aadAuthority string

@description('The tenant URL for the Azure Active Directory B2C Tenant.')
param aadTenant string

@description('The client ID for the Azure Active Directory B2C Tenant.')
param aadClientId string

@secure()
@description('The client secret for the Azure Active Directory B2C Tenant.')
param aadClientSecret string


@description('The App Service hosting plan name')
param appServiceHostingPlanName string

@description('The App Service name')
param appServiceName string

@allowed([
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1'
  'P2'
  'P3'
  'P1V2'
  'P2V2'
  'P3V2'
])
@description('The pricing tier of the App Service plan to deploy, defaults to Basic')
param appServiceSkuName string = 'B1'

@minValue(1)
param appServiceSkuCapacity int = 1

@description('The payment provider - Adyen or Stripe')
@allowed([
  'Stripe'
  'Adyen'
])
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
param appServiceContainerImage string = 'mcr.microsoft.com/azure-api-management/samples/monetization:0.1.0'

@description('Port for the App Service container')
param appServiceContainerPort int = 8000

@description('The app ID of the service principal that the Web App uses to manage APIM')
param servicePrincipalAppId string

@description('The object ID of the service principal that the Web App uses to manage APIM')
param servicePrincipalObjectId string

@secure()
@description('The password for the service principal')
param servicePrincipalPassword string

@description('The AAD tenant in which the service principal resides')
param servicePrincipalTenantId string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The base URL for artifacts used in deployment.')
param artifactsBaseUrl string = 'https://raw.githubusercontent.com/microsoft/azure-api-management-monetization/main'

var contributorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions/', 'b24988ac-6180-42a0-ab88-20f7382dd24c')

module appService 'app-service.bicep' = {
  name: 'appServiceDeploy'
  params: {
    location: location
    hostingPlanName: appServiceHostingPlanName
    webSiteName: appServiceName
    skuName: appServiceSkuName
    skuCapacity: appServiceSkuCapacity
    containerImage: appServiceContainerImage
  }
}

module apimInstance './apim-instance.bicep' = {
  name: 'apimInstanceDeploy'
  params: {
    serviceName: apimServiceName
    publisherEmail: apimPublisherEmail
    publisherName: apimPublisherName
    sku: apimSku
    skuCount: apimSkuCount
    location: location
    delegationUrl: uri('https://${appService.outputs.webSiteUrl}', 'apim-delegation')
  }
}

module apimIdentityProvider './apim-identity-provider.bicep' = {
  name: 'apimIdentityProvider'
  params: {
    apimServiceName: apimServiceName
    aadAuthority: aadAuthority
    aadTenant: aadTenant
    aadClientId: aadClientId
    aadClientSecret: aadClientSecret
  }
  dependsOn: [
    apimInstance
  ]
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
    apimInstanceNamedValues
  ]
}

module appServiceSettings 'app-service-settings.bicep' = {
  name: 'appServiceSettingsDeploy'
  params: {
    webSiteName: appServiceName
    apimServiceName: apimServiceName
    stripeApiKey: stripeApiKey
    stripePublicKey: stripePublicKey
    containerPort: appServiceContainerPort
    servicePrincipalAppId: servicePrincipalAppId
    servicePrincipalPassword: servicePrincipalPassword
    servicePrincipalTenantId: servicePrincipalTenantId
    paymentProvider: paymentProvider
    adyenApiKey: adyenApiKey
    adyenClientKey: adyenClientKey
    adyenMerchantAccount: adyenMerchantAccount
  }
  dependsOn: [
    apimInstance
  ]
}

resource servicePrincipalContributorRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, servicePrincipalObjectId, contributorRoleId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: contributorRoleId
    principalId: servicePrincipalObjectId
  }
}
