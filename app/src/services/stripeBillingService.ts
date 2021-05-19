import { LastUsageUpdateKey, ApimSubscriptionIdKey } from "../constants";
import Stripe from "stripe";
import { ApimService } from "./apimService";
import { BillingService } from "./billingService";

// Containing functionality relating to Stripe billing - updating usage records
export class StripeBillingService implements BillingService {

    // When unsubscribing from APIM product, we cancel the Stripe subscription to stop the consumer being billed.
    public async unsubscribe(apimSubscriptionId: string) {
        const stripe = new Stripe(process.env.STRIPE_API_KEY, {
            apiVersion: '2020-08-27',
        });

        let stripeSubscriptionListResponse: Stripe.Response<Stripe.ApiList<Stripe.Subscription>>;
        let startingAfter: string;
        let stripeSubscription: Stripe.Subscription
        do {
            stripeSubscriptionListResponse = await stripe.subscriptions.list({ starting_after: startingAfter });
            stripeSubscription = stripeSubscriptionListResponse.data.find(sub => sub.metadata[ApimSubscriptionIdKey] === apimSubscriptionId);
            startingAfter = stripeSubscriptionListResponse.data.slice(-1)[0].id;
        }
        while(!stripeSubscription && stripeSubscriptionListResponse.has_more);

        await stripe.subscriptions.del(stripeSubscription.id);
    }

    // Stripe automatically bills consumers monthly according to their usage. To support this, we report usage to Stripe throughout the month.
    public static async reportUsageToStripe(): Promise<number> {

        const apimService = new ApimService();
        const now = new Date();

        const stripe = new Stripe(process.env.STRIPE_API_KEY, {
            apiVersion: '2020-08-27',
        });

        let stripeSubscriptionListResponse: Stripe.Response<Stripe.ApiList<Stripe.Subscription>>;
        let startingAfter: string;

        do {
            stripeSubscriptionListResponse = await stripe.subscriptions.list({ starting_after: startingAfter });

            // For each Stripe subscription
            stripeSubscriptionListResponse.data.forEach(async stripeSubscription => {
                const subscriptionItem = stripeSubscription.items.data[0];

                // Find the subscriptions with a metered usage type, as these are the only ones which depend on usage
                if (subscriptionItem.price.recurring.usage_type !== "metered") {
                    return;
                }

                const apimSubscriptionId = stripeSubscription.metadata[ApimSubscriptionIdKey];

                if (!apimSubscriptionId) {
                    return;
                }

                const lastUsageUpdate = stripeSubscription.metadata[LastUsageUpdateKey];

                // Get all usage since the start of the current billing period.
                // Unless the last time we did a usage update was in the last period,
                // in which case we need to create an additional usage record for the usage between the previous update, and the start of this billing period
                // This is to ensure that no usage is missed

                const startofBillingPeriod = new Date(stripeSubscription.current_period_start * 1000);

                if (lastUsageUpdate) {
                    const lastUsageUpdateDate = new Date(lastUsageUpdate);
                    if (lastUsageUpdateDate < startofBillingPeriod) {
                        const priorUsageReport = await apimService.getUsage(apimSubscriptionId, startofBillingPeriod, lastUsageUpdateDate);

                        const totalPriorCalls = priorUsageReport.callCountTotal;
                        const priorUsageUnits = Math.floor(totalPriorCalls / 100); // We bill in units of 100 calls

                        if (priorUsageUnits !== 0) {
                            // Create a usage record in Stripe for the period between the previous usage record and the start of this billing period
                            await stripe.subscriptionItems.createUsageRecord(subscriptionItem.id, { quantity: priorUsageUnits, timestamp: stripeSubscription.current_period_start + 1, action: "set" });

                            // Update Stripe's record for when the usage was last updated to the start of the billing period
                            await stripe.subscriptions.update(stripeSubscription.id, { metadata: { [LastUsageUpdateKey]: startofBillingPeriod.toISOString() } });
                        }
                    }
                }

                // Retrieve the usage report for the start of the billing period to now
                const usageReport = await apimService.getUsage(apimSubscriptionId, now, startofBillingPeriod);

                const totalCalls = usageReport.callCountTotal;
                const usageUnits = Math.floor(totalCalls / 100); // We bill in units of 100 calls

                if (usageUnits === 0) {
                    return;
                }

                // Create a usage record in Stripe for the start of the billing period to now
                await stripe.subscriptionItems.createUsageRecord(subscriptionItem.id, { quantity: usageUnits, timestamp: stripeSubscription.current_period_start, action: "set" });

                // Update Stripe's record for when the usage was last updated to now
                await stripe.subscriptions.update(stripeSubscription.id, { metadata: { [LastUsageUpdateKey]: now.toISOString() } });

                startingAfter = stripeSubscription.id;
            });
        }
        while (stripeSubscriptionListResponse.has_more)

        return 0;
    }
}