# Stripe Configuration Guide

This document explains how to configure Stripe for ARTIQ's subscription payments.

## Overview

ARTIQ uses Stripe for processing subscription payments. The integration requires three key pieces of information:

1. **Stripe Secret Key** - For API authentication
2. **Stripe Webhook Secret** - For verifying webhook signatures
3. **Stripe Price ID** - The subscription product price

## Configuration Steps

### 1. Get Your Stripe Keys

**Test Mode** (for development):
1. Log in to [Stripe Dashboard](https://dashboard.stripe.com/)
2. Switch to **Test mode** (toggle in top right)
3. Go to **Developers → API keys**
4. Copy your **Secret key** (starts with `sk_test_...`)

**Live Mode** (for production):
1. Complete Stripe account verification
2. Switch to **Live mode**
3. Go to **Developers → API keys**
4. Copy your **Secret key** (starts with `sk_live_...`)

### 2. Create a Subscription Product

1. Go to **Products** in Stripe Dashboard
2. Click **Add product**
3. Enter details:
   - Name: "ARTIQ Pro"
   - Description: "Premium subscription for ARTIQ"
   - Pricing: $9.99/month (recurring)
4. Click **Save product**
5. Copy the **Price ID** (starts with `price_...`)

### 3. Create a Webhook Endpoint

**Option A: Using Stripe Dashboard**
1. Go to **Developers → Webhooks**
2. Click **Add endpoint**
3. Enter webhook URL:
   - Test: `https://stripewebhook-wd7cqtfkwq-uc.a.run.app`
   - Production: (your production Cloud Function URL)
4. Select events to listen for:
   - `checkout.session.completed`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`
5. Click **Add endpoint**
6. Copy the **Signing secret** (starts with `whsec_...`)

**Option B: Using the Stripe API** (automated)
```bash
# See create_webhook.py script in the repository
python3 create_webhook.py
```

### 4. Configure Firebase Functions

Create `functions/.env.yaml` with your keys:

```yaml
STRIPE_SECRET_KEY: sk_test_your_key_here
STRIPE_WEBHOOK_SECRET: whsec_your_secret_here
STRIPE_PRICE_ID: price_your_price_id_here
```

**Important**: Never commit this file to Git! It's already in `.gitignore`.

### 5. Deploy to Firebase

```bash
firebase deploy --only functions
```

The deployment will automatically load the environment variables from `.env.yaml`.

## Current Configuration

### Test Mode (Development)
- **Webhook URL**: `https://stripewebhook-wd7cqtfkwq-uc.a.run.app`
- **Price ID**: `price_1SkNRFbVWPKXvfRQEquXEnp` ($9.99/month)
- **Events**: checkout.session.completed, customer.subscription.updated, customer.subscription.deleted, invoice.payment_succeeded, invoice.payment_failed

### Production Mode
- **Status**: Not yet configured
- **Action Required**: Follow steps above with live mode keys

## Switching to Production

When you're ready to accept real payments:

1. **Complete Stripe Verification**
   - Provide business information
   - Verify bank account
   - Complete identity verification

2. **Create Production Product**
   - Create new product in live mode
   - Set price to $9.99/month
   - Copy the live price ID

3. **Create Production Webhook**
   - Add webhook endpoint in live mode
   - Use production Cloud Function URL
   - Copy the live webhook secret

4. **Update Environment Variables**
   - Update `functions/.env.yaml` with live keys
   - Deploy functions: `firebase deploy --only functions`

5. **Test Thoroughly**
   - Complete a real payment with a real card
   - Verify webhook processes correctly
   - Check Firestore updates
   - Test subscription cancellation

## Security Best Practices

- ✅ Never commit `.env` or `.env.yaml` to Git
- ✅ Use test keys for development
- ✅ Use live keys only in production
- ✅ Rotate keys if compromised
- ✅ Use restricted API keys when possible
- ✅ Monitor webhook logs for suspicious activity

## Troubleshooting

### Webhook Not Receiving Events
1. Check webhook URL is correct
2. Verify webhook secret matches
3. Check Firebase Functions logs
4. Test webhook from Stripe Dashboard

### Payment Not Updating Subscription
1. Check Firestore security rules
2. Verify user ID matches
3. Check Cloud Functions logs
4. Ensure price ID is correct

### Signature Verification Failing
1. Verify webhook secret is correct
2. Check Express raw body middleware is working
3. Ensure webhook URL matches deployed function

## Support

For questions or issues:
- Stripe Documentation: https://stripe.com/docs
- Firebase Functions: https://firebase.google.com/docs/functions
- ARTIQ Support: [Your Support Email]

---

**Last Updated**: January 27, 2026  
**Current Status**: Test mode configured and deployed
