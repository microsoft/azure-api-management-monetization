export class Utils {

    // This ensures that URLs for contacting the APIM service contain the Azure subscription, resource group ahd service name
    public static ensureUrlArmified(resourceUrl: string): string {
        const regex = /subscriptions\/.*\/resourceGroups\/.*\/providers\/microsoft.ApiManagement\/service/i;
        const isArmUrl = regex.test(resourceUrl);

        if (isArmUrl) {
            return resourceUrl;
        }

        const url = new URL(resourceUrl);
        const protocol = url.protocol;
        const hostname = url.hostname;
        const pathname = url.pathname.endsWith("/")
            ? url.pathname.substring(0, url.pathname.length - 1)
            : url.pathname;

        resourceUrl = `${protocol}//${hostname}/subscriptions/sid/resourceGroups/rgid/providers/Microsoft.ApiManagement/service/sid${pathname}`;

        return resourceUrl;
    }
}