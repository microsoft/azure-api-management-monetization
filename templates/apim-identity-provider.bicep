param apimServiceName string
param aadAuthority string
param aadTenant string
param aadClientId string

@secure()
param aadClientSecret string


var aadClientLibrary = 'MSAL-2'
var aadSigninPolicy = 'B2C_1_signupsignin1'
var aadSignupPolicy = 'B2C_1_signupsignin1'
var idpType = 'aadB2C'


resource apiManagementService 'Microsoft.ApiManagement/service@2020-12-01' existing = {
  name: apimServiceName
}

resource apimIdp 'Microsoft.ApiManagement/service/identityProviders@2022-09-01-preview' = {
  parent: apiManagementService
  name: 'aadb2c'
  properties: {
    authority: aadAuthority
    allowedTenants: [
      aadTenant
    ]
    clientId: aadClientId
    clientLibrary: aadClientLibrary
    clientSecret: aadClientSecret
    signinPolicyName: aadSigninPolicy
    signinTenant: aadTenant
    signupPolicyName: aadSignupPolicy
    type: idpType
  }
}

resource portalSignupSetting 'Microsoft.ApiManagement/service/portalsettings@2022-09-01-preview' = {
  name: 'signup'
  parent: apiManagementService
  properties: {
    enabled: false
  }
}

resource portalSigninSetting 'Microsoft.ApiManagement/service/portalsettings@2022-09-01-preview' = {
  name: 'signin'
  parent: apiManagementService
  properties: {
    enabled: false
  }
}
