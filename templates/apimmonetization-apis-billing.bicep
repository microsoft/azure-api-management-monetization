param apimServiceName string
param serviceUrl object
param artifactsBaseUrl string

resource apiManagementService 'Microsoft.ApiManagement/service@2020-12-01' existing = {
  name: apimServiceName
}

resource billingApi 'Microsoft.ApiManagement/service/apis@2019-01-01' = {
  parent: apiManagementService
  name: 'billing'
  properties: {
    isCurrent: false
    subscriptionRequired: true
    displayName: 'billing'
    serviceUrl: serviceUrl.billing
    path: 'billing'
    protocols: [
      'https'
    ]
    value: '${artifactsBaseUrl}/apiConfiguration/openApi/billing.yaml'
    format: 'openapi-link'
  }

  resource getMonetizationModelsOperation 'operations' existing = {
    name: 'get_monetization_models'

    resource policy 'policies' = {
      name: 'policy'
      properties: {
        value: '${artifactsBaseUrl}/apiConfiguration/policies/apis/billing-get_monetization_models.xml'
        format: 'rawxml-link'
      }
    }
  }

  resource getProductsOperation 'operations' existing = {
    name: 'get_products'

    resource policy 'policies' = {
      name: 'policy'
      properties: {
        value: '${artifactsBaseUrl}/apiConfiguration/policies/apis/billing-get_products.xml'
        format: 'xml-link'
      }    
    }
  }
}
