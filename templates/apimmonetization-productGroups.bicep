param ApimServiceName string

resource ApimServiceName_free_guests_group 'Microsoft.ApiManagement/service/products/groups@2019-01-01' = {
  name: '${ApimServiceName}/free/guests'
}

resource ApimServiceName_free_developers_group 'Microsoft.ApiManagement/service/products/groups@2019-01-01' = {
  name: '${ApimServiceName}/free/developers'
}

resource ApimServiceName_developer_guests_group 'Microsoft.ApiManagement/service/products/groups@2019-01-01' = {
  name: '${ApimServiceName}/developer/guests'
}

resource ApimServiceName_developer_developers_group 'Microsoft.ApiManagement/service/products/groups@2019-01-01' = {
  name: '${ApimServiceName}/developer/developers'
}

resource ApimServiceName_payg_guests_group 'Microsoft.ApiManagement/service/products/groups@2019-01-01' = {
  name: '${ApimServiceName}/payg/guests'
}

resource ApimServiceName_payg_developers_group 'Microsoft.ApiManagement/service/products/groups@2019-01-01' = {
  name: '${ApimServiceName}/payg/developers'
}

resource ApimServiceName_basic_guests_group 'Microsoft.ApiManagement/service/products/groups@2019-01-01' = {
  name: '${ApimServiceName}/basic/guests'
}

resource ApimServiceName_basic_developers_group 'Microsoft.ApiManagement/service/products/groups@2019-01-01' = {
  name: '${ApimServiceName}/basic/developers'
}

resource ApimServiceName_standard_guests_group 'Microsoft.ApiManagement/service/products/groups@2019-01-01' = {
  name: '${ApimServiceName}/standard/guests'
}

resource ApimServiceName_standard_developers_group 'Microsoft.ApiManagement/service/products/groups@2019-01-01' = {
  name: '${ApimServiceName}/standard/developers'
}

resource ApimServiceName_pro_guests_group 'Microsoft.ApiManagement/service/products/groups@2019-01-01' = {
  name: '${ApimServiceName}/pro/guests'
}

resource ApimServiceName_pro_developers_group 'Microsoft.ApiManagement/service/products/groups@2019-01-01' = {
  name: '${ApimServiceName}/pro/developers'
}

resource ApimServiceName_enterprise_guests_group 'Microsoft.ApiManagement/service/products/groups@2019-01-01' = {
  name: '${ApimServiceName}/enterprise/guests'
}

resource ApimServiceName_enterprise_developers_group 'Microsoft.ApiManagement/service/products/groups@2019-01-01' = {
  name: '${ApimServiceName}/enterprise/developers'
}
