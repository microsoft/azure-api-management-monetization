param ApimServiceName string
param serviceUrl object
param artifactsBaseUrl string

resource ApimServiceName_address 'Microsoft.ApiManagement/service/apis@2019-01-01' = {
  properties: {
    isCurrent: false
    subscriptionRequired: true
    displayName: 'address'
    serviceUrl: serviceUrl.address
    path: 'address'
    protocols: [
      'https'
    ]
    value: concat(artifactsBaseUrl, '/apiConfiguration/openApi/address.yaml')
    format: 'openapi-link'
  }
  name: '${ApimServiceName}/address'
  dependsOn: []
}

resource ApimServiceName_address_validate_address_policy 'Microsoft.ApiManagement/service/apis/operations/policies@2019-01-01' = {
  properties: {
    value: concat(artifactsBaseUrl, '/apiConfiguration/policies/apis/address-validate_address.xml')
    format: 'xml-link'
  }
  name: '${ApimServiceName}/address/validate_address/policy'
  dependsOn: [
    ApimServiceName_address
  ]
}
