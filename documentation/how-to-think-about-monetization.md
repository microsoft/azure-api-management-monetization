# How to think about monetization

Modern web APIs underpin the digital economy. They *generate revenue* by providing a company's *intellectual property* (IP) to *3rd parties*.

How do they do this?

- they *package IP.* This could be in the form of data, algorithms, or processes.
- they allow other parties to *discover useful IP* and consume it in a consistent, frictionless manner.
- they offer *a mechanism to get paid* (either directly or indirectly) for this usage.

A common theme across API success stories is a *healthy business model*. Value is created and exchanged between all parties, in a sustainable way.

Whether you are a start-up or an established organisation seeking to digitally transform, the business model should come first. The API is what enables the business model to be realised, by enabling the underlying IP to be marketed, adopted, consumed, and scaled far more easily (and cheaply) than non-digital products or services.

When an organization publishes their first API, it will face a complex set of decisions. Microsoft's Azure API Management platform is designed to de-risk and accelerate key elements of this journey, but organisations will still need to determine how to configure it and build their API to meet the unique needs of the business model they are seeking to deliver. This will involve decisions ranging from technical concerns such API versioning strategy, to business concerns such as licensing and monetization strategy.

## Developing a monetization strategy

Monetization is the process of converting something into money - in this case, the value that the API provides. API interactions typically involve three distinct parties in the value chain:

![](./illustration1.png)

Categories of API monetization strategy include:
- **Free** - for example where an API facilitates business to business integration such as streamlining a supply chain. Here the API is not monetized, but does deliver significant value by enabling business processes efficiencies for both the API provider and API consumer.
- **Consumer pays** - API consumers will pay based on the number of interactions they have with the API.
- **Consumer gets paid** - for example, where an API consumers is using the API to embed advertising in their web site they will typically receive a share of the revenue generated.
- **Indirect monetization** - the API monetization is not driven by the number of interactions with the API, but through other sources of revenue facilitated by the API.

In this document, we are focusing on the "consumer pays" approach. The monetization strategy is set by the API Provider and should be designed to meet the needs of the API Consumer.

There is no one-size-fits-all solution to API monetization because a wide range of factors influence the design. So each monetization strategy tends to be unique.

Monetization strategy provides an opportunity to differentiate your API from your competitors and to maximise the revenue you will generate from your API.

The following six steps explain how you should implement a monetization strategy for your API.

![](./illustration2.png)

### Step 1 - understand your customer

Map out the stages in the journey that your customers (API Consumers) are likely to follow from first discovering your API all the way through to maximum scale.

For example, a set of customer stages could be:

- **Investigation** - enable the API Consumer to be able to try out your API with zero cost and friction.
- **Implementation** - provide sufficient access to the API to support the development and testing work required to integrate with it.
- **Preview** - allow the customer to launch their offering and understand initial demand.
- **Initial production usage** - support early adoption of the API in production when usage levels are not yet fully understood and a risk adverse approach may be necessary.
- **Initial growth** - enable the API Consumer to ramp up usage of the API in response to increased demand from end users.
- **Scale** - incentivise the API Consumer to commit to a higher volume of purchase once the API is consistently reaching high levels of usage each month.
- **Global growth** - reward the API users who is using the API at global scale by offering the optimal wholesale price.

Analyse the value that your API will be generating for the customer at each stage in their journey. 

Consider applying a value based pricing strategy if the direct value of the API to the customer is well understood.

Calculate the anticipated lifetime usage levels of the API for a customer and your anticipated number of customers over the lifetime of the API.

### Step 2 - quantify the costs

Calculate the total cost of ownership for your API. This will include:

- Cost of customer acquisition (COCA) - the cost of marketing, sales and to onboard the customer. The most successful APIs tend to have a COCA that tends to zero as adoption level increase. APIs should be largely self service when it comes to onboarding a new customer. Factors that will influence that include documentation and frictionless integration with payment systems.
- Engineering costs - the human resources required to build, test, operate and maintain the API over its lifetime. This tends to be the most significant cost component. Exploit cloud PaaS and serverless technologies where possible to minimise.
- Infrastructure costs - the costs for the underlying platforms, compute, network and storage required to support the API over its lifetime. Exploit cloud platforms to achieve an infrastructure cost model that scales up proportionally in line with API usage levels.

