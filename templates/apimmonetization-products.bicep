param ApimServiceName string
param artifactsBaseUrl string

resource ApimServiceName_admin 'Microsoft.ApiManagement/service/products@2019-01-01' = {
  properties: {
    description: 'Admin'
    terms: 'Terms here'
    subscriptionRequired: true
    approvalRequired: true
    subscriptionsLimit: 1
    state: 'published'
    displayName: 'Admin'
  }
  name: '${ApimServiceName}/admin'
  dependsOn: []
}

resource ApimServiceName_free 'Microsoft.ApiManagement/service/products@2019-01-01' = {
  properties: {
    description: 'Free tier with a monthly quota of 100 calls.'
    terms: 'Terms here'
    subscriptionRequired: true
    approvalRequired: false
    subscriptionsLimit: 1
    state: 'published'
    displayName: 'Free'
  }
  name: '${ApimServiceName}/free'
  dependsOn: []
}

resource ApimServiceName_free_policy 'Microsoft.ApiManagement/service/products/policies@2019-01-01' = {
  properties: {
    value: concat(artifactsBaseUrl, '/apiConfiguration/policies/products/free.xml')
    format: 'xml-link'
  }
  name: '${ApimServiceName_free.name}/policy'
}

resource ApimServiceName_developer 'Microsoft.ApiManagement/service/products@2019-01-01' = {
  properties: {
    description: 'Developer tier with a free monthly quota of 100 calls and charges for overage.'
    terms: 'Terms here'
    subscriptionRequired: true
    approvalRequired: true
    state: 'published'
    displayName: 'Developer'
  }
  name: '${ApimServiceName}/developer'
  dependsOn: []
}

resource ApimServiceName_developer_policy 'Microsoft.ApiManagement/service/products/policies@2019-01-01' = {
  properties: {
    value: concat(artifactsBaseUrl, '/apiConfiguration/policies/products/developer.xml')
    format: 'xml-link'
  }
  name: '${ApimServiceName_developer.name}/policy'
}

resource ApimServiceName_payg 'Microsoft.ApiManagement/service/products@2019-01-01' = {
  properties: {
    description: 'Pay-as-you-go tier.'
    terms: 'Terms here'
    subscriptionRequired: true
    approvalRequired: true
    state: 'published'
    displayName: 'PAYG'
  }
  name: '${ApimServiceName}/payg'
  dependsOn: []
}

resource ApimServiceName_payg_policy 'Microsoft.ApiManagement/service/products/policies@2019-01-01' = {
  properties: {
    value: concat(artifactsBaseUrl, '/apiConfiguration/policies/products/payg.xml')
    format: 'xml-link'
  }
  name: '${ApimServiceName_payg.name}/policy'
}

resource ApimServiceName_basic 'Microsoft.ApiManagement/service/products@2019-01-01' = {
  properties: {
    description: 'Basic tier with a monthly quota of 50,000 calls.'
    terms: 'Terms here'
    subscriptionRequired: true
    approvalRequired: true
    state: 'published'
    displayName: 'Basic'
  }
  name: '${ApimServiceName}/basic'
  dependsOn: []
}

resource ApimServiceName_basic_policy 'Microsoft.ApiManagement/service/products/policies@2019-01-01' = {
  properties: {
    value: concat(artifactsBaseUrl, '/apiConfiguration/policies/products/basic.xml')
    format: 'xml-link'
  }
  name: '${ApimServiceName_basic.name}/policy'
}

resource ApimServiceName_standard 'Microsoft.ApiManagement/service/products@2019-01-01' = {
  properties: {
    description: 'Standard tier with a monthly quota of 100,000 calls and charges for overage.'
    terms: 'Terms here'
    subscriptionRequired: true
    approvalRequired: true
    state: 'published'
    displayName: 'Standard'
  }
  name: '${ApimServiceName}/standard'
  dependsOn: []
}

resource ApimServiceName_standard_policy 'Microsoft.ApiManagement/service/products/policies@2019-01-01' = {
  properties: {
    value: concat(artifactsBaseUrl, '/apiConfiguration/policies/products/standard.xml')
    format: 'xml-link'
  }
  name: '${ApimServiceName_standard.name}/policy'
}

resource ApimServiceName_pro 'Microsoft.ApiManagement/service/products@2019-01-01' = {
  properties: {
    description: 'Pro tier with a monthly quota of 500,000 calls and charges for overage.'
    terms: 'Terms here'
    subscriptionRequired: true
    approvalRequired: true
    state: 'published'
    displayName: 'Pro'
  }
  name: '${ApimServiceName}/pro'
  dependsOn: []
}

resource ApimServiceName_pro_policy 'Microsoft.ApiManagement/service/products/policies@2019-01-01' = {
  properties: {
    value: concat(artifactsBaseUrl, '/apiConfiguration/policies/products/pro.xml')
    format: 'xml-link'
  }
  name: '${ApimServiceName_pro.name}/policy'
}

resource ApimServiceName_enterprise 'Microsoft.ApiManagement/service/products@2019-01-01' = {
  properties: {
    description: 'Enterprise tier with a monthly quota of 1,500,000 calls. Overage is charged in units of 1,500,000 calls.'
    terms: 'Terms here'
    subscriptionRequired: true
    approvalRequired: true
    state: 'published'
    displayName: 'Enterprise'
  }
  name: '${ApimServiceName}/enterprise'
  dependsOn: []
}

resource ApimServiceName_enterprise_policy 'Microsoft.ApiManagement/service/products/policies@2019-01-01' = {
  properties: {
    value: concat(artifactsBaseUrl, '/apiConfiguration/policies/products/enterprise.xml')
    format: 'xml-link'
  }
  name: '${ApimServiceName_enterprise.name}/policy'
}
