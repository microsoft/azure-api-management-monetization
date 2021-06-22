param apimServiceName string

resource apiManagementService 'Microsoft.ApiManagement/service@2020-12-01' existing = {
  name: apimServiceName

  resource freeProduct 'products' existing = {
    name: 'free'

    resource addressApi 'apis' = {
      name: 'address'
    }
  }

  resource developerProduct 'products' existing = {
    name: 'developer'

    resource addressApi 'apis' = {
      name: 'address'
    }    
  }

  resource paygProduct 'products' existing = {
    name: 'payg'

    resource addressApi 'apis' = {
      name: 'address'
    }
  }

  resource basicProduct 'products' existing = {
    name: 'basic'

    resource addressApi 'apis' = {
      name: 'address'
    }
  }

  resource standardProduct 'products' existing = {
    name: 'standard'

    resource addressApi 'apis' = {
      name: 'address'
    }
  }

  resource proProduct 'products' existing = {
    name: 'pro'

    resource addressApi 'apis' = {
      name: 'address'
    }
  }

  resource enterpriseProduct 'products' existing = {
    name: 'enterprise'

    resource addressApi 'apis' = {
      name: 'address'
    }
  }

  resource adminProduct 'products' existing = {
    name: 'admin'

    resource addressApi 'apis' = {
      name: 'address'
    }
  }
}
