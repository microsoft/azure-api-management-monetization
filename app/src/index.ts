import express from "express";
import expressLayouts from "express-ejs-layouts";
import path from "path";
import dotenv from "dotenv";
import { CronJob } from "cron";
import * as routes from "./routes/index";
import { AdyenBillingService, Invoice } from "./services/adyenBillingService";
import { StripeBillingService } from "./services/stripeBillingService";

dotenv.config();

const app = express();
const paymentProvider = process.env.PAYMENT_PROVIDER

app.use(express.urlencoded({ extended: true }));

// Use JSON parser for all non-webhook routes
app.use(
  (
    req: express.Request,
    res: express.Response,
    next: express.NextFunction
  ): void => {
    if (req.originalUrl.startsWith('/webhook/')) {
      next();
    } else {
      express.json()(req, res, next);
    }
  }
);

const port = process.env.SERVER_PORT || 8080;

app.use(expressLayouts)
app.set("views", path.join(__dirname, "views"));
app.set('layout', './layout');
app.set("view engine", "ejs");

app.use(express.static(path.join(__dirname, "public")));

routes.register(app);

if (paymentProvider === "Stripe") {
  // Run 'report usage' function every day at midnight
  const job = new CronJob(
    '0 0 * * *',
    async () => {
      await StripeBillingService.reportUsageToStripe();
    },
    null,
    true,
    'Europe/London'
  );
}

if (paymentProvider === "Adyen") {
  // Run monthly billing for all subscriptions
  const job = new CronJob(
    '0 0 1 * *',
    async () => {
      const now = new Date(Date.now());
      const invoices : Invoice[] = await AdyenBillingService.calculateInvoices(now.getMonth(), now.getFullYear());

      await Promise.all(invoices.map(async invoice => {
        await AdyenBillingService.takePaymentFromUser(invoice);
      }))
    },
    null,
    true,
    'Europe/London'
  );
}

app.listen(port, () => {
  // tslint:disable-next-line:no-console
  console.log(`server started at http://localhost:${port}`);
});