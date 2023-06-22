import express from "express";
import crypto from "crypto";
import querystring from "querystring";
import { ApimService } from "../services/apimService";
import { BillingService } from "../services/billingService";

export const register = (app: express.Application, billingService: BillingService) => {
    const apimService = new ApimService();

    /** Delegated sign up/in, sign out and subscription creation for APIM */
    app.get("/apim-delegation", async (req, res) => {
        const operation = req.query.operation as string;
        const errorMessage = req.query.errorMessage as string;

        let isValid: boolean;
        switch (operation) {
            case "Subscribe":
                const subscribeRequest: SubscriptionRequest = {
                    operation,
                    productId: req.query.productId as string,
                    userId: req.query.userId as string,
                    salt: req.query.salt as string,
                    sig: req.query.sig as string,
                };

                isValid = validateSubscribeRequest(subscribeRequest);

                if (!isValid) {
                    res.status(401);
                    return;
                }

                const product = await apimService.getProduct(subscribeRequest.productId);

                res.render("subscribe", { subscribeRequest, product, title: "Subscribe" });
                break;
            case "Unsubscribe":
                const unsubscribeRequest: SubscriptionRequest = {
                    operation,
                    subscriptionId: req.query.subscriptionId as string,
                    salt: req.query.salt as string,
                    sig: req.query.sig as string,
                };

                isValid = validateUnsubscribeRequest(unsubscribeRequest);

                if (!isValid) {
                    res.status(401);
                    return;
                }

                await apimService.updateSubscriptionState(unsubscribeRequest.subscriptionId, "cancelled");
                await billingService.unsubscribe(unsubscribeRequest.subscriptionId);

                res.render("unsubscribe", { unsubscribeRequest, title: "Unsubscribe" });
            case "SignUp":
            case "SignIn":
            case "SignOut":
            case "ChangePassword":
            case "ChangeProfile":
            case "CloseAccount":
            case "Renew":
                // Not implemented
                res.status(501);
                break;
            default:
                res.status(400);
                break;
        }
    });

    /** Create a subscription for the user. This includes validating the request, retrieving the user, and redirecting them to checkout. On successful checkout, the subscription will be created. */
    app.post("/subscribe", async (req, res) => {
        const subscribeRequest: SubscriptionRequest = {
            operation: req.body.operation as string,
            productId: req.body.productId as string,
            userId: req.body.userId as string,
            salt: req.body.salt as string,
            sig: req.body.sig as string,
        };

        const isValid = validateSubscribeRequest(subscribeRequest);

        if (!isValid) {
            res.status(401);
            return;
        }

        const subscriptionName = req.body.subscriptionName as string;

        const user = await apimService.getUser(subscribeRequest.userId);

        const redirectQuery = querystring.stringify({
            operation: subscribeRequest.operation,
            userId: subscribeRequest.userId,
            productId: subscribeRequest.productId,
            subscriptionName,
            salt: subscribeRequest.salt,
            sig: subscribeRequest.sig,
            userEmail: user.email
        });

        res.redirect("/checkout?" + redirectQuery);
    });

    /** Checkout, using redirect to specific payment provider view */
    app.get("/checkout", async (req, res) => {
        const operation = req.query.operation as string;
        const userId = req.query.userId as string;
        const productId = req.query.productId as string;
        const subscriptionName = req.query.subscriptionName as string;
        const salt = req.query.salt as string;
        const sig = req.query.sig as string;
        const userEmail = req.query.userEmail as string;

        const subscribeRequest: SubscriptionRequest = {
            operation,
            productId,
            userId,
            salt,
            sig
        }

        const isValid = validateSubscribeRequest(subscribeRequest);

        if (!isValid) {
            res.status(401);
            return;
        }

        res.render(`checkout-${process.env.PAYMENT_PROVIDER.toLowerCase()}`, { subscribeRequest, subscriptionName, userEmail, title: "Checkout" });
    });

    app.get("/success", (req, res) => {
        res.render("success", { title: 'Payment Succeeded' });
    });

    app.get("/fail", (req, res) => {
        const subscribeRequest: SubscriptionRequest = {
            operation: req.query.operation as string,
            productId: req.query.productId as string,
            userId: req.query.userId as string,
            salt: req.query.salt as string,
            sig: req.query.sig as string,
        };

        const subscriptionName = req.query.subscriptionName as string;
        const userEmail = req.query.userEmail as string;

        const checkoutQuery = querystring.stringify({
            operation: subscribeRequest.operation,
            userId: subscribeRequest.userId,
            productId: subscribeRequest.productId,
            salt: subscribeRequest.salt,
            sig: subscribeRequest.sig,
            subscriptionName,
            userEmail
        });

        const checkoutUrl = "/checkout?" + checkoutQuery;

        res.render("fail", { title: 'Payment Failed', checkoutUrl });
    });

    /** Checkout cancelled, redirect to payment cancelled view */
    app.get("/cancel", (req, res) => {
        const subscribeRequest: SubscriptionRequest = {
            operation: req.query.operation as string,
            productId: req.query.productId as string,
            userId: req.query.userId as string,
            salt: req.query.salt as string,
            sig: req.query.sig as string,
        };

        const subscriptionName = req.query.subscriptionName as string;
        const userEmail = req.query.userEmail as string;

        const checkoutQuery = querystring.stringify({
            operation: subscribeRequest.operation,
            userId: subscribeRequest.userId,
            productId: subscribeRequest.productId,
            salt: subscribeRequest.salt,
            sig: subscribeRequest.sig,
            subscriptionName,
            userEmail
        });

        const checkoutUrl = "/checkout?" + checkoutQuery;

        res.render("cancel", { title: 'Payment Cancelled', checkoutUrl });
    });
}

function validateSubscribeRequest(subscriptionRequest: SubscriptionRequest): boolean {
    return validateRequest([subscriptionRequest.salt, subscriptionRequest.productId, subscriptionRequest.userId], subscriptionRequest.sig)
}

function validateUnsubscribeRequest(subscriptionRequest: SubscriptionRequest): boolean {
    return validateRequest([subscriptionRequest.salt, subscriptionRequest.subscriptionId], subscriptionRequest.sig)
}

function validateRequest(queryParams: string[], expectedSignature: string): boolean {
    const key = process.env.APIM_DELEGATION_VALIDATION_KEY;
    const hmac = crypto.createHmac('sha512', Buffer.from(key, 'base64'));

    const input = queryParams.join('\n');
    const digest = hmac.update(input).digest();

    const calculatedSignature = digest.toString('base64');

    return calculatedSignature === expectedSignature;
}

interface SubscriptionRequest {
    operation: string;
    productId?: string;
    subscriptionId?: string;
    userId?: string;
    salt: string;
    sig: string;
}