import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:artiq_flutter/src/services/auth_service.dart';
import 'package:artiq_flutter/src/screens/design_gallery_screen.dart';
import 'package:artiq_flutter/src/providers/subscription_provider.dart';
import 'package:artiq_flutter/src/providers/demo_mode_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh subscription when app resumes (user returns from Stripe Checkout)
    if (state == AppLifecycleState.resumed) {
      provider.Provider.of<SubscriptionProvider>(context, listen: false)
          .loadSubscription();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    final demoModeProvider = provider.Provider.of<DemoModeProvider>(context);
    final isDemoMode = demoModeProvider.isDemoMode;
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ARTIQ'),
        backgroundColor: isDemoMode ? Colors.orange : null,
        actions: [
          if (isDemoMode)
            ElevatedButton.icon(
              onPressed: () {
                demoModeProvider.disableDemoMode();
              },
              icon: const Icon(Icons.login, size: 18),
              label: const Text('Sign Up to Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          if (!isDemoMode)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await authService.signOut();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          if (isDemoMode)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.orange.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  const Flexible(
                    child: Text(
                      'Demo Mode: Your work won\'t be saved. Sign up to save and export your designs!',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          const Expanded(
            child: DesignGalleryScreen(),
          ),
        ],
      ),
    );
  }
}
