# Azure API Management - Monetization

## Purpose and scope

This is a **demo project** providing two working examples of how to integrate Azure API Management (APIM) with payment providers - one based on integration with [Stripe](https://stripe.com/), the other with [Adyen](https://www.adyen.com/).

The objective is to show how you can enable consumers to discover an API that you wish to make public, enter their payment details, activate their subscription and trigger automated payment based on their usage of the API.

To use this demo, you will need to deploy the solution into your own Azure subscription and to set up your own Stripe / Adyen account.  This is **not** a managed service - you will be responsible for managing the resources that are deployed on Azure, adapting the solution to meet your specific use case and keeping the solution up to date.

### Table of contents

| Document                                                                                                | Purpose 
|---------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------|
| [How to think about monetization](./documentation/how-to-think-about-monetization.md)                   | Makes recommendations about how to design a successful monetization strategy for your API.             |
| [How APIM supports monetization](./documentation/how-APIM-supports-monetization.md)                     | Provides an overview of the APIM features that can be used to accelerate and de-risk API monetization. |
| [How to implement monetization with Azure API Management and Stripe](./documentation/stripe-details.md) | Describes how the Stripe integration has been implemented and the user flow through the solution.      |
| [Deploy demo with Stripe](./documentation/stripe-deploy.md)                                             | End to end deployment steps to implement the demo project with Stripe as payment provider.             |
| [How to implement monetization with Azure API Management and Adyen](./documentation/adyen-details.md)   | Describes how the Adyen integration has been implemented and the user flow through the solution.       |
| [Deploy demo with Adyen](./documentation/adyen-deploy.md)                                               | End to end deployment steps to implement the demo project with Adyen as payment provider.              |
| [Deployment details](./documentation/deployment-details.md)                                             | Details the resources that are deployed and the approach taken to script the deployment.               |
| [Advanced steps](./documentation/advanced-steps.md)                                                     | Details of advanced steps to modify the infrastructure templates and run the billing app locally.      |

## Steps to follow

Follow these steps to implement the demo project:

1. Read [How to think about monetization](./documentation/how-to-think-about-monetization.md) to get background about designing a successful monetization strategy.

1. Read [How APIM supports monetization](./documentation/how-APIM-supports-monetization.md) to understand how APIM supports implementation of a monetization strategy.

1. Choose the payment provider you want to implement - either [Stripe](https://stripe.com/) or [Adyen](https://www.adyen.com/).

1. Read the overview: either [How to implement monetization with Azure API Management and Stripe](./documentation/stripe-details.md) or [How to implement monetization with Azure API Management and Adyen](./documentation/adyen-details.md) to understand more about Stripe / Adyen, how they integrate with APIM, the architecture adopted and the consumer flow through the solution.

1. Follow the deployment instructions in either [Deploy demo with Stripe](./documentation/stripe-deploy.md) or [Deploy demo with Adyen](./documentation/adyen-deploy.md) to set up the pre-requisites, deploy the resources onto Azure and complete remaining steps post deployment to implement the demo project.

1. Reference [Deployment details](./documentation/deployment-details.md) to get more detail about the resources that are being deployed and how this has been scripted.

1. Reference [Advanced steps](./documentation/advanced-steps.md) if you want to modify the infrastructure templates used by the billing app or run the billing app locally.

## Architecture

The following diagram illustrates the high level architecture this demo has adopted to integrate API Management with a payment provider:

![](documentation/architecture-overview.png)

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