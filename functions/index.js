const functions = require('firebase-functions');
const admin = require('firebase-admin');
const stripeLib = require('stripe');
const cors = require('cors')({ origin: true });
const express = require('express');

admin.initializeApp();

// Lazy-load Stripe with secret
const getStripe = () => {
  if (!process.env.STRIPE_SECRET_KEY) {
    throw new Error('STRIPE_SECRET_KEY not configured');
  }
  return stripeLib(process.env.STRIPE_SECRET_KEY);
};

/**
 * Create Stripe Checkout Session
 * Called from Flutter app when user clicks "Upgrade to Pro"
 */
exports.createCheckoutSession = functions.https.onRequest((req, res) => {
    cors(req, res, async () => {
      try {
        // Verify authentication
        const authHeader = req.headers.authorization;
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
          return res.status(401).json({ error: 'Unauthorized' });
        }

        const idToken = authHeader.split('Bearer ')[1];
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        const userId = decodedToken.uid;

        // Create Stripe Checkout Session
        const stripe = getStripe();
        const session = await stripe.checkout.sessions.create({
          payment_method_types: ['card'],
          line_items: [
            {
              price: process.env.STRIPE_PRICE_ID,
              quantity: 1,
            },
          ],
          mode: 'subscription',
          success_url: process.env.SUCCESS_URL || 'https://roy939.github.io/artiq-flutter-app/',
          cancel_url: process.env.CANCEL_URL || 'https://roy939.github.io/artiq-flutter-app/',
          client_reference_id: userId,
          metadata: {
            userId: userId,
          },
        });

        res.json({ sessionId: session.id, url: session.url });
      } catch (error) {
        console.error('Error creating checkout session:', error);
        res.status(500).json({ error: error.message });
      }
    });
  });

/**
 * Stripe Webhook Handler
 * Processes Stripe events (payment success, subscription updates, etc.)
 * Using Express with raw body parser to properly handle Stripe webhooks
 */
// Create Express app with raw body parser for ALL routes
const webhookApp = express();
webhookApp.use(express.raw({ type: '*/*' }));
webhookApp.post('/', async (req, res) => {
  const sig = req.headers['stripe-signature'];
  const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

  let event;

  try {
    const stripe = getStripe();
    
    // req.body is now a Buffer thanks to express.raw()
    console.log('Webhook received - Body is Buffer:', Buffer.isBuffer(req.body));
    console.log('Webhook secret:', webhookSecret ? 'Set' : 'Not set');
    console.log('Signature present:', !!sig);
    
    // Convert Buffer to string for Stripe signature verification
    const payload = Buffer.isBuffer(req.body) ? req.body.toString('utf8') : req.body;
    event = stripe.webhooks.constructEvent(payload, sig, webhookSecret);
    console.log('Webhook signature verified successfully for event:', event.type);
  } catch (err) {
    console.error('Webhook signature verification failed:', err.message);
    console.error('Error details:', err);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  // Handle the event
  try {
    switch (event.type) {
      case 'checkout.session.completed':
        const session = event.data.object;
        const userId = session.client_reference_id || session.metadata.userId;

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
          console.log(`User ${userId} upgraded to Pro in subscriptions collection`);
        }
        break;

      case 'customer.subscription.updated':
        const subscription = event.data.object;
        const customerId = subscription.customer;

        // Find subscription by customer ID
        const subsSnapshot = await admin
          .firestore()
          .collection('subscriptions')
          .where('stripeCustomerId', '==', customerId)
          .get();

        if (!subsSnapshot.empty) {
          const subDoc = subsSnapshot.docs[0];
          await subDoc.ref.update({
            isActive: subscription.status === 'active',
            subscriptionEnd: subscription.status === 'canceled' ? admin.firestore.FieldValue.serverTimestamp() : null,
          });
          console.log(`Subscription updated for customer ${customerId}`);
        }
        break;

      case 'customer.subscription.deleted':
        const deletedSub = event.data.object;
        const deletedCustomerId = deletedSub.customer;

        // Find subscription and downgrade to free
        const deletedSubsSnapshot = await admin
          .firestore()
          .collection('subscriptions')
          .where('stripeCustomerId', '==', deletedCustomerId)
          .get();

        if (!deletedSubsSnapshot.empty) {
          const subDoc = deletedSubsSnapshot.docs[0];
          await subDoc.ref.update({
            tier: 'free',
            isActive: false,
            subscriptionEnd: admin.firestore.FieldValue.serverTimestamp(),
          });
          console.log(`User downgraded to free for customer ${deletedCustomerId}`);
        }
        break;

      case 'invoice.payment_succeeded':
        console.log('Payment succeeded:', event.data.object.id);
        break;

      case 'invoice.payment_failed':
        console.log('Payment failed:', event.data.object.id);
        break;

      default:
        console.log(`Unhandled event type ${event.type}`);
    }

    res.json({ received: true });
  } catch (error) {
    console.error('Error handling webhook:', error);
    res.status(500).json({ error: error.message });
  }
});

// Export the Express app as a Cloud Function
exports.stripeWebhook = functions.https.onRequest(webhookApp);

/**
 * Get Subscription Status
 * Returns current subscription tier for a user
 */
exports.getSubscriptionStatus = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      const authHeader = req.headers.authorization;
      if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      const idToken = authHeader.split('Bearer ')[1];
      const decodedToken = await admin.auth().verifyIdToken(idToken);
      const userId = decodedToken.uid;

      const userDoc = await admin.firestore().collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return res.json({ tier: 'free', status: 'active' });
      }

      const subscription = userDoc.data().subscription || { tier: 'free', status: 'active' };
      res.json(subscription);
    } catch (error) {
      console.error('Error getting subscription status:', error);
      res.status(500).json({ error: error.message });
    }
  });
});

/**
 * Cancel Subscription
 * Cancels user's subscription at period end
 */
exports.cancelSubscription = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      const authHeader = req.headers.authorization;
      if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      const idToken = authHeader.split('Bearer ')[1];
      const decodedToken = await admin.auth().verifyIdToken(idToken);
      const userId = decodedToken.uid;

      const userDoc = await admin.firestore().collection('users').doc(userId).get();

      if (!userDoc.exists || !userDoc.data().subscription) {
        return res.status(404).json({ error: 'No subscription found' });
      }

      const subscriptionId = userDoc.data().subscription.stripeSubscriptionId;

      if (!subscriptionId) {
        return res.status(404).json({ error: 'No Stripe subscription ID found' });
      }

      // Cancel at period end
      const stripe = getStripe();
      const subscription = await stripe.subscriptions.update(subscriptionId, {
        cancel_at_period_end: true,
      });

      await userDoc.ref.update({
        'subscription.cancelAtPeriodEnd': true,
        'subscription.updatedAt': admin.firestore.FieldValue.serverTimestamp(),
      });

      res.json({ success: true, subscription });
    } catch (error) {
      console.error('Error canceling subscription:', error);
      res.status(500).json({ error: error.message });
    }
  });
});
