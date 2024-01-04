import { ProductContract } from "@azure/arm-apimanagement/esm/models";
import fetch from "node-fetch";

export interface MonetizationModel {
    id: string,
    prices: any;
    pricingModelType: string
    recurring: any;
}

export class MonetizationService {
    /** Retrieve our defined monetization model for a given APIM product */
    public static async getMonetizationModelFromProduct(product: ProductContract): Promise<MonetizationModel> {

        const monetizationModelsUrl = `${process.env.APIM_GATEWAY_URL}/billing/monetizationModels`;

        const monetizationModelsResponse = await fetch(monetizationModelsUrl, { method: "GET", headers: { "Ocp-Apim-Subscription-Key": process.env.APIM_ADMIN_SUBSCRIPTION_KEY } });

        const monetizationModels = (await monetizationModelsResponse.json()) as MonetizationModel[];

        const monetizationModel = monetizationModels.find((x: { id: any; }) => x.id === product.name);

        return monetizationModel;
    }
}