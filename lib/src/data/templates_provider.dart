import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:artiq_flutter/src/models/template.dart';

// Provider for templates
final templatesProvider = Provider<List<DesignTemplate>>((ref) {
  return [
    // Blank Canvas
    const DesignTemplate(
      id: 'blank_800x600',
      name: 'Blank Canvas',
      category: 'Blank',
      width: 800,
      height: 600,
      description: 'Standard blank canvas for free drawing',
    ),
    
    // Social Media - Instagram Post
    const DesignTemplate(
      id: 'instagram_post',
      name: 'Instagram Post',
      category: 'Social Media',
      width: 1080,
      height: 1080,
      description: 'Perfect square format for Instagram feed posts',
    ),
    
    // Social Media - Instagram Story
    const DesignTemplate(
      id: 'instagram_story',
      name: 'Instagram Story',
      category: 'Social Media',
      width: 1080,
      height: 1920,
      description: 'Vertical format for Instagram and Facebook stories',
    ),
    
    // Social Media - Facebook Cover
    const DesignTemplate(
      id: 'facebook_cover',
      name: 'Facebook Cover',
      category: 'Social Media',
      width: 820,
      height: 312,
      description: 'Wide format for Facebook page cover photos',
    ),
    
    // Marketing - Flyer
    const DesignTemplate(
      id: 'flyer_letter',
      name: 'Flyer (Letter)',
      category: 'Marketing',
      width: 816,  // 8.5 inches at 96 DPI
      height: 1056, // 11 inches at 96 DPI
      description: 'Standard US Letter size for printable flyers',
    ),
  ];
});

// Provider for template categories
final templateCategoriesProvider = Provider<List<String>>((ref) {
  final templates = ref.watch(templatesProvider);
  return templates.map((t) => t.category).toSet().toList()..sort();
});

// Provider for templates by category
final templatesByCategoryProvider = Provider.family<List<DesignTemplate>, String>(
  (ref, category) {
    final templates = ref.watch(templatesProvider);
    if (category == 'All') return templates;
    return templates.where((t) => t.category == category).toList();
  },
);
