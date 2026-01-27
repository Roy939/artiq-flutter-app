const express = require('express');
const admin = require('firebase-admin');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.applicationDefault()
});

const app = express();

// CRITICAL: Use raw body parser for webhook signature verification
// This must come BEFORE any other body parsing middleware
app.post('/webhook', express.raw({ type: 'application/json' }), async (req, res) => {
  const sig = req.headers['stripe-signature'];
  const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

  console.log('Webhook received');
  console.log('Body is Buffer:', Buffer.isBuffer(req.body));
  console.log('Signature present:', !!sig);
  console.log('Webhook secret configured:', !!webhookSecret);

  let event;

  try {
    // Verify webhook signature
    // req.body is a Buffer thanks to express.raw()
    event = stripe.webhooks.constructEvent(req.body, sig, webhookSecret);
    console.log('✅ Webhook signature verified successfully');
    console.log('Event type:', event.type);
  } catch (err) {
    console.error('❌ Webhook signature verification failed:', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  // Handle the event
  try {
    switch (event.type) {
      case 'checkout.session.completed':
        const session = event.data.object;
        const userId = session.client_reference_id || session.metadata?.userId;

        console.log('Processing checkout.session.completed');
        console.log('User ID:', userId);
        console.log('Customer ID:', session.customer);
        console.log('Subscription ID:', session.subscription);

        if (userId) {
          await admin.firestore().collection('subscriptions').doc(userId).set(
            {
              userId: userId,
              tier: 'pro',
              stripeCustomerId: session.customer,
              stripeSubscriptionId: session.subscription,
              isActive: true,
              subscriptionStart: admin.firestore.FieldValue.serverTimestamp(),
              subscriptionEnd: null,
            },
            { merge: true }
          );
          console.log(`✅ User ${userId} upgraded to Pro in subscriptions collection`);
        } else {
          console.error('❌ No user ID found in session');
        }
        break;

      case 'customer.subscription.updated':
        const subscription = event.data.object;
        const customerId = subscription.customer;

        console.log('Processing customer.subscription.updated');
        console.log('Customer ID:', customerId);
        console.log('Subscription status:', subscription.status);

        // Find subscription by customer ID
        const subsSnapshot = await admin
          .firestore()
          .collection('subscriptions')
          .where('stripeCustomerId', '==', customerId)
          .limit(1)
          .get();

        if (!subsSnapshot.empty) {
          const subsDoc = subsSnapshot.docs[0];
          await subsDoc.ref.update({
            isActive: subscription.status === 'active',
            subscriptionEnd: subscription.cancel_at
              ? admin.firestore.Timestamp.fromMillis(subscription.cancel_at * 1000)
              : null,
          });
          console.log(`✅ Updated subscription for customer ${customerId}`);
        } else {
          console.error(`❌ No subscription found for customer ${customerId}`);
        }
        break;

      case 'customer.subscription.deleted':
        const deletedSub = event.data.object;
        const deletedCustomerId = deletedSub.customer;

        console.log('Processing customer.subscription.deleted');
        console.log('Customer ID:', deletedCustomerId);

        // Find and deactivate subscription
        const deletedSubsSnapshot = await admin
          .firestore()
          .collection('subscriptions')
          .where('stripeCustomerId', '==', deletedCustomerId)
          .limit(1)
          .get();

        if (!deletedSubsSnapshot.empty) {
          const deletedSubDoc = deletedSubsSnapshot.docs[0];
          await deletedSubDoc.ref.update({
            tier: 'free',
            isActive: false,
            subscriptionEnd: admin.firestore.FieldValue.serverTimestamp(),
          });
          console.log(`✅ Subscription cancelled for customer ${deletedCustomerId}`);
        } else {
          console.error(`❌ No subscription found for customer ${deletedCustomerId}`);
        }
        break;

      case 'invoice.payment_succeeded':
        console.log('Processing invoice.payment_succeeded');
        console.log('Invoice ID:', event.data.object.id);
        // Payment succeeded - subscription remains active
        break;

      case 'invoice.payment_failed':
        console.log('Processing invoice.payment_failed');
        console.log('Invoice ID:', event.data.object.id);
        // Could mark subscription as past_due here
        break;

      default:
        console.log(`Unhandled event type: ${event.type}`);
    }

    res.json({ received: true });
  } catch (error) {
    console.error('Error handling webhook:', error);
    res.status(500).json({ error: error.message });
  }
});

// Health check endpoint
app.get('/', (req, res) => {
  res.json({ status: 'ok', service: 'artiq-stripe-webhook' });
});

// Health check for Cloud Run
app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`🚀 Stripe webhook service listening on port ${PORT}`);
  console.log(`✅ Stripe secret key configured: ${!!process.env.STRIPE_SECRET_KEY}`);
  console.log(`✅ Webhook secret configured: ${!!process.env.STRIPE_WEBHOOK_SECRET}`);
});