### Step 3 - conduct market research

Research the market to identify competitors. Analyse their monetization strategies. Understand the specific features (functional and non-functional) that they are offering with their API.

### Step 4 - design the revenue model

In this step you design a revenue model based on the output from the previous steps. The objective is to define a set of tiers in your revenue model that will support an API consumer as they move through the lifecycle.  This is achieved by working across two dimensions:

- **Quality of service** - by putting constraints on the level of service you are offering.  One common method of achieving this is to set a **cap** on usage of the API, by defining a quota for the number of API calls that that can be made over a period of time (e.g. 50,000 calls per month) and then blocking calls once that quota is reached.  Another example is to set a **rate limit** which throttles the number of calls that can be made in a short period (e.g. 100 calls per second) thus preventing API consumers from making an intensive burst of API calls.  You often find that caps and rate limits are applied in conjunction - thus preventing users from consuming their monthly quota in a short intensive burst of API calls.
- **Price** - by defining the unit price that will be paid for each API call.

The objective is to maximise the lifetime value (LTV) that you generate from each customer by designing a revenue model that supports your customer at each stage of the customer journey:

- Make it as easy as possible for your customers to scale up by making it attractive to move up to the next tier in the revenue model. For example, by rewarding customers who purchase a higher volume of API calls with a lower unit price.
- Keep the revenue model as simple as possible by balancing the need to provide choice with the risk of overwhelming customers with a confusing array of options. Keep the number of dimensions used to differentiate across the revenue model tiers as few as possible.
- Be transparent by providing clear documentation about the different options and giving your customers tools to help choose the revenue model that best suits their needs.

First, identify the range of pricing models that will be required.  A pricing model describes a specific set of rules that the API Provider can use to turn consumption by the the API Consumer into revenue.

For example, to support the seven customer lifecycle stages in the example above, we could define six different pricing models:

- `Free` - enables the API Consumer to trial the API in an obligation and cost free way, to determine whether it fulfils a use case. This removes all barriers to entry.
- `Freemium` - allows the API Consumer to use the API for free, but to transition into a paid for service as demand increases.
- `Metered` - the API Consumer can make as many calls as they want per month, and will pay a fixed amount per call.
- `Tier` - the API Consumer pays for a set amount of calls per month, and if they exceed this limit they pay an overage amount per additional call. If they regularly incur overage, they have the option to upgrade to the next tier.
- `Tier + Overage` - the API Consumer pays for a set amount of calls per month, and if they exceed this limit they pay a set amount per additional call usually at a higher rate.
- `Unit` - the API Consumer pays for a set amount of call per month. If they exceed this limit they have to pay for another unit of calls.

The revenue model defines the set of API products, each of which implements a specific pricing model to target at a specific stage in the API Consumer lifecycle.

In general, you should not expect the pricing models to change, but you should expect to adapt how these pricing models are configured and applied to create your revenue model, for example if you saw a competitor enter the market at a lower price point you may want to adjust your own prices accordingly.

Bringing this to life, and building on the examples above, the pricing models could be applied to create an overall **revenue model** as follows:

| Customer lifecycle stage | Pricing model    | Pricing model configuration                                                                                                                                     | Quality of service                                                                                          |
|--------------------------|------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------|
| Investigation            | `Free`           | Not implemented.                                                                                                                                                | Quota set to limit the Consumer to 100 calls / month                                                        |
| Implementation           | `Freemium `      | Graduated tiers, where the first tier flat amount is $0, next tiers per unit amount charge set to charge $0.20 / 100 calls.                                     | No quota set - Consumer can continue to make & pay for calls, rate limit of 100 calls / minute              |
| Preview                  | `Metered`        | Price set to charge Consumer $0.15 / 100 calls                                                                                                                  | No quota set - Consumer can continue to make & pay for calls, rate limit of 200 calls / minute              |
| Initial production usage | `Tier`           | Price set to charge Consumer $14.95 / month                                                                                                                     | Quota set to limit the Consumer to 50,000 calls / month, rate limit of 100 calls / minute                   |
| Initial growth           | `Tier + Overage` | Graduated tiers, where the first tier flat amount is $89.95 / month for first 100,000 calls, next tiers per unit amount charge set to charge $0.10 / 100 calls  | No quota set - Consumer can continue to make & pay for additional calls, rate limit of 100 calls / minute   |
| Scale                    | `Tier + Overage` | Graduated tiers, where the first tier flat amount is $449.95 / month for first 500,000 calls, next tiers per unit amount charge set to charge $0.06 / 100 calls | No quota set - Consumer can continue to make & pay for additional calls, rate limit of 1,200 calls / minute |
| Global growth            | `Unit`           | Graduated tiers, where every tier flat amount is $749.95 / month for 1,500,000 calls                                                                            | No quota set - Consumer can continue to make & pay for additional calls, rate limit of 3,500 calls / minute |

