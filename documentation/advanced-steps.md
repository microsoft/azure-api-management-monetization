# Advanced steps

This article takes you beyond initial Adyen or Stripe deployment and integration with API Management.

## Running the build script

To modify the infrastructure templates, you'll run a build script to generate a new Azure Resource Manager template output for deployment.

1. Run the `build.ps1` PowerShell script at the root of the repo.

1. The build script generates deployment scripts for all Azure resources required to support the demo project.
    * See the [deployment details](./deployment-details.md) for more details.

1. The build script executes the following steps:
    * Installs the Bicep CLI into the `build` folder.
    * Transpiles the `main.bicep` template into a single `main.json` Azure Resource Manager template in the `output` folder.

## Running the billing portal app locally

To modify the billing portal app and run the app locally:

1. Install [NodeJS](https://nodejs.org/en/download/) (version 20.10 or later).
1. Deploy an instance of the API Management infrastructure, following the instructions in either:
    * [Deploy with Stripe](./stripe-deploy.md), or
    * [Deploy with Adyen](./adyen-deploy.md) documents).
1. Make a copy of `.env.sample` in `/app`, rename to `.env`, and fill in the variables as per your environment.
1. Use a tunneling app such as [ngrok](https://ngrok.com/) to create a public URL forwarding port 8080. If using ngrok:
    * [Download ngrok](https://ngrok.com/download).
    * Unzip the executable.
    * From the command line, run the ngrok executable to start an HTTP tunnel, using port 8080: `./ngrok http 8080`.
    * Continue with the following steps, replacing `<public-forwarded-url>` with the output URL (for example, https://\<unique-value\>.ngrok.io).
1. Update the API Management delegation URL via the Azure portal to point to `<public-forwarded-url>/apim-delegation`.
    * For Stripe, update the Stripe webhook endpoint URL to `<public-forwarded-url>/webhook/stripe`.
    * For Adyen, update the allowed origins to include `<public-forwarded-url>`.
1. Run `npm run dev` from the `/app` folder to start the app.
1. If you're running from VS Code, enable debugging by:
    * Opening the command palette.
    * Selecting **Debug: Toggle Auto Attach**.
    * Setting to **Smart**.

## Re-building the docker image

If you make code changes to the custom billing portal app, you will need to:

1. Re-build the docker image from `app/Dockerfile`.
1. Publish the docker image to a publicly accessible container registry.
1. When deploying, set the value of the `appServiceContainerImage` parameter to the URL for your published container image.
