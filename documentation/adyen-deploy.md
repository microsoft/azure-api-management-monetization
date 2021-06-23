# Deploy demo with Adyen

## 1. Pre-requisites

You will need to [create an Adyen test account](https://www.adyen.com/signup).

- Set up a merchant "ECommerce" account.
- Go to the Account tab at the top of the Adyen test homepage, and select the Web Service username.
- Add the origin that you will be using to the list of allowed origins.
- Retrieve the API key and client key.

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