import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../models/subscription_model.dart';
import '../models/promo_code_model.dart';

class SubscriptionProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  UserSubscription? _subscription;
  bool _isLoading = false;

  UserSubscription? get subscription => _subscription;
  bool get isLoading => _isLoading;
  bool get isPro => _subscription?.isPro ?? false;
  bool get isFree => _subscription?.isFree ?? true;

  Future<void> loadSubscription() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Force fetch from server to get latest subscription status
      // This is critical for Flutter Web to bypass offline cache after payment
      final doc = await _firestore
          .collection('subscriptions')
          .doc(user.uid)
          .get(const GetOptions(source: Source.server));

      if (doc.exists) {
        debugPrint('[ARTIQ DEBUG] Raw Firestore data: ${doc.data()}');
        _subscription = UserSubscription.fromJson(doc.data()!);
        debugPrint('[ARTIQ DEBUG] Parsed subscription - tier: ${_subscription?.tier}, isPro: ${_subscription?.isPro}, isActive: ${_subscription?.isActive}, isAdmin: ${_subscription?.isAdmin}');
      } else {
        // Create default free subscription
        _subscription = UserSubscription(
          userId: user.uid,
          userEmail: user.email ?? '',
          tier: SubscriptionTier.free,
          isActive: true,
        );
        await _firestore
            .collection('subscriptions')
            .doc(user.uid)
            .set(_subscription!.toJson());
      }
    } catch (e) {
      debugPrint('[ARTIQ ERROR] Failed to load subscription: $e');
      // Default to free tier on error
      _subscription = UserSubscription(
        userId: user.uid ?? '',
        userEmail: user.email ?? '',
        tier: SubscriptionTier.free,
        isActive: true,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSubscription(UserSubscription subscription) async {
    try {
      await _firestore
          .collection('subscriptions')
          .doc(subscription.userId)
          .set(subscription.toJson());
      
      _subscription = subscription;
      notifyListeners();
    } catch (e) {
      debugPrint('[ARTIQ ERROR] Failed to update subscription: $e');
      rethrow;
    }
  }

  Future<bool> canCreateDesign(int currentDesignCount) async {
    if (_subscription == null) {
      await loadSubscription();
    }

    final maxDesigns = _subscription?.maxDesigns ?? 5;
    if (maxDesigns == -1) return true; // Unlimited
    
    return currentDesignCount < maxDesigns;
  }

  bool canExportFormat(String format) {
    if (_subscription == null) return false;
    
    switch (format.toLowerCase()) {
      case 'png':
        return true; // Always available
      case 'jpg':
      case 'jpeg':
        return _subscription!.canExportJPG;
      case 'pdf':
        return _subscription!.canExportPDF;
      default:
        return false;
    }
  }

  bool canUseFont(String fontFamily) {
    if (_subscription == null) return fontFamily == 'Roboto';
    return _subscription!.availableFonts.contains(fontFamily);
  }

  SubscriptionTier get currentTier => _subscription?.tier ?? SubscriptionTier.free;

  Future<void> openCheckout(BuildContext context) async {
    final user = _auth.currentUser;
    if (user == null) {
      _showError(context, 'Please log in to upgrade');
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Get Firebase ID token for authentication
      final idToken = await user.getIdToken();
      
      // Call Firebase Cloud Function to create Stripe Checkout Session
      final response = await http.post(
        Uri.parse('https://us-central1-artiq-1ebb2.cloudfunctions.net/createCheckoutSession'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: json.encode({
          'successUrl': 'https://roy939.github.io/artiq-flutter-app/?success=true',
          'cancelUrl': 'https://roy939.github.io/artiq-flutter-app/?canceled=true',
        }),
      );

      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final checkoutUrl = data['url'];
        
        // Open Stripe Checkout in browser
        final uri = Uri.parse(checkoutUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            _showError(context, 'Could not open checkout page');
          }
        }
      } else {
        if (context.mounted) {
          _showError(context, 'Failed to create checkout session: ${response.body}');
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) Navigator.pop(context);
      
      if (context.mounted) {
        _showError(context, 'Error: $e');
      }
      debugPrint('[ARTIQ ERROR] Failed to open checkout: $e');
    }
  }

  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> cancelSubscription(BuildContext context) async {
    final user = _auth.currentUser;
    if (user == null) {
      _showError(context, 'Please log in to cancel subscription');
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Get Firebase ID token for authentication
      final idToken = await user.getIdToken();
      
      // Call Firebase Cloud Function to cancel subscription
      final response = await http.post(
        Uri.parse('https://us-central1-artiq-1ebb2.cloudfunctions.net/cancelSubscription'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        // Reload subscription to get updated status
        await loadSubscription();
        
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Subscription Canceled'),
              content: const Text('Your subscription has been canceled. You will retain Pro access until the end of your billing period.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        if (context.mounted) {
          _showError(context, 'Failed to cancel subscription: ${response.body}');
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) Navigator.pop(context);
      
      if (context.mounted) {
        _showError(context, 'Error: $e');
      }
      debugPrint('[ARTIQ ERROR] Failed to cancel subscription: $e');
    }
  }

  Future<bool> applyPromoCode(String code) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    // Validate promo code
    final promoCode = PromoCodes.validate(code);
    if (promoCode == null) {
      debugPrint('[ARTIQ DEBUG] Invalid promo code: $code');
      return false;
    }

    try {
      // Calculate subscription end date
      final now = DateTime.now();
      final endDate = DateTime(now.year, now.month + promoCode.durationMonths, now.day);

      // Create updated subscription with promo code benefits
      final updatedSubscription = UserSubscription(
        userId: user.uid,
        userEmail: user.email ?? '',
        tier: promoCode.tier,
        subscriptionStart: now,
        subscriptionEnd: endDate,
        isActive: true,
      );

      // Save to Firestore
      await updateSubscription(updatedSubscription);

      debugPrint('[ARTIQ DEBUG] Promo code applied successfully: $code');
      return true;
    } catch (e) {
      debugPrint('[ARTIQ ERROR] Failed to apply promo code: $e');
      return false;
    }
  }

  Future<void> openCustomerPortal(BuildContext context) async {
    final user = _auth.currentUser;
    if (user == null) {
      _showError(context, 'Please log in to manage billing');
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Get Firebase ID token for authentication
      final idToken = await user.getIdToken();
      
      // Call Firebase Cloud Function to create Customer Portal Session
      final response = await http.post(
        Uri.parse('https://us-central1-artiq-1ebb2.cloudfunctions.net/createCustomerPortalSession'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final portalUrl = data['url'];
        
        // Open Stripe Customer Portal in browser
        final uri = Uri.parse(portalUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            _showError(context, 'Could not open customer portal');
          }
        }
      } else {
        if (context.mounted) {
          _showError(context, 'Failed to open customer portal: ${response.body}');
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) Navigator.pop(context);
      
      if (context.mounted) {
        _showError(context, 'Error: $e');
      }
      debugPrint('[ARTIQ ERROR] Failed to open customer portal: $e');
    }
  }
}
