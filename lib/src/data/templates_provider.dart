import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:artiq_flutter/src/models/template.dart';
import 'package:artiq_flutter/src/models/canvas_models.dart';

// Provider for templates
final templatesProvider = Provider<List<DesignTemplate>>((ref) {
  return [
    // Blank Canvas
    DesignTemplate(
      id: 'blank_800x600',
      name: 'Blank Canvas',
      category: 'Blank',
      width: 800,
      height: 600,
      description: 'Standard blank canvas for free drawing',
      elements: const [],
    ),
    
    // Social Media - Instagram Post
    DesignTemplate(
      id: 'instagram_post',
      name: 'Instagram Post',
      category: 'Social Media',
      width: 1080,
      height: 1080,
      description: 'Perfect square format for Instagram feed posts',
      elements: [
        // Gradient background
        DrawingRectangle(
          id: 'bg_rect',
          color: const Color(0xFF6366F1), // Indigo
          strokeWidth: 0,
          createdAt: DateTime.now(),
          topLeft: const Offset(0, 0),
          bottomRight: const Offset(1080, 1080),
        ),
        // Title placeholder
        DrawingText(
          id: 'title_text',
          text: 'Your Title Here',
          position: const Offset(540, 400),
          color: Colors.white,
          strokeWidth: 1,
          fontSize: 72,
          createdAt: DateTime.now(),
        ),
        // Subtitle placeholder
        DrawingText(
          id: 'subtitle_text',
          text: 'Add your caption',
          position: const Offset(540, 680),
          color: Colors.white70,
          strokeWidth: 1,
          fontSize: 36,
          createdAt: DateTime.now(),
        ),
      ],
    ),
    
    // Social Media - Instagram Story
    DesignTemplate(
      id: 'instagram_story',
      name: 'Instagram Story',
      category: 'Social Media',
      width: 1080,
      height: 1920,
      description: 'Vertical format for Instagram and Facebook stories',
      elements: [
        // Purple gradient background
        DrawingRectangle(
          id: 'bg_rect',
          color: const Color(0xFF8B5CF6), // Purple
          strokeWidth: 0,
          createdAt: DateTime.now(),
          topLeft: const Offset(0, 0),
          bottomRight: const Offset(1080, 1920),
        ),
        // Main text
        DrawingText(
          id: 'main_text',
          text: 'Your Story',
          position: const Offset(540, 960),
          color: Colors.white,
          strokeWidth: 1,
          fontSize: 96,
          createdAt: DateTime.now(),
        ),
      ],
    ),
    
    // Social Media - Facebook Cover
    DesignTemplate(
      id: 'facebook_cover',
      name: 'Facebook Cover',
      category: 'Social Media',
      width: 820,
      height: 312,
      description: 'Wide format for Facebook page cover photos',
      elements: [
        // Blue background
        DrawingRectangle(
          id: 'bg_rect',
          color: const Color(0xFF3B82F6), // Blue
          strokeWidth: 0,
          createdAt: DateTime.now(),
          topLeft: const Offset(0, 0),
          bottomRight: const Offset(820, 312),
        ),
        // Page name
        DrawingText(
          id: 'page_name',
          text: 'Your Page Name',
          position: const Offset(410, 156),
          color: Colors.white,
          strokeWidth: 1,
          fontSize: 64,
          createdAt: DateTime.now(),
        ),
      ],
    ),
    
    // Marketing - Flyer
    DesignTemplate(
      id: 'flyer_letter',
      name: 'Flyer (Letter)',
      category: 'Marketing',
      width: 816,  // 8.5 inches at 96 DPI
      height: 1056, // 11 inches at 96 DPI
      description: 'Standard US Letter size for printable flyers',
      elements: [
        // White background with colored header
        DrawingRectangle(
          id: 'bg_rect',
          color: Colors.white,
          strokeWidth: 0,
          createdAt: DateTime.now(),
          topLeft: const Offset(0, 0),
          bottomRight: const Offset(816, 1056),
        ),
        // Header rectangle
        DrawingRectangle(
          id: 'header_rect',
          color: const Color(0xFFEF4444), // Red
          strokeWidth: 0,
          createdAt: DateTime.now(),
          topLeft: const Offset(0, 0),
          bottomRight: const Offset(816, 200),
        ),
        // Title
        DrawingText(
          id: 'title',
          text: 'Event Title',
          position: const Offset(408, 100),
          color: Colors.white,
          strokeWidth: 1,
          fontSize: 64,
          createdAt: DateTime.now(),
        ),
        // Body text
        DrawingText(
          id: 'body',
          text: 'Add your event details here',
          position: const Offset(408, 400),
          color: Colors.black87,
          strokeWidth: 1,
          fontSize: 32,
          createdAt: DateTime.now(),
        ),
        // Date/time
        DrawingText(
          id: 'date',
          text: 'Date & Time',
          position: const Offset(408, 600),
          color: Colors.black54,
          strokeWidth: 1,
          fontSize: 28,
          createdAt: DateTime.now(),
        ),
      ],
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
