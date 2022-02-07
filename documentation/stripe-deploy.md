# Deploy demo with Stripe

In this tutorial, you'll deploy the demo Stripe account and learn how to:

> [!div class="checklist"]
> * Set up a Stripe account, the required PowerShell and `az cli` tools, an Azure subscription, and a service principal on Azure. 
> * Deploy the Azure resources using either Azure portal or PowerShell.
> * Make your deployment visible to consumers by publishing the Azure developer portal.
> * Initialize the Stripe products and prices.

## Pre-requisites

To prepare for this demo, you'll need to:

> [!div class="checklist"]
> * Create a Stripe account.
> * Install and set up the required PowerShell and Azure CLI tools.
> * Set up an Azure subscription.
> * Set up a service principal in Azure.

### [Create a Stripe account](https://dashboard.stripe.com/register)
    
1. Once you've [created a Stripe account](https://dashboard.stripe.com/register), navigate to the **Developers** tab in the Stripe dashboard.
1. Use the **API keys** menu to create the following two API keys with specific permissions on different APIs.

    | Key name               | Description                                                                                | Permissions                                                                                                                                               |
    |------------------------|--------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------|
    | **Initialization key** | Use to initialize Stripe with products, prices, and webhooks                               | <ul><li>Products: `write`</li><li>Plans: `write`</li><li>Webhook endpoints: `write`</li></ul>                                                             |
    | **App key**            | Used by application to create checkout sessions, subscriptions, and payments for consumers | <ul><li>Checkout sessions: `write`</li><li>Subscriptions: `write`</li><li>Usage records: `write`</li><li>Plans: `read`</li><li>Products: `read`</li></ul> |

### Install and set up the required tools

- Version 7.1 or later of [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.1).
- Version 2.21.0 or later of [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).

### Set up an Azure subscription with admin access

For this sample project, you will need admin access in order to deploy all the included artifacts to Azure. If you do not have an Azure subscription, set up a [free trial](https://azure.microsoft.com/).

### Set up a service principal on Azure

For the solution to work, the Web App component needs a privileged credential on your Azure subscription with the scope to execute `read` operations on API Management (get products, subscriptions, etc.).

Before deploying the resources, set up the service principal in the Azure Active Directory (AAD) tenant used by the Web App to update the status of API Management subscriptions.

The simplest method is using the Azure CLI.

1. [Sign in with Azure CLI](../cli/azure/authenticate-azure-cli.md#sign-in-interactively):

    ```azurecli-interactive
    az login
    ```
2. [Create an Azure service principal with the Azure CLI](../cli/azure/create-an-azure-service-principal-azure-cli.md#password-based-authentication):

    ```azurecli-interactive
    az ad sp create-for-rbac --name <chosen-name-for-your-service-principal> --skip-assignment
    ```

3. Take note of the `name` (ID), `appId` (client ID) and `password` (client secret), as you will need to pass these values as deployment parameters.

4. Retrieve the **object ID** of your new service principal for deployment:

    ```azurecli-interactive
    az ad sp show --id "<id-of-your-service-principal>"
    ```

The correct role assignments for the service principal will be assigned as part of the deployment.

## Deploy the Azure monetization resources

You can deploy the monetization resource via either Azure portal or PowerShell script. 

>[!NOTE]
> For both options, when filling in parameters, leave the `adyen*` parameters blank.

### Azure portal

Click the button below to deploy the example to Azure and fill in the required parameters in the Azure portal.
n
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmicrosoft%2Fazure-api-management-monetization%2Fmain%2Foutput%2Fmain.json)

### PowerShell script

You can deploy by running the `deploy.ps1` PowerShell script at the root of the repo.

1. Provide a parameters file for the `main.json` ARM template. 
    * Find a template for the parameters file provider in `output/main.parameters.template.json`. 
    * Rename this JSON file to `output/main.parameters.json` and update the values as necessary.

2. Execute the `deploy.ps1` script:

    ```powershell
    deploy.ps1 `
    -TenantId "<azure-ad-tenant-id>" `
    -SubscriptionId "<azure-subscription-id>" `
    -ResourceGroupName "apimmonetization" `
    -ResourceGroupLocation "uksouth" `
    -ArtifactStorageAccountName "<name-of-artifact-storage-account>"
    ```

## Publish the API Management developer portal

This example project uses the hosted [API Management developer portal](api-management-howto-developer-portal-customize.md). 

You are required to complete a manual step to publish and make the resources visible to customers. See the [Publish the portal](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-developer-portal-customize#publish) for instructions.

## Initialize Stripe products and prices

Once you've deployed the billing portal, the API Management service, and the products defined within API Management, you'll need to initialize the products in Stripe. Use [the Stripe initialization PowerShell script](../payment/stripeInitialisation.ps1). 

1. Run the script using the following parameters:

    ```powershell
    ./payment/stripeInitialisation.ps1 `
        -StripeApiKey "<the 'Initialization Key' API key (see pre-requisites)>" `
        -ApimGatewayUrl "<the gateway URL of the APIM service - can find in Azure Portal>" `
        -ApimSubscriptionKey "<the primary key for the Built-in all-access subscription in APIM - can find in Azure Portal>" `
        -StripeWebhookUrl "<the URL of the billing portal App Service>/webhook/stripe" `
        -AppServiceResourceGroup "<the name of the resource group containing the billing portal App Service>" `
        -AppServiceName "<the name of the billing portal App Service>"
    ```   

1. The script makes two API calls:

    * To retrieve the API Management products.
    * To retrieve the monetization model definitions.

1. For each of the monetization models defined, the script:

    * Finds the corresponding APIM product.
    * Uses the Stripe CLI to create a Stripe product.
    * For that Stripe product, creates the corresponding price for the model.

1. The script:

    * Creates a webhook in Stripe to listen for:
        * Stripe subscription created events (to create API Management subscriptions when a consumer completes checkout).
        * Failed/cancelled Stripe subscription events (to deactivate API Management subscriptions when consumers cease payment).
    * Adds the secret for webhook connection to the billing portal app settings, so that the app can attach listeners and handle these events.

## Next Steps

* Learn more about [deploying API Management monetization with Stripe](stripe-details.md).
* Learn about the [Adyen deployment](adyen-details.md) option.