import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import '../providers/subscription_provider.dart';
import '../models/subscription_model.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh subscription status when page loads
    // This ensures we get the latest status after returning from Stripe Checkout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final subscriptionProvider = provider.Provider.of<SubscriptionProvider>(context, listen: false);
      subscriptionProvider.loadSubscription();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
        backgroundColor: Colors.black,
      ),
      body: provider.Consumer<SubscriptionProvider>(
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
                  price: '\$9.99',
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
    final subscriptionProvider = provider.Provider.of<SubscriptionProvider>(context, listen: false);
    final subscription = subscriptionProvider.subscription;
    
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
            
            // Show subscription details for Pro users
            if (isPro && subscription != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              // Only show start date if it exists
              if (subscription.subscriptionStart != null) ...[
                _buildSubscriptionDetail(
                  icon: Icons.calendar_today,
                  label: 'Started',
                  value: _formatDate(subscription.subscriptionStart!),
                ),
                const SizedBox(height: 8),
              ],
              _buildSubscriptionDetail(
                icon: Icons.credit_card,
                label: 'Status',
                value: subscription.isActive ? 'Active' : 'Inactive',
              ),
              const SizedBox(height: 16),
              
              // Management buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openCustomerPortal(context),
                      icon: const Icon(Icons.settings),
                      label: const Text('Manage Billing'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmCancelSubscription(context),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancel'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildSubscriptionDetail({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
  
  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
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
    final subscriptionProvider = provider.Provider.of<SubscriptionProvider>(context, listen: false);
    await subscriptionProvider.openCheckout(context);
  }
}


  Future<void> _openCustomerPortal(BuildContext context) async {
    final subscriptionProvider = provider.Provider.of<SubscriptionProvider>(context, listen: false);
    await subscriptionProvider.openCustomerPortal(context);
  }

  Future<void> _confirmCancelSubscription(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription?'),
        content: const Text(
          'Are you sure you want to cancel your Pro subscription? You will retain access until the end of your current billing period.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Subscription'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Subscription'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final subscriptionProvider = provider.Provider.of<SubscriptionProvider>(context, listen: false);
      await subscriptionProvider.cancelSubscription(context);
    }
  }
