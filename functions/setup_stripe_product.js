const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

async function setupStripeProduct() {
  try {
    console.log('Creating ARTIQ Pro subscription product...');
    
    // Create product
    const product = await stripe.products.create({
      name: 'ARTIQ Pro',
      description: 'Professional tier with unlimited exports and no watermarks',
    });
    
    console.log('✅ Product created:', product.id);
    
    // Create price (monthly subscription)
    const price = await stripe.prices.create({
      product: product.id,
      unit_amount: 999, // $9.99 per month
      currency: 'usd',
      recurring: {
        interval: 'month',
      },
    });
    
    console.log('✅ Price created:', price.id);
    console.log('\n📋 Add this to your .env file:');
    console.log(`STRIPE_PRICE_ID=${price.id}`);
    
    return { product, price };
  } catch (error) {
    console.error('❌ Error:', error.message);
    throw error;
  }
}

setupStripeProduct();
