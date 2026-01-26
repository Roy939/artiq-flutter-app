import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../models/subscription_model.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
        backgroundColor: Colors.black,
      ),
      body: Consumer<SubscriptionProvider>(
        builder: (context, subscriptionProvider, child) {
          if (subscriptionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final subscription = subscriptionProvider.subscription;
          final isPro = subscription?.isPro ?? false;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Current Plan
                _buildCurrentPlanCard(isPro),
                const SizedBox(height: 32),

                // Free Tier Card
                _buildPlanCard(
                  context,
                  title: 'Free',
                  price: '\$0',
                  period: 'forever',
                  features: [
                    '5 designs maximum',
                    'Basic templates (first 10)',
                    'Watermark on exports',
                    'PNG export only',
                    '2 fonts',
                  ],
                  isCurrentPlan: !isPro,
                  onTap: null, // Can't downgrade to free
                ),
                const SizedBox(height: 16),

                // Pro Tier Card
                _buildPlanCard(
                  context,
                  title: 'Pro',
                  price: '\$8.99',
                  period: 'per month',
                  features: [
                    'Unlimited designs',
                    'All 20+ templates',
                    'No watermarks',
                    'Image upload',
                    '8 professional fonts',
                    'Export PNG, JPG, PDF',
                    'Priority support',
                  ],
                  isCurrentPlan: isPro,
                  isPro: true,
                  onTap: isPro ? null : () => _upgradeToPro(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentPlanCard(bool isPro) {
    return Card(
      color: isPro ? Colors.blue.shade50 : Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              isPro ? Icons.star : Icons.free_breakfast,
              size: 48,
              color: isPro ? Colors.blue : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              isPro ? 'Pro Member' : 'Free Plan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isPro ? Colors.blue : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isPro ? 'Thank you for your support!' : 'Upgrade to unlock all features',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required bool isCurrentPlan,
    bool isPro = false,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: isPro ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isPro
            ? const BorderSide(color: Colors.blue, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isPro ? Colors.blue : Colors.black,
                  ),
                ),
                if (isPro)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'POPULAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    period,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: isPro ? Colors.blue : Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isCurrentPlan ? null : onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPro ? Colors.blue : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isCurrentPlan ? 'Current Plan' : 'Upgrade to $title',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _upgradeToPro(BuildContext context) async {
    // For now, show a message that Stripe checkout will be implemented
    // In production, this would open Stripe Checkout
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade to Pro'),
        content: const Text(
          'Stripe checkout integration is being set up. '
          'You will be redirected to a secure payment page to complete your subscription.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
