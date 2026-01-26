const functions = require('firebase-functions');
const admin = require('firebase-admin');
const stripe = require('stripe')(functions.config().stripe.secret_key);
const cors = require('cors')({ origin: true });

admin.initializeApp();

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

      // Get user email
      const userRecord = await admin.auth().getUser(userId);
      const userEmail = userRecord.email;

      // Create Stripe Checkout Session
      const session = await stripe.checkout.sessions.create({
        payment_method_types: ['card'],
        line_items: [
          {
            price: 'price_1SkNRFbVWPKXvfRQEquXEnp', // ARTIQ PRO price ID
            quantity: 1,
          },
        ],
        mode: 'subscription',
        success_url: `${req.body.successUrl || 'https://roy939.github.io/artiq-flutter-app/'}?session_id={CHECKOUT_SESSION_ID}`,
        cancel_url: `${req.body.cancelUrl || 'https://roy939.github.io/artiq-flutter-app/'}?canceled=true`,
        customer_email: userEmail,
        client_reference_id: userId,
        metadata: {
          userId: userId,
          userEmail: userEmail,
        },
      });

      res.json({ 
        sessionId: session.id,
        url: session.url 
      });
    } catch (error) {
      console.error('Error creating checkout session:', error);
      res.status(500).json({ error: error.message });
    }
  });
});

/**
 * Stripe Webhook Handler
 * Processes webhook events from Stripe
 */
