param apimServiceName string

resource apiManagementService 'Microsoft.ApiManagement/service@2020-12-01' existing = {
  name: apimServiceName

  resource freeProduct 'products' existing = {
    name: 'free'

    resource guestsGroup 'groups' = {
      name: 'guests'
    }

    resource developersGroup 'groups' = {
      name: 'developers'
    }
  }

  resource developerProduct 'products' existing = {
    name: 'developer'

    resource guestsGroup 'groups' = {
      name: 'guests'
    }

    resource developersGroup 'groups' = {
      name: 'developers'
    }
  }

  resource paygProduct 'products' existing = {
    name: 'payg'

    resource guestsGroup 'groups' = {
      name: 'guests'
    }

    resource developersGroup 'groups' = {
      name: 'developers'
    }
  }

  resource basicProduct 'products' existing = {
    name: 'basic'

    resource guestsGroup 'groups' = {
      name: 'guests'
    }

    resource developersGroup 'groups' = {
      name: 'developers'
    }
  }

  resource standardProduct 'products' existing = {
    name: 'standard'

    resource guestsGroup 'groups' = {
      name: 'guests'
    }

    resource developersGroup 'groups' = {
      name: 'developers'
    }
  }

  resource proProduct 'products' existing = {
    name: 'pro'

    resource guestsGroup 'groups' = {
      name: 'guests'
    }

    resource developersGroup 'groups' = {
      name: 'developers'
    }
  }

  resource enterpriseProduct 'products' existing = {
    name: 'enterprise'

    resource guestsGroup 'groups' = {
      name: 'guests'
    }

    resource developersGroup 'groups' = {
      name: 'developers'
    }
  }
}
