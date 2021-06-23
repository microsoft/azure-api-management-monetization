# How to implement monetization with Azure API Management and Adyen

In this example we have created an API monetization model which consists of a pricing model and a revenue model, and demonstrates how these can be implemented by integrating Azure API Management (APIM) with Adyen.

The pricing model describes the different strategies the API Provider can use to provide access to the API Consumer:

- `Free` - enables the API Consumer to trial the API in an obligation and cost free way, to determine whether it fulfils a use case. This removes all barriers to entry.
- `Freemium` - allows the API Consumer to use the API for free, but to transition into a paid for service as demand increases.
- `Metered` - the API Consumer can make as many calls as they want per month, and will pay a fixed amount per call.
- `Tier` - the API Consumer pays for a set amount of calls per month, they cannot exceed this limit.
- `Tier + Overage` - the API Consumer pays for a set amount of calls per month, and if they exceed this limit they pay an overage amount per additional call. If they regularly incur overage, it may be more economic to upgrade to the next tier.
- `Unit` - the API Consumer pays for a set amount of call per month. If they exceed this limit they have to pay for another unit of calls.

The revenue model describes how we can create products, which implement a specific monetization model, targeted at a specific API Consumer scenario:

- `Free` - this implements the `Free` pricing model and enables the API Consumer to **investigate** your product.
- `Developer` - this implements the `Freemium` pricing model and enables the API Consumer to **implement** your product.
- `PAYG` - this implements the `Metered` pricing model and enables the API Consumer to **preview** their offering and understand initial demand.
- `Basic` - this implements the `Tier` pricing model and enables the API Consumer's **initial production usage**.
- `Standard` - this implements the `Tier + Overage` pricing model and supports the API Consumer's **initial growth**.
- `Pro`  - this implements the `Tier + Overage` pricing model and supports the API Consumer's **scale** requirements.
- `Enterprise` - this implements the `Unit` pricing model and supports the API Consumer's **global growth** requirements.

In order to share these models between APIM and Adyen, they have been defined in the monetization models configuration file [payment/monetizationModels.json](../payment/monetizationModels.json).

## Azure API Management Products 

APIM is configured to create Products that mirror the revenue model (Free, Developer, PAYG, Basic, Standard, Pro, Enterprise). This allows API Consumers to browse, select a product and subscribe to it, all via the Development Portal.

## Adyen 

