import 'package:flutter/material.dart';
import '../utils/responsive_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:artiq_flutter/src/data/designs_provider.dart';
import 'package:artiq_flutter/src/models/design.dart';
import 'package:artiq_flutter/src/services/sync_service.dart';
import 'package:artiq_flutter/src/screens/create_design_screen.dart';

class DesignGalleryScreen extends ConsumerWidget {
  const DesignGalleryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final designs = ref.watch(designsProvider);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveLayout.getMaxContentWidth(context),
          ),
          child: RefreshIndicator(
        onRefresh: () async {
          await ref.read(syncServiceProvider).syncDesigns();
          await ref.read(designsProvider.notifier).refreshDesigns();
        },
        child: ListView.builder(
          itemCount: designs.length,
          itemBuilder: (context, index) {
            final design = designs[index];
            return ListTile(
              title: Text(design.title),
              subtitle: Text('Last updated: ${design.updatedAt}'),
              trailing: design.isSynced
                  ? const Icon(Icons.sync, color: Colors.green)
                  : const Icon(Icons.sync_problem, color: Colors.orange),
              onTap: () {
                // Navigate to design editor
              },
            );
          },
        ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CreateDesignScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
