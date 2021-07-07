# Deploy demo with Stripe

## 1. Pre-requisites

You will need to [create a Stripe account](https://dashboard.stripe.com/register).

Once created, you will need to create two API keys. You can do this from the "Developers" tab in the Stripe dashboard. You can set up these keys with specific permissions on different APIs.

The two keys you need to create are:

| Key                | Description                                                                               | Permissions                                                             |
|--------------------|-------------------------------------------------------------------------------------------|-------------------------------------------------------------------------|
| Initialization Key | Used for initializing Stripe with products, prices and webhooks                           | Products - Write, Plans - Write, Webhook Endpoints - Write              |
| App Key            | Used by application to create checkout sessions, subscriptions and payments for consumers | Checkout Sessions - Write, Subscriptions - Write, Usage Records - Write, Plans - Read |

## 2. Deploy the Azure resources

Select one of 2 options below for deploying the Azure resources. For both options, when filling in parameters, ignore the `adyen*` parameters (leave them blank).

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

### Initialize Stripe products and prices

Once the billing portal and APIM service have been deployed, and the products defined within APIM, the same products need to be initialised in Stripe, using [this PowerShell script](../payment/stripeInitialisation.ps1). To run the script, first ensure the Az CLI in installed and you are logged in (`az login`), then run using the following parameters:

```powershell
./payment/stripeInitialisation.ps1 `
    -StripeApiKey "<the 'Initialization Key' API key (see pre-requisites)>" `
    -ApimGatewayUrl "<the gateway URL of the APIM service - can find in Azure Portal>" `
    -ApimSubscriptionKey "<the default admin subscription key for the APIM service - can find in Azure Portal>" `
    -StripeWebhookUrl "<the URL of the billing portal App Service>/webhook/stripe" `
    -AppServiceResourceGroup "<the name of the resource group containing the billing portal App Service>" `
    -AppServiceName "<the name of the billing portal App Service>"
```

The script performs the following functions:

It first makes two API calls:

- To retrieve the APIM products.
- To retrieve the monetization model definitions.

For each of the monetization models defined, the script:

1. Finds the corresponding APIM product.
2. Uses the Stripe CLI to create a Stripe product.
3. For that Stripe product, creates the corresponding price for the model.
   
Additionally, the script:
- Creates a webhook in stripe which can be used to listen for Stripe subscription created events (which we can listen for and create APIM subscriptions when a Consumer completed checkout) and failed / cancelled Stripe subscription events (which we can use to deactivate APIM subscriptions when Consumers cease to pay for them).
- Adds the secret for connecting to the webhook to the settings of the billing portal app, so that the app can attach listeners and handle these events.