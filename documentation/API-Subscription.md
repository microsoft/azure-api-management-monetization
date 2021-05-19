# API Subscription

## Azure API Management Service

The [Azure API Management Service (APIM)](https://docs.microsoft.com/en-us/azure/api-management/) is a API management platform. Users of APIM can publish APIs, which consumers can then subscribe to. 

The APIs are published [via products](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-add-products). A product allows you to define which APIs a subscriber can access, and specific throttling [policies](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-policies) (to e.g. limit a specific subscription to a certain quota of calls per month).

When a consumer subscribes to a product, they are provided with an API key which they can use to make calls. However, the subscription is initially set to a `submitted` state, and needs to be activated before they will be able to use the APIs.

## Initialisation and deployment

The initialisation for the APIM service and billing portal is covered in the [initialisation guide](Initialisation.md).

## Monetization models

In our example we have defined three types of subscription:

- `Free` - enables the API Consumer to trial the API in an obligation and cost free way, to determine whether it fulfils a use case. This removes all barriers to entry.
- `Freemium` - allows the API Consumer to use the API for free, but to transition into a paid for service as demand increases.
- `Metered` - the API Consumer can make as many calls as they want per month, and will pay a fixed amount per call.
- `Tier` - the API Consumer pays for a set amount of calls per month, and if they exceed this limit they pay an overage amount per additional call. If they regularly incur overage, they have the option to upgrade to the next tier.
- `Tier + Overage` - the API Consumer pays for a set amount of calls per month, and if they exceed this limit they pay a set amount per additional call.
- `Unit` - the API Consumer pays for a set amount of call per month. If they exceed this limit they have to pay for another unit of calls.

In order to share these models between APIM, Adyen, and Stripe they have been defined in the monetization models configuration file [payment/monetizationModels.json](../payment/monetizationModels.json).

An example of `Tier` pricing is the Basic product, in which a consumer pays $14.95 / month and can make up to 50,000 calls.

An example of `Metered` pricing is the PAYG product, in which consumers are charged a flat rate of $0.15 / 100 calls. 

An example of `Tier + Overage` pricing is the Standard product, in which consumers are charged $89.95 / month for 100,000 calls. And are charged an additional $0.10 / 100 additional calls.

## Consumer flow

These steps in the consumer flow are common to both Stripe and Adyen users.

1. Consumer selects sign up in the APIM developer portal.
2. Consumer is redirected to the billing portal app to register their account (via APIM delegation).
3. Consumer is redirected back to the APIM developer portal, authenticated.
4. Consumer selects a product to subscribe to in the APIM developer portal.
5. Consumer is redirected to the billing portal app (via APIM delegation).
6. Consumer inputs a display name for their subscription and selects checkout.
7. Consumer is redirected to payment page
8. On successful payment, subscription is created
9. Consumer navigates back to APIM developer portal

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

Once redirected to the billing portal, the consumer can enter a display name for their subscription and select 'Checkout', where they will be redirected to the checkout page, which varies depending on the payment provider configured.

### Payment

The next steps in the process are defined seperately for [Stripe](Stripe.md) and for [Adyen](Adyen.md).