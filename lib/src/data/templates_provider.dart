import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:artiq_flutter/src/models/template.dart';
import 'package:artiq_flutter/src/utils/template_loader.dart';

// Provider for templates - loads from JSON files
final templatesProvider = FutureProvider<List<DesignTemplate>>((ref) async {
  return await TemplateLoader.loadAllTemplates();
});

// Provider for filtered templates by category
final filteredTemplatesProvider = Provider.family<List<DesignTemplate>, String?>((ref, category) {
  final templatesAsync = ref.watch(templatesProvider);
  
  return templatesAsync.when(
    data: (templates) {
      if (category == null || category == 'All') {
        return templates;
      }
      return templates.where((t) => t.category == category).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Provider for template categories
final templateCategoriesProvider = Provider<List<String>>((ref) {
  final templatesAsync = ref.watch(templatesProvider);
  
  return templatesAsync.when(
    data: (templates) {
      final categories = templates.map((t) => t.category).toSet().toList();
      categories.sort();
      return ['All', ...categories];
    },
    loading: () => ['All'],
    error: (_, __) => ['All'],
  );
});
