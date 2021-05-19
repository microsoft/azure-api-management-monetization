export interface BillingService {
    unsubscribe: (apimSubscriptionId: string) => Promise<void>;
}