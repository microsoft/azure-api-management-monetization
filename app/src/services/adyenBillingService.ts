import { ApimService } from "./apimService";
import { CheckoutAPI, Client, Config } from "@adyen/api-library";
import { MonetizationService } from "./monetizationService";
import { BillingService } from "./billingService";

export interface Invoice {
    amount: number,
    subscriptionId: string,
    userId: string,
    month: number,
    year: number,
    currency: string
}

// Contains functionality relating to Adyen billing - invoices and taking payment via users' saved payment methods
export class AdyenBillingService implements BillingService {
    public async unsubscribe(apimSubscriptionId: string) {
        // We only charge for active subscriptions, so not necessary to update any state here.
        // You can add logic in here to e.g. bill the customer for a pro-rated month, or remove their saved payment details
    }

    // From the usage, calculate the invoices for all subscriptions for the past month
    public static async calculateInvoices(month: number, year: number): Promise<Invoice[]> {
        const startDate = new Date(year, month, 1);
        let endDate = new Date(startDate);
        endDate = new Date(endDate.setMonth(startDate.getMonth() + 1));

        const invoices: Invoice[] = []

        const apimService = new ApimService();
        const subscriptions = await apimService.getSubscriptions();

        await Promise.all(subscriptions.filter(sub => sub.state === "active").map(async sub => {
            // Retrieve the usage report for the period from APIM
            const usageReport = await apimService.getUsage(sub.name, endDate, startDate);

            const subscriptionId = sub.name;
            const userId = sub.ownerId.replace('/users/', '');

            // Retrieve the product, which is stored in the scope of the subscription
            const product = await apimService.getProduct(sub.scope.split("/").slice(-1)[0]);

            if (product) {
                const monetizationModel = await MonetizationService.getMonetizationModelFromProduct(product);

                if (monetizationModel) {
                    let amount: number;
                    let currency: string;

                    let invoice: Invoice;

                    if (usageReport) {
                        const usageUnits = usageReport.callCountTotal / 100;

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

                        invoice = {
                            amount,
                            month,
                            year,
                            subscriptionId,
                            userId,
                            currency: currency.toUpperCase()
                        }
                    }
                    else {
                        invoice = {
                            amount: 0,
                            month,
                            year,
                            subscriptionId: sub.name,
                            userId,
                            currency: currency.toUpperCase()
                        }
                    }

                    invoices.push(invoice);
                }
            }
        }));

        return invoices;
    }

    // Use Adyen and the consumer's stored card details to take payment for an invoice
    public static async takePaymentFromUser(invoice: Invoice) {
        const checkout = this.GetAdyenCheckout();

        const apimService = new ApimService();

        if (invoice.amount > 0) {
            // Retrieve the stored card details for the subscription
            const paymentMethodsResponse = await checkout.paymentMethods(
                {
                    merchantAccount: process.env.ADYEN_MERCHANT_ACCOUNT,
                    countryCode: "GB",
                    shopperLocale: "en-GB",
                    shopperReference: invoice.userId,
                    amount: {
                        currency: invoice.currency,
                        value: invoice.amount
                    }
                })
            if (paymentMethodsResponse.storedPaymentMethods) {
                // Create a new payment using the stored method, for the amount on the invoice
                const paymentResponse = await checkout.payments({
                    amount: { currency: invoice.currency, value: invoice.amount },
                    paymentMethod: {
                        type: 'scheme',
                        storedPaymentMethodId: paymentMethodsResponse.storedPaymentMethods[0].id
                    },
                    reference: `${invoice.subscriptionId}-${invoice.month}-${invoice.year}`,
                    merchantAccount: process.env.ADYEN_MERCHANT_ACCOUNT,
                    shopperInteraction: "ContAuth",
                    shopperReference: invoice.userId,
                    recurringProcessingModel: "CardOnFile",
                    returnUrl: "/"
                })

                // If there is an error in payment, deactivate the subscription
                if (paymentResponse.resultCode === "Error" || paymentResponse.resultCode === "Cancelled" || paymentResponse.resultCode === "Refused") {
                    await apimService.updateSubscriptionState(invoice.subscriptionId, 'suspended');
                }
            } else {
                // If there are no stored payment details for the subscription, deactivate it
                await apimService.updateSubscriptionState(invoice.subscriptionId, 'suspended');
            }

        }
    }

    // Retrieve Adyen checkout API access client
    public static GetAdyenCheckout() {
        const config = new Config();
        // Set your X-API-KEY with the API key from the Customer Area.
        config.apiKey = process.env.ADYEN_API_KEY;
        config.merchantAccount = process.env.ADYEN_MERCHANT_ACCOUNT;
        const client = new Client({ config });
        client.setEnvironment("TEST");
        const checkout = new CheckoutAPI(client);
        return checkout;
    }
}