[Adyen](https://adyen.com/) is a payment provider which allows you to securely take payment from consumers.

Adyen allows you to [tokenize](https://docs.adyen.com/online-payments/tokenization) a consumer's card details so that they can be securely stored (by Adyen) and used to authorize recurring transactions.

## Architecture

![](./architecture-adyen.png)

## API Consumer flow

The Consumer flow is as follows:

1. Consumer selects sign up in the APIM developer portal.
2. Consumer is redirected to the billing portal app to register their account (via [APIM delegation](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-setup-delegation)).
3. Consumer is redirected back to the APIM developer portal, authenticated.
4. Consumer selects a product to subscribe to in the APIM developer portal.
5. Consumer is redirected to the billing portal app (via [APIM delegation](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-setup-delegation)).
6. Consumer inputs a display name for their subscription and selects checkout.
7. Consumer is redirected to an embedded Adyen checkout page where they enter their payment details
8. Payment details are saved by Adyen
9. Consumer's APIM subscription is created
10. Each month the usage is used to calculate the invoice, which is then charged to the consumer's card

### Consumer registers an account *(Step 1, 2, 3)*

From the APIM developer portal (defined for your APIM account), consumers can browse APIs and products. 

The developer portal for an APIM service is located at:

`https://{ApimServiceName}.developer.azure-api.net`

However, they cannot create a product subscription until they have created a user account.

On selecting 'Sign Up', the user is redirected to the billing portal app where they can enter their details to create an account. This is handled via [user registration delegation](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-setup-delegation#-delegating-developer-sign-in-and-sign-up).

On successful account creation, the consumer is redirected to the APIM developer portal, authenticated.

Once an account has been created, in future the consumer can just sign in to the account.

### Consumer subscribes to APIM product and retrieves API keys *(Step 4, 5)*

From the APIM developer portal, consumers can browse products.

From here, a consumer can select a product to create a new subscription. They will be redirected to the billing portal app when they select 'Subscribe'. This is handled via [product subscription delegation](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-setup-delegation#-delegating-product-subscription).

### Billing portal *(Step 5, 6)*

Once redirected to the billing portal, the consumer can enter a display name for their subscription and select 'Checkout', where they will be redirected to the checkout page.

### Adyen checkout *(Step 7, 8)*

Once they have selected the subscription they wish to activate, the consumer is redirected to the [Adyen checkout page](../app/src/views/checkout-adyen.ejs). This page uses an Adyen plugin to collect the consumer's payment details. 

When the card details are confirmed, the request is sent through to the [API for initiating payments](../app/src/routes/adyen.ts). Here we create a 0-amount payment for the consumer, passing in a flag to store the payment method and keep the card on file. We also pass the APIM user ID as the shopper reference, and a combination of the APIM user ID, APIM product ID and subscription name as payment reference.

We will then be able to use the saved card details for future transactions related to this subscription.

### APIM Subscription created *(Step 9)*

Once the consumer's payment details have been successfully tokenized, we create their APIM subscription so that they are now able to use their API keys to access the APIs provided under the product they signed up for. This is done as part of the same API call, so there is no need for a callback / webhook as is necessary with the [Stripe](Stripe.md) implementation.

### Billing *(Step 10)*

On the 1st of each month, a [CRON job](https://www.npmjs.com/package/node-cron) is run which calculates the invoices for all the APIM subscriptions, and charges the consumer's cards.

The job is defined in the main [index.ts file](../app/src/index.ts) for the app. This calls into the [calculateInvoices method on the AdyenBillingService](../src/services/AdyenBillingService.ts) to calculate the invoices.

This method contains the logic for calculating the payment amount, using the product that the subscription is for, and the usage data from APIM.

The `UsageUnits` are calculated by dividing the total number of API calls by 100 (as our pricing model works in units of 100 calls).

Then the following logic is used to calculate the amount, based on the pricing model for the product:

```ts
 // Calculate the amount owing based on the pricing model and usage
  switch (monetizationModel.pricingModelType) {
      case "Free":
          amount = 0;
          currency = "";
          break;
      case "Freemium":
      case "TierWithOverage":
          // We floor this calculation as consumers only pay for full units used
          let usageOverage = Math.floor(usageUnits - monetizationModel.prices.unit.quota);

          if (usageOverage < 0) {
              usageOverage = 0;
          }

          amount = monetizationModel.prices.unit.unitAmount + usageOverage * monetizationModel.prices.metered.unitAmount;
          currency = monetizationModel.prices.metered.currency;
          break;
      case "Tier":
          amount = monetizationModel.prices.unit.unitAmount;
          currency = monetizationModel.prices.unit.currency;
          break;
      case "Metered":
          // We floor this calculation as consumers only pay for full units used
          amount = Math.floor(usageUnits) * monetizationModel.prices.metered.unitAmount;
          currency = monetizationModel.prices.metered.currency;
          break;
      case "Unit":
          // We ceiling this calculation as for "Unit" prices, you buy full units at a time
          let numberOfUnits = Math.ceil(usageUnits / monetizationModel.prices.unit.quota);

          // The minimum units that someone pays for is 1
          if (numberOfUnits <= 0) {
              numberOfUnits = 1;
          }

          amount = numberOfUnits * monetizationModel.prices.unit.unitAmount;
          currency = monetizationModel.prices.unit.currency;
          break;
      default:
          break;
  }
}

```

The invoices are then passed unto the `takePaymentViaAdyen` function. This uses the APIM user ID to retrieve the stored payment methods for the subscription. We then use the ID of the stored payment method to authorize a payment for the amount on the invoice.

### Subscription suspended *(Step 11)*

If the payment fails, we then put the APIM subscription into a suspended state.