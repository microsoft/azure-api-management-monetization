import * as express from "express";
import { ApimProductIdKey, ApimSubscriptionIdKey, ApimSubscriptionNameKey, ApimUserIdKey } from "../constants"
import Stripe from 'stripe';
import { ApimService } from "../services/apimService";
import querystring from "querystring";
import { MonetizationService } from "../services/monetizationService";

export const register = (app: express.Application) => {

    /** Create a new Stripe checkout session for the user */
    app.post(`/api/checkout/session`, async (req: any, res) => {
        const userEmail = req.body.userEmail;
        const apimUserId = req.body.apimUserId;
        const apimProductId = req.body.apimProductId;
        const apimSubscriptionName = req.body.apimSubscriptionName;
        const returnUrlBase = req.body.returnUrlBase
        const salt = req.body.salt
        const sig = req.body.sig
        const operation = req.body.operation

        // Get the APIM products
        const apimService = new ApimService();
        const apimProduct = await apimService.getProduct(apimProductId);

        // Get the monetization model relating to that product
        const monetizationModel = await MonetizationService.getMonetizationModelFromProduct(apimProduct);

        const stripe = new Stripe(process.env.STRIPE_API_KEY, {
            apiVersion: '2020-08-27',
        });


        // List the prices for that product in Stripe
        const prices = (await stripe.prices.list({ product: apimProduct.name, active: true })).data;

        const pricingModelType = monetizationModel.pricingModelType;

        const cancelUrlQuery = querystring.stringify({
            operation,
            userId: apimUserId,
            productId: apimProductId,
            subscriptionName: apimSubscriptionName,
            salt,
            sig,
            userEmail
        });

        const cancelUrl = returnUrlBase + "/cancel?" + cancelUrlQuery;
        const successUrl = returnUrlBase + "/success";

        const session: Stripe.Checkout.Session = await createCheckoutSession(userEmail, cancelUrl, successUrl, apimUserId, apimProductId, apimSubscriptionName, prices[0], pricingModelType, stripe);

        res.json({ id: session.id });
    });

    /** Listens for Stripe events for successful subscription creation, update or deletion */
    app.post(
        '/webhook/stripe',
        // Stripe requires the raw body to construct the event
        express.raw({ type: 'application/json' }),
        async (req: express.Request, res: express.Response): Promise<void> => {
            const stripe = new Stripe(process.env.STRIPE_API_KEY, {
                apiVersion: '2020-08-27',
            });

            const sig = req.headers['stripe-signature'];

            let event: Stripe.Event;

            try {
                event = stripe.webhooks.constructEvent(req.body, sig, process.env.STRIPE_WEBHOOK_SECRET);
            } catch (err) {
                // On error, log and return the error message
                // tslint:disable-next-line:no-console
                console.log(`Error message: ${err.message}`);
                res.status(400).send(`Webhook Error: ${err.message}`);
                return;
            }

            // Successfully constructed event
            // tslint:disable-next-line:no-console
            console.log('✅ Success:', event.id);

            let stripeSubscription : Stripe.Subscription;

            switch (event.type) {
                case 'customer.subscription.created':
                    // Create a new APIM subscription for the user when checkout is successful
                    stripeSubscription = event.data.object as Stripe.Subscription;

                    const apimProductId = stripeSubscription.metadata[ApimProductIdKey];
                    const apimUserId = stripeSubscription.metadata[ApimUserIdKey];
                    const apimSubscriptionName = stripeSubscription.metadata[ApimSubscriptionNameKey];

                    const createSubscriptionResponse = await createApimSubscription(stripeSubscription.id, apimUserId, apimProductId, apimSubscriptionName);

                    // Add APIM subscription ID to Stripe subscription metadata
                    stripe.subscriptions.update(stripeSubscription.id, { metadata: {[ApimSubscriptionIdKey]: createSubscriptionResponse.name }})

                    break;

                case 'customer.subscription.updated':
                case 'customer.subscription.deleted':
                    // Deactivate APIM subscription if Stripe subscription is updated / deleted (as payment may no longer be valid)
                    stripeSubscription = event.data.object as Stripe.Subscription;

                    if (stripeSubscription.status === 'canceled' || stripeSubscription.status === 'unpaid'){
                        const apimSubscriptionId = stripeSubscription.metadata[ApimSubscriptionIdKey];

                        await deactivateApimSubscription(apimSubscriptionId);
                    }

                    break;

                default:
                    // tslint:disable-next-line:no-console
                    console.warn(`Unhandled event type: ${event.type}`);
                    break;
            }

            // Return a response to acknowledge receipt of the event
            res.json({ received: true });
        }
    );
};

async function createCheckoutSession(
    userEmail: string,
    cancelUrl: string,
    successUrl: string,
    apimUserId: string,
    apimProductId: string,
    apimSubscriptionName: string,
    price: Stripe.Price,
    pricingModelType: string,
    stripe: Stripe
) {
    let session: Stripe.Checkout.Session;

    const createSessionParameters: Stripe.Checkout.SessionCreateParams = {
        cancel_url: cancelUrl,
        success_url: successUrl,
        payment_method_types: ["card"],
        mode: 'subscription',
        customer_email: userEmail,
        subscription_data: {
            metadata: {
                [ApimUserIdKey]: apimUserId,
                [ApimProductIdKey]: apimProductId,
                [ApimSubscriptionNameKey]: apimSubscriptionName
            }
        }
    };

    let lineItems: Stripe.Checkout.SessionCreateParams.LineItem[];

    switch (pricingModelType) {
        case "Tier":
            lineItems = [
                { price: price.id, quantity: 1 }
            ];
            break;
        default:
            lineItems = [
                { price: price.id }
            ];
            break;
    }

    createSessionParameters.line_items = lineItems;
    session = await stripe.checkout.sessions.create(createSessionParameters);

    return session;
}

async function createApimSubscription(apimSubscriptionId: string, apimUserId: string, apimProductId: string, apimSubscriptionName: string) {
    const apimService = new ApimService();
    return await apimService.createSubscription(apimSubscriptionId, apimUserId, apimProductId, apimSubscriptionName);
}

async function deactivateApimSubscription(apimSubscriptionId: string) {
    const apimService = new ApimService();
    const subscription = await apimService.getSubscription(apimSubscriptionId);

    if (subscription.state === "active" || subscription.state === "submitted") {
        await apimService.updateSubscriptionState(apimSubscriptionId, 'suspended');
    }
}