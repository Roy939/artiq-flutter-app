import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:artiq_flutter/src/screens/auth_wrapper.dart';
import 'package:artiq_flutter/src/providers/subscription_provider.dart';
import 'package:artiq_flutter/src/providers/demo_mode_provider.dart';
import 'package:artiq_flutter/src/providers/canvas_state_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Force enable semantics for web - this makes buttons clickable!
  // Without this, Flutter web doesn't create interactive DOM elements
  SemanticsBinding.instance.ensureSemantics();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => DemoModeProvider()),
        ChangeNotifierProvider(create: (_) => CanvasStateProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARTIQ',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(),
    );
  }
}
