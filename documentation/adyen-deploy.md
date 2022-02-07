# Deploy demo with Adyen

In this tutorial, you'll deploy the demo Adyen account and learn how to:

> [!div class="checklist"]
> * Set up an Adyen account, the required PowerShell and `az cli` tools, an Azure subscription, and a service principal on Azure. 
> * Deploy the Azure resources using either Azure portal or PowerShell.
> * Make your deployment visible to consumers by publishing the Azure developer portal.

## Pre-requisites

To prepare for this demo, you'll need to:

> [!div class="checklist"]
> * Create an Adyen test account. 
> * Install and set up the required PowerShell and Azure CLI tools.
> * Set up an Azure subscription.
> * Set up a service principal in Azure.

### [Create an Adyen test account](https://www.adyen.com/signup)

From within an Adyen test account:
1. Expand the **Accounts** tab on the pages panel on the left side of the Adyen test account homepage, select the **Merchant accounts** option.
1. If you do not have one already, create a **merchant account** for an **ecommerce sales channel**.

Three values should be copied from the Adyen test account that are required as input parameters during the deployment process:
1. Copy the **Merchant account name** which is the displayed in the top left corner of the Adyen test account homepage.
1. Expand the **Developers** tab on the pages panel on the left side of the Adyen test account homepage, select the **API Credentials** option.
1. Select the **ws** (Web Service) API.
1. Generate and copy an **API key** and copy the **Client key**.

After the deployment of the Azure resources (see below) has completed, you should return to the Adyen test account homepage to:
1. Expand the **Developers** tab on the pages panel on the left side of the Adyen test account homepage, select the **API Credentials** option.
1. Select the **ws** (Web Service) API.
1. Add a new origin to the list of allowed origins which is the URL of the App Service that has been deployed.

### Install and set up the required tools

- Version 7.1 or later of [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.1).
- Version 2.21.0 or later of [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).

### Set up an Azure subscription with admin access

For this sample project, you will need admin access in order to deploy all the included artifacts to Azure. If you do not have an Azure subscription, set up a [free trial](https://azure.microsoft.com/).

### Set up a service principal on Azure

For the solution to work, the Web App component needs a privileged credential on your Azure subscription with the scope to execute `read` operations on API Management (get products, subscriptions, etc.).

Before deploying the resources, set up the service principal in the Azure Active Directory (AAD) tenant used by the Web App to update the status of API Management subscriptions.

The simplest method is using the Azure CLI.

1. [Sign in with Azure CLI](https://docs.microsoft.com/cli/azure/authenticate-azure-cli#sign-in-interactively):

    ```azurecli-interactive
    az login
    ```
2. [Create an Azure service principal with the Azure CLI](https://docs.microsoft.com/cli/azure/create-an-azure-service-principal-azure-cli#password-based-authentication):

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
> For both options, when filling in parameters, leave the `stripe*` parameters blank.

### Azure portal

Click the button below to deploy the example to Azure and fill in the required parameters in the Azure portal.

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

This example project uses the hosted [API Management developer portal](https://docs.microsoft.com/azure/api-management/api-management-howto-developer-portal). 

You are required to complete a manual step to publish and make the resources visible to customers. See the [Publish the portal](https://docs.microsoft.com/azure/api-management/api-management-howto-developer-portal-customize#publish) for instructions.

## Next Steps
* Learn more about [deploying API Management monetization with Adyen](adyen-details.md).
* Learn about the [Stripe deployment](stripe-details.md) option.