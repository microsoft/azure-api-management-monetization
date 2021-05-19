import * as express from "express";
import { ApimService } from "../services/apimService";
import { env } from "shelljs";
import { AdyenBillingService } from "../services/adyenBillingService";
import { Guid } from "js-guid";

export const register = (app: express.Application) => {

  // Retrieve the available payment methods from Adyen for the merchant.
  app.post("/api/getPaymentMethods", async (req, res) => {
    try {
      const checkout = AdyenBillingService.GetAdyenCheckout();
      const response = await checkout.paymentMethods({
        channel: "Web",
        merchantAccount: env.ADYEN_MERCHANT_ACCOUNT,
      });
      res.json(response);
    } catch (err) {
      // tslint:disable-next-line:no-console
      console.error(`Error: ${err.message}, error code: ${err.errorCode}`);
      res.status(err.statusCode).json(err.message);
    }
  });

  // Save a user's card details for future payments
  app.post("/api/initiatePayment", async (req, res) => {
    try {
      const checkout = AdyenBillingService.GetAdyenCheckout();

      // Use the Adyen checkout API to create a 0-amount payment, and save the consumer's card details
      const response = await checkout.payments({
        amount: { currency: "USD", value: 0 },
        storePaymentMethod: true,
        shopperInteraction: "Ecommerce",
        recurringProcessingModel: "CardOnFile",
        reference: `${req.body.userId}_${req.body.productId}_${req.body.subscriptionName}`,
        merchantAccount: process.env.ADYEN_MERCHANT_ACCOUNT,
        returnUrl: req.body.returnUrl,
        paymentMethod: req.body.paymentMethod,
        shopperReference: req.body.userId
      });

      const apimUserId = req.body.userId;
      const apimProductId = req.body.productId;
      const apimSubscriptionName = req.body.subscriptionName;
      const apimService = new ApimService();

      // Create a new APIM subscription for the user
      await apimService.createSubscription(Guid.newGuid().toString(), apimUserId, apimProductId, apimSubscriptionName);

      res.json(response);
    } catch (err) {
      // tslint:disable-next-line:no-console
      console.error(`Error: ${err.message}, error code: ${err.errorCode}`);
      res.status(err.statusCode).json(err.message);
    }
  });

  // Used to submit additional payment details
  app.post("/api/submitAdditionalDetails", async (req, res) => {
    // Create the payload for submitting payment details
    const payload = {
      details: req.body.details,
      paymentData: req.body.paymentData,
    };

    try {
      const checkout = AdyenBillingService.GetAdyenCheckout();
      // Return the response back to client
      // (for further action handling or presenting result to shopper)
      const response = await checkout.paymentsDetails(payload);

      res.json(response);
    } catch (err) {
      // tslint:disable-next-line:no-console
      console.error(`Error: ${err.message}, error code: ${err.errorCode}`);
      res.status(err.statusCode).json(err.message);
    }
  });
};