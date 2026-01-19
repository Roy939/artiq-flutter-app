import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:artiq_flutter/src/services/auth_service.dart';
import 'package:artiq_flutter/src/screens/design_gallery_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ARTIQ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
            },
          ),
        ],
      ),
      body: const DesignGalleryScreen(),
    );
  }
}
