const functions = require('firebase-functions');
const admin = require('firebase-admin');
const stripeLib = require('stripe');
const cors = require('cors')({ origin: true });

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
 */
exports.stripeWebhook = functions.https.onRequest(async (req, res) => {
  const sig = req.headers['stripe-signature'];
  const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

  let event;

  try {
    const stripe = getStripe();
    event = stripe.webhooks.constructEvent(req.rawBody, sig, webhookSecret);
  } catch (err) {
    console.error('Webhook signature verification failed:', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  // Handle the event
  try {
    switch (event.type) {
      case 'checkout.session.completed':
        const session = event.data.object;
        const userId = session.client_reference_id || session.metadata.userId;

        if (userId) {
          await admin.firestore().collection('users').doc(userId).set(
            {
              subscription: {
                tier: 'pro',
                stripeCustomerId: session.customer,
                stripeSubscriptionId: session.subscription,
                status: 'active',
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
              },
            },
            { merge: true }
          );
          console.log(`User ${userId} upgraded to Pro`);
        }
        break;

      case 'customer.subscription.updated':
        const subscription = event.data.object;
        const customerId = subscription.customer;

        // Find user by customer ID
        const usersSnapshot = await admin
          .firestore()
          .collection('users')
          .where('subscription.stripeCustomerId', '==', customerId)
          .get();

        if (!usersSnapshot.empty) {
          const userDoc = usersSnapshot.docs[0];
          await userDoc.ref.update({
            'subscription.status': subscription.status,
            'subscription.updatedAt': admin.firestore.FieldValue.serverTimestamp(),
          });
          console.log(`Subscription updated for customer ${customerId}`);
        }
        break;

      case 'customer.subscription.deleted':
        const deletedSub = event.data.object;
        const deletedCustomerId = deletedSub.customer;

        // Find user and downgrade to free
        const deletedUsersSnapshot = await admin
          .firestore()
          .collection('users')
          .where('subscription.stripeCustomerId', '==', deletedCustomerId)
          .get();

        if (!deletedUsersSnapshot.empty) {
          const userDoc = deletedUsersSnapshot.docs[0];
          await userDoc.ref.update({
            'subscription.tier': 'free',
            'subscription.status': 'canceled',
            'subscription.updatedAt': admin.firestore.FieldValue.serverTimestamp(),
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
