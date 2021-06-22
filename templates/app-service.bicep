param location string = resourceGroup().location

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
param skuName string = 'B1'

@minValue(1)
param skuCapacity int = 1

param hostingPlanName string
param webSiteName string

param apimServiceName string

param containerImage string

var linuxFxVersion = 'DOCKER|${containerImage}'

resource apiManagementService 'Microsoft.ApiManagement/service@2020-12-01' existing = {
  name: apimServiceName

  resource masterSubscription 'subscriptions' existing = {
    name: 'master'
  }

  resource serviceDelegation 'portalsettings@2021-01-01-preview' = {
    name: 'delegation'
  }
}

resource hostingPlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: hostingPlanName
  location: location
  kind: 'linux'
  properties: {
    reserved: true
  }
  sku: {
    name: skuName
    capacity: skuCapacity
  }
}

resource webSite 'Microsoft.Web/sites@2018-11-01' = {
  name: webSiteName
  location: location
  properties: {
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      alwaysOn: true
    }
    serverFarmId: hostingPlan.id
    clientAffinityEnabled: false
  }
}

output webSiteUrl string = webSite.properties.defaultHostName