exports.stripeWebhook = functions.https.onRequest(async (req, res) => {
  const sig = req.headers['stripe-signature'];
  const webhookSecret = functions.config().stripe.webhook_secret;

  let event;

  try {
    // Verify webhook signature
    event = stripe.webhooks.constructEvent(
      req.rawBody,
      sig,
      webhookSecret
    );
  } catch (err) {
    console.error('Webhook signature verification failed:', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  // Handle the event
  switch (event.type) {
    case 'checkout.session.completed':
      await handleCheckoutSessionCompleted(event.data.object);
      break;
    
    case 'customer.subscription.updated':
      await handleSubscriptionUpdated(event.data.object);
      break;
    
    case 'customer.subscription.deleted':
      await handleSubscriptionDeleted(event.data.object);
      break;
    
    case 'invoice.payment_succeeded':
      await handleInvoicePaymentSucceeded(event.data.object);
      break;
    
    case 'invoice.payment_failed':
      await handleInvoicePaymentFailed(event.data.object);
      break;
    
    default:
      console.log(`Unhandled event type: ${event.type}`);
  }

  res.json({ received: true });
});

/**
 * Handle successful checkout session
 */
async function handleCheckoutSessionCompleted(session) {
  try {
    const userId = session.client_reference_id || session.metadata.userId;
    
    if (!userId) {
      console.error('No userId found in checkout session');
      return;
    }

    // Get subscription details from Stripe
    const subscription = await stripe.subscriptions.retrieve(session.subscription);

    // Update Firestore
    await admin.firestore().collection('subscriptions').doc(userId).set({
      tier: 'pro',
      stripeCustomerId: session.customer,
      stripeSubscriptionId: session.subscription,
      stripePriceId: subscription.items.data[0].price.id,
      status: subscription.status,
      currentPeriodStart: new Date(subscription.current_period_start * 1000),
      currentPeriodEnd: new Date(subscription.current_period_end * 1000),
      cancelAtPeriodEnd: subscription.cancel_at_period_end,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    console.log(`Subscription activated for user ${userId}`);
  } catch (error) {
    console.error('Error handling checkout session:', error);
  }
}

/**
 * Handle subscription updates
 */
async function handleSubscriptionUpdated(subscription) {
  try {
    const userId = subscription.metadata.userId;
    
    if (!userId) {
      // Try to find user by customer ID
      const snapshot = await admin.firestore()
        .collection('subscriptions')
        .where('stripeCustomerId', '==', subscription.customer)
        .limit(1)
        .get();
      
      if (snapshot.empty) {
        console.error('No user found for subscription update');
        return;
      }
      
      const doc = snapshot.docs[0];
      await doc.ref.update({
        status: subscription.status,
        currentPeriodStart: new Date(subscription.current_period_start * 1000),
        currentPeriodEnd: new Date(subscription.current_period_end * 1000),
        cancelAtPeriodEnd: subscription.cancel_at_period_end,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } else {
      await admin.firestore().collection('subscriptions').doc(userId).update({
        status: subscription.status,
        currentPeriodStart: new Date(subscription.current_period_start * 1000),
        currentPeriodEnd: new Date(subscription.current_period_end * 1000),
        cancelAtPeriodEnd: subscription.cancel_at_period_end,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    console.log(`Subscription updated for subscription ${subscription.id}`);
  } catch (error) {
    console.error('Error handling subscription update:', error);
  }
}

/**
 * Handle subscription deletion/cancellation
 */
async function handleSubscriptionDeleted(subscription) {
  try {
    // Find user by customer ID
    const snapshot = await admin.firestore()
      .collection('subscriptions')
      .where('stripeCustomerId', '==', subscription.customer)
      .limit(1)
      .get();
    
    if (snapshot.empty) {
      console.error('No user found for subscription deletion');
      return;
    }
    
    const doc = snapshot.docs[0];
    await doc.ref.update({
      tier: 'free',
      status: 'canceled',
      canceledAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`Subscription canceled for subscription ${subscription.id}`);
  } catch (error) {
    console.error('Error handling subscription deletion:', error);
  }
}

/**
 * Handle successful invoice payment
 */
async function handleInvoicePaymentSucceeded(invoice) {
  try {
    console.log(`Invoice payment succeeded: ${invoice.id}`);
    // Additional logic if needed (e.g., send receipt email)
  } catch (error) {
    console.error('Error handling invoice payment success:', error);
  }
}

/**
 * Handle failed invoice payment
 */
async function handleInvoicePaymentFailed(invoice) {
  try {
    console.log(`Invoice payment failed: ${invoice.id}`);
    // Additional logic if needed (e.g., send payment failure notification)
  } catch (error) {
    console.error('Error handling invoice payment failure:', error);
  }
}

/**
 * Get user subscription status
 * Called from Flutter app to check current subscription
 */
exports.getSubscriptionStatus = functions.https.onRequest((req, res) => {
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

      // Get subscription from Firestore
      const doc = await admin.firestore().collection('subscriptions').doc(userId).get();
      
      if (!doc.exists) {
        return res.json({ tier: 'free' });
      }

      const subscription = doc.data();
      
      // If has Stripe subscription, verify it's still active
      if (subscription.stripeSubscriptionId) {
        const stripeSubscription = await stripe.subscriptions.retrieve(
          subscription.stripeSubscriptionId
        );
        
        // Update Firestore if status changed
        if (stripeSubscription.status !== subscription.status) {
          await doc.ref.update({
            status: stripeSubscription.status,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          subscription.status = stripeSubscription.status;
        }
      }

      res.json(subscription);
    } catch (error) {
      console.error('Error getting subscription status:', error);
      res.status(500).json({ error: error.message });
    }
  });
});

/**
 * Cancel subscription
 * Called from Flutter app when user wants to cancel
 */
exports.cancelSubscription = functions.https.onRequest((req, res) => {
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

      // Get subscription from Firestore
      const doc = await admin.firestore().collection('subscriptions').doc(userId).get();
      
      if (!doc.exists || !doc.data().stripeSubscriptionId) {
        return res.status(404).json({ error: 'No active subscription found' });
      }

      const subscription = doc.data();

      // Cancel at period end (don't immediately cancel)
      const updatedSubscription = await stripe.subscriptions.update(
        subscription.stripeSubscriptionId,
        { cancel_at_period_end: true }
      );

      // Update Firestore
      await doc.ref.update({
        cancelAtPeriodEnd: true,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      res.json({ 
        success: true,
        cancelAtPeriodEnd: updatedSubscription.cancel_at_period_end,
        currentPeriodEnd: new Date(updatedSubscription.current_period_end * 1000)
      });
    } catch (error) {
      console.error('Error canceling subscription:', error);
      res.status(500).json({ error: error.message });
    }
  });
});
