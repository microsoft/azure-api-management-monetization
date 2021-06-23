param apimServiceName string
param serviceUrl object
param artifactsBaseUrl string

resource apiManagementService 'Microsoft.ApiManagement/service@2020-12-01' existing = {
  name: apimServiceName
}

resource addressApi 'Microsoft.ApiManagement/service/apis@2019-01-01' = {
  parent: apiManagementService
  name: 'address'
  properties: {
    isCurrent: false
    subscriptionRequired: true
    displayName: 'address'
    serviceUrl: serviceUrl.address
    path: 'address'
    protocols: [
      'https'
    ]
    value: '${artifactsBaseUrl}/apiConfiguration/openApi/address.yaml'
    format: 'openapi-link'
  }

  resource validateAddressOperation 'operations' existing = {
    name: 'validate_address'

    resource policy 'policies' = {
      name: 'policy'
      properties: {
        value: '${artifactsBaseUrl}/apiConfiguration/policies/apis/address-validate_address.xml'
        format: 'xml-link'
      }
    }
  }
}
