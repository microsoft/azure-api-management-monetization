param location string = resourceGroup().location

@allowed([
  'F1'
  'D1'
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1'
  'P2'
  'P3'
  'P4'
])
param skuName string = 'F1'

@minValue(1)
param skuCapacity int = 1

param hostingPlanName string
param webSiteName string

param apimServiceName string
param apimManagementUrl string
param apimGatewayUrl string
param apimDeveloperPortalUrl string
param apimAdminSubscriptionKey string
param apimDelegationValidationKey string

param paymentProvider string

// Required for Stripe
param stripePublicKey string = ''
param stripeApiKey string = ''

// Required for Adyen
param adyenApiKey string = ''
param adyenClientKey string = ''
param adyenMerchantAccount string = ''

param containerImage string
param containerPort int

param servicePrincipalClientId string
@secure()
param servicePrincipalClientSecret string
param servicePrincipalTenantId string

var linuxFxVersion = concat('DOCKER|', containerImage)

resource hostingPlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: hostingPlanName
  location: location
  kind: 'linux'
  properties: {
    reserved: true
  }
  sku: {
    name: skuName
  }
  dependsOn: []
}


resource webSite 'Microsoft.Web/sites@2018-11-01' = {
  name: webSiteName
  location: location
  properties: {
    name: webSiteName
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      alwaysOn: true
    }
    serverFarmId: hostingPlan.id
    clientAffinityEnabled: false
  }
  dependsOn: [
    hostingPlan
  ]
}

resource webSiteAppSettings 'Microsoft.Web/sites/config@2020-06-01' = {
  name: '${webSite.name}/appsettings'
  properties: {
    NODE_ENV: 'production'
    SERVER_PORT: '8000'
    APIM_MANAGEMENT_URL: apimManagementUrl
    APIM_GATEWAY_URL: apimGatewayUrl
    APIM_DEVELOPER_PORTAL_URL: apimDeveloperPortalUrl
    APIM_ADMIN_SUBSCRIPTION_KEY: apimAdminSubscriptionKey
    STRIPE_PUBLIC_KEY: stripePublicKey
    STRIPE_API_KEY: stripeApiKey
    WEBSITES_PORT: string(containerPort)
    WEBSITES_ENABLE_APP_SERVICE_STORAGE: false
    APIM_SERVICE_NAME: apimServiceName
    APIM_SERVICE_AZURE_SUBSCRIPTION_ID: subscription().subscriptionId
    APIM_SERVICE_AZURE_RESOURCE_GROUP_NAME: resourceGroup().name
    APIM_DELEGATION_VALIDATION_KEY: apimDelegationValidationKey
    AZURE_AD_SERVICE_PRINCIPAL_CLIENT_ID: servicePrincipalClientId
    AZURE_AD_SERVICE_PRINCIPAL_CLIENT_SECRET: servicePrincipalClientSecret
    AZURE_AD_SERVICE_PRINCIPAL_TENANT_ID: servicePrincipalTenantId
    PAYMENT_PROVIDER: paymentProvider
    ADYEN_MERCHANT_ACCOUNT: adyenMerchantAccount
    ADYEN_CLIENT_KEY: adyenClientKey
    ADYEN_API_KEY: adyenApiKey
  }
}

output webSiteUrl string = webSite.properties.defaultHostName
