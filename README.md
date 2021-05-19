# Azure API Management - Monetization

This solution provides an example of how to integrate Azure API Management (APIM) with payment providers - the options in this example are Stripe, or Adyen. This integration allows consumers to subscribe to public APIs and enter their payment details in order to activate those subscriptions.

To find out more about how this works, read the [API subscription guide](documentation/API-Subscription.md)!

## Architecture

The following diagram illustrates the architecture for integration with Stripe as a payment provider:

![](documentation/architecture-stripe.png)

The architecture for the Adyen integraiton is also available in the [Adyen documentation](documentation\Adyen.md).

## Prerequisites

### Required tools

- [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.1)
- [Az CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

### Service Principal

In order to run the deployment, you will need a service principal set up in the AAD tenant that will be used by the Web App to update the status of APIM subscriptions. 

The simplest way to do this is using the Az CLI - run the following commands:

```
az login
az ad sp create-for-rbac -n "<name-for-your-service-principal>" --skip-assignment
```

Take note of the appId (aka client ID) and password (aka client secret), as you will need to pass these values as deployment parameters.

For deployment, you will also need the object ID of the service principal you just created. To retrieve this use:

```
az ad sp show --id "http://<name-for-your-service-principal>"
```

The correct role assignments for the service principal will be assigned as part of the deployment.

### Payment providers

Depending which payment provider you are using, you will need to do some set up for your account.

#### Stripe

You will need to [create a Stripe account](https://dashboard.stripe.com/register).

Once created, you will need to create two API keys. You can do this from the "Developers" tab in the Stripe dashboard. You can set up these keys with specific permissions on different APIs.

The two keys you need to create are:

| Key                | Description                                                                               | Permissions                                                             |
|--------------------|-------------------------------------------------------------------------------------------|-------------------------------------------------------------------------|
| Initialization Key | Used for initializing Stripe with products, prices and webhooks                           | Products - Write, Plans - Write, Webhook Endpoints - Write              |
| App Key            | Used by application to create checkout sessions, subscriptions and payments for consumers | Checkout Sessions - Write, Subscriptions - Write, Usage Records - Write |

#### Adyen

You will need to [create an Adyen test account](https://www.adyen.com/signup).

- Set up a merchant "ECommerce" account.
- Go to the Account tab at the top of the Adyen test homepage, and select the Web Service username.
- Add the origin that you will be using to the list of allowed origins.
- Retrieve the API key and client key.

## Deploying the example

The following resources are deployed as part of the example:
- API Management service
- API Management resources (APIs, Products, Policies, Named Values)
- App Service Plan
- Web App for Containers, using the [billing portal app container image](./documentation/Initialisation.md#billing-portal)
- Service Principal RBAC assignment

Click the button below to deploy the example to Azure. You will be able to fill in the required parameters in the Azure Portal.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%microsoft%2Fazure-api-management-monetization%2Fmain%2Ftemplates%2main.json)

Alternatively, you can also deploy by running the `deploy.ps1` PowerShell script at the root of the repo, e.g.:

```powershell
deploy.ps1 -TenantId "<azure-ad-tenant-id>" -SubscriptionId "<azure-subscription-id>" -ResourceGroupName "apimmonetization" -ResourceGroupLocation "uksouth" --ArtifactStorageAccountName "<name-of-artifact-storage-account>"
```

 You must have the Azure CLI installed, and you will need to provide a parameters file for the `main.json` ARM template (the script expects this to be located at `output/main.parameters.json` by default).

 As part of this deployment you will need to decide which payment provider you are going to use - [Stripe](https://stripe.com/) or [Adyen](https://www.adyen.com/).

## Additional Steps

### Publishing the APIM Developer Portal

The example makes use of the hosted [APIM Developer Portal](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-developer-portal-customize), but there is a manual step required to publish this to make this visible to customers. Follow the steps in the [Publish the portal](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-developer-portal-customize#publish) section to do this.

### Stripe

If you are using [Stripe](documentation/Stripe.md), you will need to run the [Stripe Initialization script](../apim-monetization/payment/stripeInitialisation.ps1). This will set up the products and prices within your Stripe account.

## Running the build script

If you want to make modifications to the infrastructure templates, you will need to run a build script in order to generate a new ARM template output for deployment. Run the `build.ps1` PowerShell script at the root of the repo.

The build script executes the following steps:

1. Installs the Bicep CLI into the `build` folder
2. Transpiles the `main.bicep` template into a single `main.json` ARM template in the `output` folder

## Running the billing portal app locally

If you are making changes to the billing portal app and want to run the app locally, you will need to do the following:
- Deploy an instance of the APIM infrastructure (following the instructions in [Deploying the example](#deploying-the-example))
- Make a copy of `.env.sample` in `/app`, rename to `.env` and fill in the variables as per your environment
- Use a tunneling app such as [ngrok](https://ngrok.com/) to create a public URL that is forwarding port 8080
- Update the APIM delegation URL via the Azure Portal to point to `<public-forwarded-url>/apim-delegation`
- If you are using Stripe, you will need to update the Stripe webhook endpoint URL to `<public-forwarded-url>/webhook/stripe`
- If you are using Adyen, you will need to update the allowed origins to include `<public-forwarded-url>`
- Run `npm run dev` from the `/app` folder to start the app
- If running from VS Code, to enable debugging, open the command palette, select 'Debug: Toggle Auto Attach' and set to 'Smart'

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.