Two examples of how to interpret the revenue model based on the table above:
- In the 4th row, the "tier" pricing model is being applied to support API consumers during the "initial production phase" of the lifecycle.  The `Tier` pricing model is configured such that the consumer pays $14.95 / month and can make up to a maximum of 50,000 calls per month.  They will be rate limited to 100 calls / minute.
- The 6th row is geared to support API consumers are in the "scale" phase of the lifecycle.  It is implemented by applying the `Tier + Overage` pricing model where consumers pay $449.95 / month for first 500,000 calls. And are charged an additional $0.06 / 100 additional calls if they exceed that.  They are rate limited to 1,200 calls per minute.

**Note** - the models above are hypothetical and have been designed to illustrate the array of options that are available.  Customers are free to come up with their own!

### Step 5 - calibrate

Calibrate the pricing across the revenue model to:

- Set the pricing so as not to overprice or underprice your API based on the market research in step 3 above.
- Avoid any points in the revenue model that may appear unfair or that may encourage customers to work around the model to achieve more favourable pricing.
- Ensure that the revenue model is geared to generate a Total Lifetime Value (TLV) sufficient to cover the Total Cost of Ownership plus margin.
- Check that the quality of service that you are offering in each tier in the revenue model can be supported by your solution - i.e. if you are offering to support 3,500 calls / minute, check your end-to-end solution can scale to support that level of throughput.

### Step 6 - release and monitor

Choose an appropriate solution to collect payment for usage of your APIs.  Providers tend to fall into two groups:

- Payment platforms (e.g. Stripe) - calculate the payment based on the raw API usage metrics by applying the specific revenue model that the customer has chosen.  Therefore, the payment platform needs to be configured to reflect your monetization strategy.
- Payment providers (e.g. Adyen) - are only concerned with the facilitating the payment transaction.  Therefore, you will need to apply your pricing model (i.e. translate API usage metrics into a payment) prior to calling this service.

Use Microsoft's Azure API Management (APIM) to accelerate and de-risk the implementation by using built-in capabilities provided in APIM.  See [How APIM supports monetization](how-APIM-supports-monetization.md) for more details about the specific features in APIM that can be leveraged to support implementation.

Use the same approach as the sample project to implement a solution that builds flexibility into how you codify your monetization strategy in the underlying systems.  This will enable you to respond dynamically and to make minimise the risk and cost of making changes.

For a description of how the sample project works from an API consumer perspective see [How to implement monetization with Azure API Management and Stripe](./stripe-details.md) or [How to implement monetization with Azure API Management and Adyen](./adyen-details.md).

Follow the [README](../README.md) to deploy the sample project in your own Azure subscription.

Regularly monitor how your API is being consumed to enable you to make evidence based decisions. For example, if evidence shows you are churning customers, you should repeat steps 1 to 5 above to uncover the source and make changes accordingly to address it.

## Ongoing evolution

Review your monetization strategy on a regular basis by revisiting and re-evaluating all of the steps above. It is likely that you will need to evolve your monetization strategy over time as you learn more about your customers, what it costs to provide the API and in response to shifting competition in the market.

Remember that the monetization strategy is only one facet of a successful API implementation. Other facets include the developer experience, the quality of your documentation, the legal terms and your ability to scale the API to meet the service levels you have committed to.
