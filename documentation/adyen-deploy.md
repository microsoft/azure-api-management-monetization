# Deploy demo with Adyen

## 1. Pre-requisites

### Set up Adyen test account

You will need to [create an Adyen test account](https://www.adyen.com/signup).

- Set up a merchant "ECommerce" account.
- Go to the Account tab at the top of the Adyen test homepage, and select the Web Service username.
- Add the origin that you will be using to the list of allowed origins.
- Retrieve the API key and client key.

### Required tools

- [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.1) - version 7.1 or later
- [Az CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) - version 2.21.0 or later

### Service Principal

In order to run the deployment, you will need a service principal set up in the AAD tenant that will be used by the Web App to update the status of APIM subscriptions. 

The simplest way to do this is using the Az CLI.

First, you need to [Sign in with Azure CLI](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli) by using the following command:
```
az login
```
Then you can [Create an Azure service principal with the Azure CLI](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli) through the following command:

```
az ad sp create-for-rbac -n "<name-for-your-service-principal>" --skip-assignment
```

Take note of the appId (aka client ID) and password (aka client secret), as you will need to pass these values as deployment parameters.

For deployment, you will also need the object ID of the service principal you just created. To retrieve this use:

```
az ad sp show --id "http://<name-for-your-service-principal>"
```

The correct role assignments for the service principal will be assigned as part of the deployment.

## 2. Deploy the Azure resources

Select one of 2 options below for deploying the Azure resources. For both options, when filling in parameters, ignore the `stripe*` parameters (leave them blank).

### Option 1

Click the button below to deploy the example to Azure. You will be able to fill in the required parameters in the Azure Portal.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%microsoft%2Fazure-api-management-monetization%2Fmain%2Ftemplates%2main.json)

### Option 2

Alternatively, you can also deploy by running the `deploy.ps1` PowerShell script at the root of the repo.

You must have the Azure CLI installed and be logged in (`az login`).

You will need to provide a parameters file for the `main.json` ARM template. There is a template for the parameters file provider in `output/main.parameters.template.json` - you can rename this to `output/main.parameters.json` and update the values as necessary.

Then execute the `deploy.ps` script, e.g.:

```powershell
deploy.ps1 `
    -TenantId "<azure-ad-tenant-id>" `
    -SubscriptionId "<azure-subscription-id>" `
    -ResourceGroupName "apimmonetization" `
    -ResourceGroupLocation "uksouth" `
    -ArtifactStorageAccountName "<name-of-artifact-storage-account>"
```

## 3. Additional Steps

### Publishing the APIM Developer Portal

The example makes use of the hosted [APIM Developer Portal](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-developer-portal-customize), but there is a manual step required to publish this to make this visible to customers. Follow the steps in the [Publish the portal](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-developer-portal-customize#publish) section to do this.