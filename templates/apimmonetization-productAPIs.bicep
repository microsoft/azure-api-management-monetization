param ApimServiceName string

resource ApimServiceName_free_address 'Microsoft.ApiManagement/service/products/apis@2019-01-01' = {
  name: '${ApimServiceName}/free/address'
  dependsOn: []
}

resource ApimServiceName_developer_address 'Microsoft.ApiManagement/service/products/apis@2019-01-01' = {
  name: '${ApimServiceName}/developer/address'
  dependsOn: [
    ApimServiceName_free_address
  ]
}

resource ApimServiceName_payg_address 'Microsoft.ApiManagement/service/products/apis@2019-01-01' = {
  name: '${ApimServiceName}/payg/address'
  dependsOn: [
    ApimServiceName_developer_address
  ]
}

resource ApimServiceName_basic_address 'Microsoft.ApiManagement/service/products/apis@2019-01-01' = {
  name: '${ApimServiceName}/basic/address'
  dependsOn: [
    ApimServiceName_payg_address
  ]
}

resource ApimServiceName_standard_address 'Microsoft.ApiManagement/service/products/apis@2019-01-01' = {
  name: '${ApimServiceName}/standard/address'
  dependsOn: [
    ApimServiceName_basic_address
  ]
}

resource ApimServiceName_pro_address 'Microsoft.ApiManagement/service/products/apis@2019-01-01' = {
  name: '${ApimServiceName}/pro/address'
  dependsOn: [
    ApimServiceName_standard_address
  ]
}

resource ApimServiceName_enterprise_address 'Microsoft.ApiManagement/service/products/apis@2019-01-01' = {
  name: '${ApimServiceName}/enterprise/address'
  dependsOn: [
    ApimServiceName_pro_address
  ]
}

resource ApimServiceName_admin_billing 'Microsoft.ApiManagement/service/products/apis@2019-01-01' = {
  name: '${ApimServiceName}/admin/billing'
  dependsOn: [
    ApimServiceName_enterprise_address
  ]
}