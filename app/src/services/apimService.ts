import * as msRestNodeAuth from "@azure/ms-rest-nodeauth";
import { ApiManagementClient } from "@azure/arm-apimanagement";
import { ProductGetResponse, ProductListByServiceResponse, ReportRecordContract, SubscriptionCreateOrUpdateResponse, SubscriptionGetResponse, SubscriptionListResponse, SubscriptionState, UserCreateOrUpdateResponse, UserGetResponse, UserGetSharedAccessTokenResponse } from "@azure/arm-apimanagement/esm/models";
import { Utils } from "../utils";
import fetch from "node-fetch";
import { Guid } from 'js-guid';

export class ApimService {

    initialized = false;
    managementClient: ApiManagementClient;

    subscriptionId : string = process.env.APIM_SERVICE_AZURE_SUBSCRIPTION_ID;
    resourceGroupName : string = process.env.APIM_SERVICE_AZURE_RESOURCE_GROUP_NAME;
    serviceName : string = process.env.APIM_SERVICE_NAME;

    /** Get the list of products for the APIM service */
    public async getProducts() : Promise<ProductListByServiceResponse> {
        await this.initialize();

        return await this.managementClient.product.listByService(this.resourceGroupName, this.serviceName);
    }

    /** Get the list of subscriptions for the APIM service */
    public async getSubscriptions() : Promise<SubscriptionListResponse> {
        await this.initialize();

        return await this.managementClient.subscription.list(this.resourceGroupName, this.serviceName);
    }

    /** Get a single product by product ID for the APIM service */
    public async getProduct(productId: string) : Promise<ProductGetResponse> {
        await this.initialize();

        return await this.managementClient.product.get(this.resourceGroupName, this.serviceName, productId);
    }

    /** Get a user by ID */
    public async getUser(userId: string) : Promise<UserGetResponse> {
        await this.initialize();

        return await this.managementClient.user.get(this.resourceGroupName, this.serviceName, userId);
    }

    /** Get a subscription by ID */
    public async getSubscription(sid: string) : Promise<SubscriptionGetResponse> {
        await this.initialize();

        return await this.managementClient.subscription.get(this.resourceGroupName, this.serviceName, sid);
    }

    /** Create a new subscription to a product for a user */
    public async createSubscription(sid: string, userId: string, productId: string, subscriptionName: string) : Promise<SubscriptionCreateOrUpdateResponse> {
        await this.initialize();

        return await this.managementClient.subscription.createOrUpdate(
            this.resourceGroupName,
            this.serviceName,
            Guid.newGuid().toString(),
            {
                displayName: subscriptionName,
                scope: `/products/${productId}`,
                ownerId: `/users/${userId}`,
                state: "active"
            }
        );
    }

    /** Get the usage for a particular subscription between two dates */
    public async getUsage(sid: string, to: Date, from?: Date) : Promise<ReportRecordContract> {
        await this.initialize();
        const filter = `timestamp ge datetime'${from ? from.toISOString() : new Date('2000-01-01').toISOString()}' and timestamp le datetime'${to.toISOString()}' and subscriptionId eq '${sid}'`;
        const report = await this.managementClient.reports.listBySubscription(this.resourceGroupName, this.serviceName, filter);

        return report[0];
    }

    /** List the subscriptions for a user */
    public async getUserSubscriptions(userId: string) : Promise<SubscriptionListResponse> {
        await this.initialize();

        return await this.managementClient.userSubscription.list(this.resourceGroupName, this.serviceName, userId);
    }

    /** Update the state of a subscription (for the API keys related to a subscription to work, that subscription must be in an active state) */
    public async updateSubscriptionState(sid: string, state : SubscriptionState) {
        await this.initialize();

        return await this.managementClient.subscription.update(this.resourceGroupName, this.serviceName, sid, { state }, "*");
    }

    private async initialize() {
        if (!this.initialized) {
            const authResponse = await msRestNodeAuth.loginWithServicePrincipalSecretWithAuthResponse(
                process.env.AZURE_AD_SERVICE_PRINCIPAL_APP_ID,
                process.env.AZURE_AD_SERVICE_PRINCIPAL_PASSWORD,
                process.env.AZURE_AD_SERVICE_PRINCIPAL_TENANT_ID
            );

            const credentials = authResponse.credentials;
            const client = new ApiManagementClient(credentials, this.subscriptionId);
            this.managementClient = client
        }
    }
}