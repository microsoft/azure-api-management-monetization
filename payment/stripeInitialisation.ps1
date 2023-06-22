[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [String]
    $StripeApiKey,

    [Parameter(Mandatory=$true)]
    [String]
    $ApimGatewayUrl,

    [Parameter(Mandatory=$true)]
    [String]
    $ApimSubscriptionKey,

    [Parameter(Mandatory=$true)]
    [String]
    $StripeWebhookUrl,

    [Parameter(Mandatory=$true)]
    [String]
    $AppServiceResourceGroup,

    [Parameter(Mandatory=$true)]
    [String]
    $AppServiceName
)

$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $PSCommandPath
$toolsDir = "$here/../tools"

if ($IsWindows) {
    $osPath = "windows_x86_64.zip"
}
elseif ($IsLinux) {
    $osPath = "linux_x86_64.tar.gz"
}
elseif ($IsMacOS) {
    $osPath = "mac-os_x86_64.tar.gz"
}
else {
    throw "Unsupported OS"
}

function installStripe {
    $version = "1.5.13"
    $stripeUri = "https://github.com/stripe/stripe-cli/releases/download/v$version/stripe_$($version)_$osPath"

    $dir = New-Item -Path $toolsDir/stripe/$version -ItemType Directory -Force
    $stripe = "$dir/stripe"
    if (Test-Path $dir/* -Filter stripe*) {
        Write-Host "Stripe CLI already installed."
    }
    else {
        if ($IsWindows) {
            $stripeZipPath = "$dir/stripe.zip"
            Invoke-WebRequest -Uri $stripeUri -OutFile $stripeZipPath | Out-Null
            Expand-Archive -Path $stripeZipPath -DestinationPath $dir -Force | Out-Null
            Remove-Item $stripeZipPath -Force | Out-Null
        }  
        else {
            $stripeTarGzPath = "$dir/stripe.tar.gz"
            Invoke-WebRequest -Uri $stripeUri -OutFile $stripeTarGzPath | Out-Null
            tar -xvf $stripeTarGzPath -C $dir
            Remove-Item $stripeTarGzPath -Force | Out-Null
        }     
    }

    return $stripe
}

$stripe = installStripe

$env:STRIPE_API_KEY = $StripeApiKey

$monetizationModels = Invoke-WebRequest -Uri $ApimGatewayUrl/billing/monetizationModels -Headers @{"Ocp-Apim-Subscription-Key"=$ApimSubscriptionKey} | ConvertFrom-Json
$apimProducts = Invoke-WebRequest -Uri $ApimGatewayUrl/billing/products -Headers @{"Ocp-Apim-Subscription-Key"=$ApimSubscriptionKey} | ConvertFrom-Json

foreach ($model in $monetizationModels) {
    $apimProduct = $apimProducts.value | Where-Object { $_.name -eq $model.id }
    . $stripe post /v1/products  `
        -d "name=$($apimProduct.properties.displayName)"    `
        -d "id=$($apimProduct.name)"   `
        -d "description=$($apimProduct.properties.description)"

    $prices = . $stripe get /v1/prices `
        -d "product=$($model.id)" `
        -d "active=true" | ConvertFrom-Json

    if (!($prices.data[0])) {
        if ($model.pricingModelType -eq "Metered") {
            . $stripe post /v1/prices `
                -d "product=$($model.id)" `
                -d "currency=$($model.prices.metered.currency)" `
                -d "unit_amount_decimal=$($model.prices.metered.unitAmount)" `
                -d "recurring[interval]=$($model.recurring.interval)" `
                -d "recurring[interval_count]=$($model.recurring.intervalCount)" `
                -d "recurring[usage_type]=metered"
        }
        if (($model.pricingModelType -eq "Freemium") -or ($model.pricingModelType -eq "TierWithOverage")) {
            . $stripe post /v1/prices `
                -d "product=$($model.id)" `
                -d "currency=$($model.prices.metered.currency)" `
                -d "recurring[interval]=$($model.recurring.interval)" `
                -d "recurring[interval_count]=$($model.recurring.intervalCount)" `
                -d "recurring[usage_type]=metered" `
                -d "billing_scheme=tiered" `
                -d "tiers_mode=graduated" `
                -d "tiers[0][up_to]=$($model.prices.unit.quota)" `
                -d "tiers[0][flat_amount]=$($model.prices.unit.unitAmount)" `
                -d "tiers[1][up_to]=inf" `
                -d "tiers[1][unit_amount_decimal]=$($model.prices.metered.unitAmount)"
        }
        if (($model.pricingModelType -eq "Tier")) {
            . $stripe post /v1/prices `
                -d "product=$($model.id)" `
                -d "currency=$($model.prices.unit.currency)" `
                -d "unit_amount_decimal=$($model.prices.unit.unitAmount)" `
                -d "recurring[interval]=$($model.recurring.interval)" `
                -d "recurring[interval_count]=$($model.recurring.intervalCount)" `
                -d "recurring[usage_type]=licensed"
        }
        if (($model.pricingModelType -eq "Unit")) {
            # NOTE: we're only going up to 5 tiers for this example
            . $stripe post /v1/prices `
                -d "product=$($model.id)" `
                -d "currency=$($model.prices.unit.currency)" `
                -d "recurring[interval]=$($model.recurring.interval)" `
                -d "recurring[interval_count]=$($model.recurring.intervalCount)" `
                -d "recurring[usage_type]=metered" `
                -d "billing_scheme=tiered" `
                -d "tiers_mode=graduated" `
                -d "tiers[0][up_to]=$($model.prices.unit.quota)" `
                -d "tiers[0][flat_amount]=$($model.prices.unit.unitAmount)" `
                -d "tiers[1][up_to]=$(($model.prices.unit.quota) * 2)" `
                -d "tiers[1][flat_amount]=$($model.prices.unit.unitAmount)" `
                -d "tiers[2][up_to]=$(($model.prices.unit.quota) * 3)" `
                -d "tiers[2][flat_amount]=$($model.prices.unit.unitAmount)" `
                -d "tiers[3][up_to]=$(($model.prices.unit.quota) * 4)" `
                -d "tiers[3][flat_amount]=$($model.prices.unit.unitAmount)" `
                -d "tiers[4][up_to]=$(($model.prices.unit.quota) * 5)" `
                -d "tiers[4][flat_amount]=$($model.prices.unit.unitAmount)" `
                -d "tiers[5][up_to]=inf" `
                -d "tiers[5][flat_amount]=$($model.prices.unit.unitAmount)"
        }
    }


}

$webhookEndpoints = (. $stripe get /v1/webhook_endpoints) | ConvertFrom-Json

$webhookEndpoint = $webhookEndpoints.data | Where-Object { ($_.url -eq $StripeWebhookUrl) -and ($_.enabled_events -contains 'charge.failed') -and ($_.enabled_events -contains 'checkout.session.completed')}

if ($webhookEndpoint) {
    . $stripe delete /v1/webhook_endpoints/$($webhookEndpoint.id) --confirm
}

$webhookEndpoint = (. $stripe post /v1/webhook_endpoints `
    -d "enabled_events[]=customer.subscription.created" `
    -d "enabled_events[]=customer.subscription.updated" `
    -d "enabled_events[]=customer.subscription.deleted" `
    -d "url=$StripeWebhookUrl") | ConvertFrom-Json

$webhookSecret = $webhookEndpoint.secret

az webapp config appsettings set -g $AppServiceResourceGroup -n $AppServiceName --settings STRIPE_WEBHOOK_SECRET=$webhookSecret