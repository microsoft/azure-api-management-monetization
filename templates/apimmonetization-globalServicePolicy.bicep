param ApimServiceName string
param artifactsBaseUrl string

resource ApimServiceName_policy 'Microsoft.ApiManagement/service/policies@2019-01-01' = {
  properties: {
    value: concat(artifactsBaseUrl, '/apiConfiguration/policies/global.xml')
    format: 'xml-link'
  }
  name: '${ApimServiceName}/policy'
  dependsOn: []
}
