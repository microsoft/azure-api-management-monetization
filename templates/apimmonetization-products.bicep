param apimServiceName string
param artifactsBaseUrl string

resource apiManagementService 'Microsoft.ApiManagement/service@2020-12-01' existing = {
  name: apimServiceName
}

resource adminProduct 'Microsoft.ApiManagement/service/products@2019-01-01' = {
  parent: apiManagementService
  name: 'admin'
  properties: {
    description: 'Admin'
    terms: 'Terms here'
    subscriptionRequired: true
    approvalRequired: true
    subscriptionsLimit: 1
    state: 'published'
    displayName: 'Admin'
  }
}

resource freeProduct 'Microsoft.ApiManagement/service/products@2019-01-01' = {
  parent: apiManagementService
  name: 'free'
  properties: {
    description: 'Free tier with a monthly quota of 100 calls.'
    terms: 'Terms here'
    subscriptionRequired: true
    approvalRequired: false
    subscriptionsLimit: 1
    state: 'published'
    displayName: 'Free'
  }

  resource policy 'policies' = {
    name: 'policy'
    properties: {
      value: '${artifactsBaseUrl}/apiConfiguration/policies/products/free.xml'
      format: 'xml-link'
    }
  }
}

resource developerProduct 'Microsoft.ApiManagement/service/products@2019-01-01' = {
  parent: apiManagementService
  name: 'developer'
  properties: {
    description: 'Developer tier with a free monthly quota of 100 calls and charges for overage.'
    terms: 'Terms here'
    subscriptionRequired: true
    approvalRequired: true
    state: 'published'
    displayName: 'Developer'
  }

  resource policy 'policies' = {
    name: 'policy'
    properties: {
      value: '${artifactsBaseUrl}/apiConfiguration/policies/products/developer.xml'
      format: 'xml-link'
    }  
  }
}

resource paygProduct 'Microsoft.ApiManagement/service/products@2019-01-01' = {
  parent: apiManagementService
  name: 'payg'
  properties: {
    description: 'Pay-as-you-go tier.'
    terms: 'Terms here'
    subscriptionRequired: true
    approvalRequired: true
    state: 'published'
    displayName: 'PAYG'
  }

  resource policy 'policies' = {
    name: 'policy'
    properties: {
      value: '${artifactsBaseUrl}/apiConfiguration/policies/products/payg.xml'
      format: 'xml-link'
    }
  }  
}

resource basicProduct 'Microsoft.ApiManagement/service/products@2019-01-01' = {
  parent: apiManagementService
  name: 'basic'
  properties: {
    description: 'Basic tier with a monthly quota of 50,000 calls.'
    terms: 'Terms here'
    subscriptionRequired: true
    approvalRequired: true
    state: 'published'
    displayName: 'Basic'
  }

  resource policy 'policies' = {
    name: 'policy'
    properties: {
      value: '${artifactsBaseUrl}/apiConfiguration/policies/products/basic.xml'
      format: 'xml-link'
    }
  }
}

resource standardProduct 'Microsoft.ApiManagement/service/products@2019-01-01' = {
  parent: apiManagementService
  name: 'standard'
  properties: {
    description: 'Standard tier with a monthly quota of 100,000 calls and charges for overage.'
    terms: 'Terms here'
    subscriptionRequired: true
    approvalRequired: true
    state: 'published'
    displayName: 'Standard'
  }

  resource policy 'policies' = {
    name: 'policy'
    properties: {
      value: '${artifactsBaseUrl}/apiConfiguration/policies/products/standard.xml'
      format: 'xml-link'
    }
  }
}

resource proProduct 'Microsoft.ApiManagement/service/products@2019-01-01' = {
  parent: apiManagementService
  name: 'pro'
  properties: {
    description: 'Pro tier with a monthly quota of 500,000 calls and charges for overage.'
    terms: 'Terms here'
    subscriptionRequired: true
    approvalRequired: true
    state: 'published'
    displayName: 'Pro'
  }

  resource policy 'policies' = {
    name: 'policy'
    properties: {
      value: '${artifactsBaseUrl}/apiConfiguration/policies/products/pro.xml'
      format: 'xml-link'
    }
  }
}

resource enterpriseProduct 'Microsoft.ApiManagement/service/products@2019-01-01' = {
  parent: apiManagementService
  name: 'enterprise'
  properties: {
    description: 'Enterprise tier with a monthly quota of 1,500,000 calls. Overage is charged in units of 1,500,000 calls.'
    terms: 'Terms here'
    subscriptionRequired: true
    approvalRequired: true
    state: 'published'
    displayName: 'Enterprise'
  }

  resource policy 'policies' = {
    name: 'policy'
    properties: {
      value: '${artifactsBaseUrl}/apiConfiguration/policies/products/enterprise.xml'
      format: 'xml-link'
    }
  }
}
