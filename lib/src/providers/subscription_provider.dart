import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../models/subscription_model.dart';

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
        debugPrint('[ARTIQ DEBUG] Parsed subscription - tier: ${_subscription?.tier}, isPro: ${_subscription?.isPro}, isActive: ${_subscription?.isActive}');
      } else {
        // Create default free subscription
        _subscription = UserSubscription(
          userId: user.uid,
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
}
