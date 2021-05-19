import * as express from "express";
import * as apimDelegationRoutes from "./apim-delegation";
import * as stripeRoutes from "./stripe";
import * as adyenRoutes from "./adyen";
import { BillingService } from "../services/billingService";
import { AdyenBillingService } from "../services/adyenBillingService";
import { StripeBillingService } from "../services/stripeBillingService";

export const register = (app: express.Application) => {

    const paymentProvider = process.env.PAYMENT_PROVIDER

    let billingService: BillingService;

    // Register the adyen specific routes
    if (paymentProvider === "Adyen") {
        adyenRoutes.register(app);
        billingService = new AdyenBillingService();
    }

    // Register the Stripe specific routes
    if (paymentProvider === "Stripe") {
        stripeRoutes.register(app);
        billingService = new StripeBillingService();
    }

    apimDelegationRoutes.register(app, billingService);
};