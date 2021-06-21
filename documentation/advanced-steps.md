# Advanced steps

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