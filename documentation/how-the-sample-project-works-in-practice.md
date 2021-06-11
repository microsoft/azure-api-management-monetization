# How the sample project works in practice

These steps in the API consumer flow are common to both Stripe and Adyen users.

1. Consumer selects sign up in the APIM developer portal.
2. Consumer is redirected to the billing portal app to register their account (via APIM delegation).
3. Consumer is redirected back to the APIM developer portal, authenticated.
4. Consumer selects a product to subscribe to in the APIM developer portal.
5. Consumer is redirected to the billing portal app (via APIM delegation).
6. Consumer inputs a display name for their subscription and selects checkout.
7. Consumer is redirected to payment page
8. On successful payment, subscription is created
9. Consumer navigates back to APIM developer portal

## Consumer registers an account *(Step 1, 2, 3)*

From the APIM developer portal (defined for your APIM account), consumers can browse APIs and products. 

The developer portal for an APIM service is located at:

`https://{ApimServiceName}.developer.azure-api.net`

However, they cannot create a product subscription until they have created a user account.

On selecting 'Sign Up', the user is redirected to the billing portal app where they can enter their details to create an account. This is handled via [user registration delegation](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-setup-delegation#-delegating-developer-sign-in-and-sign-up).

On successful account creation, the consumer is redirected to the APIM developer portal, authenticated.

Once an account has been created, in future the consumer can just sign in to the account.

## Consumer subscribes to APIM product and retrieves API keys *(Step 4, 5)*

From the APIM developer portal, consumers can browse products.

From here, a consumer can select a product to create a new subscription. They will be redirected to the billing portal app when they select 'Subscribe'. This is handled via [product subscription delegation](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-setup-delegation#-delegating-product-subscription).

## Billing portal *(Step 5, 6)*

Once redirected to the billing portal, the consumer can enter a display name for their subscription and select 'Checkout', where they will be redirected to the checkout page, which varies depending on the payment provider configured.

## Payment

The next steps in the process are defined seperately for [Stripe](Stripe.md) and for [Adyen](Adyen.md).