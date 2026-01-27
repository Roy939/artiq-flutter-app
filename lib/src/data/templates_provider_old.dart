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
          filled: true,
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
          filled: true,
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
          filled: true,
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
          filled: true,
        ),
        // Header rectangle
        DrawingRectangle(
          id: 'header_rect',
          color: const Color(0xFFEF4444), // Red
          strokeWidth: 0,
          createdAt: DateTime.now(),
          topLeft: const Offset(0, 0),
          bottomRight: const Offset(816, 200),
          filled: true,
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
    
    // Social Media - YouTube Thumbnail
    DesignTemplate(
      id: 'youtube_thumbnail',
      name: 'YouTube Thumbnail',
      category: 'Social Media',
      width: 1280,
      height: 720,
      description: 'HD format for YouTube video thumbnails',
      elements: [
        DrawingRectangle(
          id: 'bg_rect',
          color: const Color(0xFFFF0000), // YouTube Red
          strokeWidth: 0,
          createdAt: DateTime.now(),
          topLeft: const Offset(0, 0),
          bottomRight: const Offset(1280, 720),
          filled: true,
        ),
        DrawingText(
          id: 'title',
          text: 'VIDEO TITLE',
          position: const Offset(640, 360),
          color: Colors.white,
          strokeWidth: 2,
          fontSize: 96,
          createdAt: DateTime.now(),
        ),
      ],
    ),
    
    // Social Media - Twitter Header
    DesignTemplate(
      id: 'twitter_header',
      name: 'Twitter Header',
      category: 'Social Media',
      width: 1500,
      height: 500,
      description: 'Banner format for Twitter/X profile headers',
      elements: [
        DrawingRectangle(
          id: 'bg_rect',
          color: const Color(0xFF1DA1F2), // Twitter Blue
          strokeWidth: 0,
          createdAt: DateTime.now(),
          topLeft: const Offset(0, 0),
          bottomRight: const Offset(1500, 500),
          filled: true,
        ),
        DrawingText(
          id: 'name',
          text: 'Your Name',
          position: const Offset(750, 250),
          color: Colors.white,
          strokeWidth: 1,
          fontSize: 72,
          createdAt: DateTime.now(),
        ),
      ],
    ),
    
    // Social Media - LinkedIn Post
    DesignTemplate(
      id: 'linkedin_post',
      name: 'LinkedIn Post',
      category: 'Social Media',
      width: 1200,
      height: 1200,
      description: 'Square format for LinkedIn feed posts',
      elements: [
        DrawingRectangle(
          id: 'bg_rect',
          color: const Color(0xFF0A66C2), // LinkedIn Blue
          strokeWidth: 0,
          createdAt: DateTime.now(),
          topLeft: const Offset(0, 0),
          bottomRight: const Offset(1200, 1200),
          filled: true,
        ),
        DrawingText(
          id: 'title',
          text: 'Professional Post',
          position: const Offset(600, 600),
          color: Colors.white,
          strokeWidth: 1,
          fontSize: 64,
          createdAt: DateTime.now(),
        ),
      ],
    ),
    
    // Social Media - Pinterest Pin
    DesignTemplate(
      id: 'pinterest_pin',
      name: 'Pinterest Pin',
      category: 'Social Media',
      width: 1000,
      height: 1500,
      description: 'Vertical format for Pinterest pins',
      elements: [
        DrawingRectangle(
          id: 'bg_rect',
          color: const Color(0xFFE60023), // Pinterest Red
          strokeWidth: 0,
          createdAt: DateTime.now(),
          topLeft: const Offset(0, 0),
          bottomRight: const Offset(1000, 1500),
          filled: true,
        ),
        DrawingText(
          id: 'title',
          text: 'Pin Title',
          position: const Offset(500, 750),
          color: Colors.white,
          strokeWidth: 1,
          fontSize: 72,
          createdAt: DateTime.now(),
        ),
      ],
    ),
    
    // Social Media - TikTok Video Cover
    DesignTemplate(
      id: 'tiktok_cover',
      name: 'TikTok Cover',
      category: 'Social Media',
      width: 1080,
      height: 1920,
      description: 'Vertical format for TikTok video covers',
      elements: [
        DrawingRectangle(
          id: 'bg_rect',
          color: const Color(0xFF000000), // Black
          strokeWidth: 0,
          createdAt: DateTime.now(),
          topLeft: const Offset(0, 0),
          bottomRight: const Offset(1080, 1920),
          filled: true,
        ),
        DrawingText(
          id: 'title',
          text: 'Video Title',
          position: const Offset(540, 960),
          color: const Color(0xFFFF0050), // TikTok Pink
          strokeWidth: 2,
          fontSize: 96,
          createdAt: DateTime.now(),
        ),
      ],
    ),
    
    // Business - Business Card
    DesignTemplate(
      id: 'business_card',
      name: 'Business Card',
      category: 'Business',
      width: 336,  // 3.5 inches at 96 DPI
      height: 192, // 2 inches at 96 DPI
      description: 'Standard business card size',
      elements: [
        DrawingRectangle(
          id: 'bg_rect',
          color: Colors.white,
          strokeWidth: 2,
          createdAt: DateTime.now(),
          topLeft: const Offset(0, 0),
          bottomRight: const Offset(336, 192),
          filled: true,
        ),
        DrawingText(
          id: 'name',
          text: 'Your Name',
          position: const Offset(168, 70),
          color: Colors.black,
          strokeWidth: 1,
          fontSize: 24,
          createdAt: DateTime.now(),
        ),
        DrawingText(
          id: 'title',
          text: 'Job Title',
          position: const Offset(168, 120),
          color: Colors.black54,
          strokeWidth: 1,
          fontSize: 16,
          createdAt: DateTime.now(),
        ),
      ],
    ),
    
    // Business - Presentation Slide
    DesignTemplate(
      id: 'presentation_slide',
      name: 'Presentation Slide',
      category: 'Business',
      width: 1920,
      height: 1080,
      description: 'Full HD format for presentations',
      elements: [
        DrawingRectangle(
          id: 'bg_rect',
          color: Colors.white,
          strokeWidth: 0,
          createdAt: DateTime.now(),
          topLeft: const Offset(0, 0),
          bottomRight: const Offset(1920, 1080),
          filled: true,
        ),
        DrawingRectangle(
          id: 'header',
          color: const Color(0xFF1E40AF), // Dark Blue
          strokeWidth: 0,
          createdAt: DateTime.now(),
          topLeft: const Offset(0, 0),
          bottomRight: const Offset(1920, 150),
          filled: true,
        ),
        DrawingText(
          id: 'title',
          text: 'Slide Title',
          position: const Offset(960, 75),
          color: Colors.white,
          strokeWidth: 1,
          fontSize: 64,
          createdAt: DateTime.now(),
        ),
        DrawingText(
          id: 'content',
          text: 'Add your content here',
          position: const Offset(960, 540),
          color: Colors.black87,
          strokeWidth: 1,
          fontSize: 48,
          createdAt: DateTime.now(),
        ),
      ],
    ),
    
    // Business - Email Header
    DesignTemplate(
      id: 'email_header',
      name: 'Email Header',
      category: 'Business',
      width: 600,
      height: 200,
      description: 'Standard email newsletter header',
      elements: [
        DrawingRectangle(
          id: 'bg_rect',
          color: const Color(0xFF059669), // Green
          strokeWidth: 0,
          createdAt: DateTime.now(),
          topLeft: const Offset(0, 0),
          bottomRight: const Offset(600, 200),
          filled: true,
        ),
        DrawingText(
          id: 'title',
          text: 'Newsletter Title',
          position: const Offset(300, 100),
          color: Colors.white,
          strokeWidth: 1,
          fontSize: 48,
          createdAt: DateTime.now(),
        ),
      ],
    ),
    
    // Marketing - Poster (Portrait)
    DesignTemplate(
      id: 'poster_portrait',
      name: 'Poster (Portrait)',
      category: 'Marketing',
      width: 1728,  // 18 inches at 96 DPI
      height: 2304, // 24 inches at 96 DPI
      description: 'Large format poster for printing',
      elements: [
        DrawingRectangle(
          id: 'bg_rect',
          color: const Color(0xFFF59E0B), // Amber
          strokeWidth: 0,
          createdAt: DateTime.now(),
          topLeft: const Offset(0, 0),
          bottomRight: const Offset(1728, 2304),
          filled: true,
        ),
        DrawingText(
          id: 'title',
          text: 'EVENT POSTER',
          position: const Offset(864, 400),
          color: Colors.white,
          strokeWidth: 2,
          fontSize: 120,
          createdAt: DateTime.now(),
        ),
        DrawingText(
          id: 'subtitle',
          text: 'Add details here',
          position: const Offset(864, 1152),
          color: Colors.white,
          strokeWidth: 1,
          fontSize: 64,
          createdAt: DateTime.now(),
        ),
      ],
    ),
    
    // Marketing - Banner (Leaderboard)
    DesignTemplate(
      id: 'banner_leaderboard',
      name: 'Web Banner',
      category: 'Marketing',
      width: 728,
      height: 90,
      description: 'Standard leaderboard banner ad size',
      elements: [
        DrawingRectangle(
          id: 'bg_rect',
          color: const Color(0xFF7C3AED), // Violet
          strokeWidth: 0,
          createdAt: DateTime.now(),
          topLeft: const Offset(0, 0),
          bottomRight: const Offset(728, 90),
          filled: true,
        ),
        DrawingText(
          id: 'text',
          text: 'Your Ad Here',
          position: const Offset(364, 45),
          color: Colors.white,
          strokeWidth: 1,
          fontSize: 32,
          createdAt: DateTime.now(),
        ),
      ],
    ),
    
    // Marketing - Square Logo
    DesignTemplate(
      id: 'logo_square',
      name: 'Logo (Square)',
      category: 'Marketing',
      width: 500,
      height: 500,
      description: 'Square format for logos and icons',
      elements: [
        DrawingRectangle(
          id: 'bg_rect',
          color: Colors.white,
          strokeWidth: 2,
          createdAt: DateTime.now(),
          topLeft: const Offset(0, 0),
          bottomRight: const Offset(500, 500),
          filled: true,
        ),
        DrawingCircle(
          id: 'circle',
          color: const Color(0xFF10B981), // Emerald
          strokeWidth: 0,
          createdAt: DateTime.now(),
          center: const Offset(250, 250),
          radius: 150,
          filled: true,
        ),
        DrawingText(
          id: 'text',
          text: 'LOGO',
          position: const Offset(250, 250),
          color: Colors.white,
          strokeWidth: 1,
          fontSize: 64,
          createdAt: DateTime.now(),
        ),
      ],
    ),
    
    // Marketing - Brochure Cover
    DesignTemplate(
      id: 'brochure_cover',
      name: 'Brochure Cover',
      category: 'Marketing',
      width: 816,  // 8.5 inches at 96 DPI
      height: 1056, // 11 inches at 96 DPI
      description: 'Letter size brochure cover',
      elements: [
        DrawingRectangle(
          id: 'bg_rect',
          color: const Color(0xFF0891B2), // Cyan
          strokeWidth: 0,
          createdAt: DateTime.now(),
          topLeft: const Offset(0, 0),
          bottomRight: const Offset(816, 1056),
          filled: true,
        ),
        DrawingText(
          id: 'title',
          text: 'Company Brochure',
          position: const Offset(408, 400),
          color: Colors.white,
          strokeWidth: 1,
          fontSize: 72,
          createdAt: DateTime.now(),
        ),
        DrawingText(
          id: 'subtitle',
          text: 'Your tagline here',
          position: const Offset(408, 600),
          color: Colors.white70,
          strokeWidth: 1,
          fontSize: 36,
          createdAt: DateTime.now(),
        ),
      ],
    ),
    
    // Marketing - Certificate
    DesignTemplate(
      id: 'certificate',
      name: 'Certificate',
      category: 'Marketing',
      width: 1056, // 11 inches at 96 DPI (landscape)
      height: 816,  // 8.5 inches at 96 DPI
      description: 'Landscape certificate template',
      elements: [
        DrawingRectangle(
          id: 'bg_rect',
          color: Colors.white,
          strokeWidth: 8,
          createdAt: DateTime.now(),
          topLeft: const Offset(0, 0),
          bottomRight: const Offset(1056, 816),
          filled: true,
        ),
        DrawingRectangle(
          id: 'border',
          color: const Color(0xFFD97706), // Gold
          strokeWidth: 4,
          createdAt: DateTime.now(),
          topLeft: const Offset(40, 40),
          bottomRight: const Offset(1016, 776),
          filled: false,
        ),
        DrawingText(
          id: 'title',
          text: 'Certificate of Achievement',
          position: const Offset(528, 200),
          color: const Color(0xFFD97706),
          strokeWidth: 1,
          fontSize: 64,
          createdAt: DateTime.now(),
        ),
        DrawingText(
          id: 'name',
          text: 'Recipient Name',
          position: const Offset(528, 408),
          color: Colors.black87,
          strokeWidth: 1,
          fontSize: 48,
          createdAt: DateTime.now(),
        ),
      ],
    ),
    
    // Marketing - Menu (Restaurant)
    DesignTemplate(
      id: 'menu_restaurant',
      name: 'Restaurant Menu',
      category: 'Marketing',
      width: 816,  // 8.5 inches at 96 DPI
      height: 1056, // 11 inches at 96 DPI
      description: 'Letter size restaurant menu',
      elements: [
        DrawingRectangle(
          id: 'bg_rect',
          color: const Color(0xFFFEF3C7), // Light Yellow
          strokeWidth: 0,
          createdAt: DateTime.now(),
          topLeft: const Offset(0, 0),
          bottomRight: const Offset(816, 1056),
          filled: true,
        ),
        DrawingRectangle(
          id: 'header',
          color: const Color(0xFFDC2626), // Red
          strokeWidth: 0,
          createdAt: DateTime.now(),
          topLeft: const Offset(0, 0),
          bottomRight: const Offset(816, 150),
          filled: true,
        ),
        DrawingText(
          id: 'title',
          text: 'MENU',
          position: const Offset(408, 75),
          color: Colors.white,
          strokeWidth: 1,
          fontSize: 72,
          createdAt: DateTime.now(),
        ),
        DrawingText(
          id: 'section',
          text: 'Main Dishes',
          position: const Offset(408, 300),
          color: Colors.black87,
          strokeWidth: 1,
          fontSize: 48,
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
