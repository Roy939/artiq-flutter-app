import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart' as provider;
import 'package:artiq_flutter/src/screens/login_screen.dart';
import 'package:artiq_flutter/src/screens/home_screen.dart';
import 'package:artiq_flutter/src/providers/subscription_provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasData) {
          // Load subscription when user is logged in
          WidgetsBinding.instance.addPostFrameCallback((_) {
            provider.Provider.of<SubscriptionProvider>(context, listen: false)
                .loadSubscription();
          });
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
