param ApimServiceName string
param serviceUrl object
param artifactsBaseUrl string

resource ApimServiceName_billing 'Microsoft.ApiManagement/service/apis@2019-01-01' = {
  properties: {
    isCurrent: false
    subscriptionRequired: true
    displayName: 'billing'
    serviceUrl: serviceUrl.billing
    path: 'billing'
    protocols: [
      'https'
    ]
    value: concat(artifactsBaseUrl, '/apiConfiguration/openApi/billing.yaml')
    format: 'openapi-link'
  }
  name: '${ApimServiceName}/billing'
  dependsOn: []
}

resource ApimServiceName_billing_get_monetization_models_policy 'Microsoft.ApiManagement/service/apis/operations/policies@2019-01-01' = {
  properties: {
    value: concat(artifactsBaseUrl, '/apiConfiguration/policies/apis/billing-get_monetization_models.xml')
    format: 'rawxml-link'
  }
  name: '${ApimServiceName}/billing/get_monetization_models/policy'
  dependsOn: [
    ApimServiceName_billing
  ]
}

resource ApimServiceName_billing_get_products_policy 'Microsoft.ApiManagement/service/apis/operations/policies@2019-01-01' = {
  properties: {
    value: concat(artifactsBaseUrl, '/apiConfiguration/policies/apis/billing-get_products.xml')
    format: 'xml-link'
  }
  name: '${ApimServiceName}/billing/get_products/policy'
  dependsOn: [
    ApimServiceName_billing
  ]
}
