# How to implement monetization with Azure API Management and Stripe

In this example we have created an API monetization model which consists of a pricing model and a revenue model, and demonstrates how these can be implemented by integrating Azure API Management (APIM) with Stripe.

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

In order to share these models between APIM and Stripe, they have been defined in the monetization models configuration file [payment/monetizationModels.json](../payment/monetizationModels.json).

## Azure API Management Products 

APIM is configured to create Products that mirror the revenue model (Free, Developer, PAYG, Basic, Standard, Pro, Enterprise). This allows API Consumers to browse, select a product and subscribe to it, all via the Development Portal.

## Stripe 

[Stripe](https://stripe.com/) is a technology company that builds economic infrastructure for the internet. It provies a fully featured payment platform, which enables you, as an "API Producer", to monetize your APIs hosted in Azure API Management (APIM) to "API Consumers". 

Both APIM and Stripe define the concept of products and subscriptions, but only Stripe has the notion of pricing.

In Stripe you can define one or more associated prices against a product. For recurring prices (billed more than once) these prices can be `Licensed` or `Metered`:

- A `Licensed` price will be billed automatically at the given interval (in the example it is set to monthly). 
- A `Metered` price will calculate the cost per month based on usage records and the set price per unit.

## Combining APIM and Stripe to implement automatic billing

Implement of the monetization model requires APIM Product Policies and Stripe Product Configuration to be implemented and connected to deliver the end-to-end API Consumer experience:

| Revenue Model | Monetization Model | Azure API Management Product Policies                                                                       | Stripe Product Configuration                                                                                                                                               |
|---------------|--------------------|-------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Free          | Free               | Quota set to limit the Consumer to 100 calls / month                                                        | Not implemented.                                                                                                                                                           |
| Developer     | Freemium           | No quota set - Consumer can continue to make & pay for calls, rate limit of 100 calls / minute              | `Metered`, graduated tiers, where the first tier flat amount is $0, next tiers per unit amount charge set to charge $0.20 / 100 calls                                      |
| PAYG          | Metered            | No quota set - Consumer can continue to make & pay for calls, rate limit of 200 calls / minute              | `Metered` price set to charge Consumer $0.15 / 100 calls                                                                                                                   |
| Basic         | Tier               | Quota set to limit the Consumer to 50,000 calls / month, rate limit of 100 calls / minute                   | `Licensed` price set to charge Consumer $14.95 / month                                                                                                                     |
| Standard      | Tier + Overage     | No quota set - Consumer can continue to make & pay for additional calls, rate limit of 100 calls / minute   | `Metered`, graduated tiers, where the first tier flat amount is $89.95 / month for first 100,000 calls, next tiers per unit amount charge set to charge $0.10 / 100 calls  |
| Pro           | Tier + Overage     | No quota set - Consumer can continue to make & pay for additional calls, rate limit of 1,200 calls / minute | `Metered`, graduated tiers, where the first tier flat amount is $449.95 / month for first 500,000 calls, next tiers per unit amount charge set to charge $0.06 / 100 calls |
| Enterprise    | Unit               | No quota set - Consumer can continue to make & pay for additional calls, rate limit of 3,500 calls / minute | `Metered`, graduated tiers, where every tier flat amount is $749.95 / month for 1,500,000 calls                                                                            |

## Architecture

![](./architecture-stripe.png)

## API Consumer flow

The Consumer flow is as follows:

1. Consumer selects sign up in the APIM developer portal.
2. Consumer is redirected to the billing portal app to register their account (via [APIM delegation](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-setup-delegation)).
3. Consumer is redirected back to the APIM developer portal, authenticated.
4. Consumer selects a product to subscribe to in the APIM developer portal.
5. Consumer is redirected to the billing portal app (via [APIM delegation](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-setup-delegation)).
6. Consumer inputs a display name for their subscription and selects checkout.
7. Stripe checkout session is started, using the product definition to retrieve the prices for that product.
8. Consumer inputs credit card details into Stripe checkout session.
9. If checkout is successful, the APIM subscription is created and enabled.
10. Consumer is billed monthly based on product they have signed up for and usage.
11. If payment fails, subscription is suspended.

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

### Stripe checkout session *(Step 7, 8)*

From the checkout page, we use a [checkout sesion API](../app/src/routes/stripe.ts), which is defined within the application, to [create a new Stripe checkout session](https://stripe.com/docs/api/checkout/sessions).

Into this API, we pass the ID of the APIM user and the APIM product that the Consumer wants to activate, and the URL to return to on completion of checkout.

Using the name of the product, we retrieve the list of prices that are linked to that product within Stripe using the [Stripe Node SDK](https://stripe.com/docs/api?lang=node).

We also use the monetization model API to retrieve the product type that the Consumer has signed up for using the name of the product (this will be `Freemium`, `Metered`, `Tier`, `TierWithOverage`, `Unit`, or `MeteredUnit`).

We then create a Stripe checkout session using following parameters:

- Success url: the URL to redirect to if the checkout is successful (hosted within the web application)
- Cancel url: the URL to redirect to if the checkout is cancelled (also hosted within the application)
- Payment method types: Here we are just using "card"
- Mode: This is set to "subscription" which means that the Consumer will be charged on a recurring basis
- Metadata: Here we pass the APIM user ID, APIM product ID, and the subscription name. We can retrieve this metadata in the event that is raised when the Stripe subscription is created, so we can then use this within our event listener to create the associated APIM subscription.
- Line items: Here we need to set up a line item for the price associated with the product.

We then return the session ID from our API.

Back in the checkout view, we now use the `stripe.redirectToCheckout` function to redirect the Consumer to the checkout session. They will then be asked to enter their card details and authorise monthly payment (either at a set price, based on usage).

Once complete, the Consumer is redirected to the success URL passed into the stripe checkout session.

### APIM Subscription created *(Step 9)*

When a checkout session is successfully completed and a Stripe subscription is created, a `customer.subscription.created` event is raised within Stripe. As part of our Stripe initialisation, we defined a webhook which can be used to listen for these events. 

Within our web application, we have then added a [listener for these events](../app/src/routes/stripe.ts).

The event data which is attached to these events contains all the data defined on the `StripeCheckoutSession`. Therefore, when a new event is raised, we can retrieve the metadta which was attached to the checkout session. When we were setting up the session, we set this as the APIM user ID, APIM product ID, and the subscription name.

Therefore, within the listener, we can now create the APIM subscription via the API Management Service Management API. Here the web app authenticates to the APIM management API using a service principal, with the credentials for that principal available via the app settings. 

The subscription that the Consumer has paid for will then be created, and they will be able to start using their API keys to access the APIs which that subscription provides them access to.

### Billing *(Step 10)*

For products using non-metered prices, Stripe will automatically charge the Consumer each billing period by their fixed amount.

For metered prices, we need to [report the Consumer's usage to Stripe](https://stripe.com/docs/billing/subscriptions/metered-billing#reporting-usage) so that Stripe can calculate the amount to charge. The logic for doing this is in the [StripeBillingService](../app/src/services/stripeBillingService.ts).

To do this, we register a daily cron job which runs a function for querying usage from APIM using the APIM Management API, and then posts the number of units of usage to Stripe. At the end of each billing period, Stripe will automatically calculate the amount to charge based on the reported usage.

### Subscription suspended *(Step 11)*

The webhook listener also listens for `customer.subscription.updated` and `customer.subscription.deleted` events. If the subscription is cancelled or moves into an unpaid state, we update the APIM subscription into a suspended state so that the Consumer can no longer access our APIs.