import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:artiq_flutter/src/widgets/left_tools_panel.dart';
import 'package:artiq_flutter/src/widgets/interactive_canvas.dart';
import 'package:artiq_flutter/src/widgets/right_properties_panel.dart';
import 'package:artiq_flutter/src/providers/canvas_state_provider.dart';

/// Three-panel editor layout: left tools, center canvas, right properties
class ThreePanelEditor extends StatelessWidget {
  const ThreePanelEditor({Key? key}) : super(key: key);

  // Template list with categories and icons
  static final List<Map<String, dynamic>> templates = [
    {
      'id': 'instagram_post',
      'title': 'Instagram Post',
      'category': 'Social Media',
      'icon': Icons.photo_camera,
      'color': Color(0xFF6366F1),
    },
    {
      'id': 'business_presentation',
      'title': 'Business Presentation',
      'category': 'Presentations',
      'icon': Icons.present_to_all,
      'color': Color(0xFF8B5CF6),
    },
    {
      'id': 'facebook_ad',
      'title': 'Facebook Ad',
      'category': 'Marketing',
      'icon': Icons.campaign,
      'color': Color(0xFFEC4899),
    },
    {
      'id': 'linkedin_banner',
      'title': 'LinkedIn Banner',
      'category': 'Social Media',
      'icon': Icons.business,
      'color': Color(0xFF06B6D4),
    },
    {
      'id': 'product_flyer',
      'title': 'Product Flyer',
      'category': 'Marketing',
      'icon': Icons.local_offer,
      'color': Color(0xFFF97316),
    },
    {
      'id': 'business_card',
      'title': 'Business Card',
      'category': 'Business',
      'icon': Icons.badge,
      'color': Color(0xFF14B8A6),
    },
    {
      'id': 'youtube_thumbnail',
      'title': 'YouTube Thumbnail',
      'category': 'Social Media',
      'icon': Icons.play_circle_outline,
      'color': Color(0xFFEF4444),
    },
    {
      'id': 'twitter_post',
      'title': 'Twitter Post',
      'category': 'Social Media',
      'icon': Icons.chat_bubble_outline,
      'color': Color(0xFF3B82F6),
    },
    {
      'id': 'email_header',
      'title': 'Email Header',
      'category': 'Business',
      'icon': Icons.email,
      'color': Color(0xFF6366F1),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ARTIQ Editor'),
        backgroundColor: Colors.deepPurple,
        actions: [
          // Templates dropdown button
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PopupMenuButton<String>(
              tooltip: 'Load a template',
              offset: const Offset(0, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (String templateId) {
                final canvasState = Provider.of<CanvasStateProvider>(context, listen: false);
                final template = templates.firstWhere((t) => t['id'] == templateId);
                
                try {
                  canvasState.loadTemplate(templateId);
                  
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Text('✨ Loaded: ${template['title']}'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                } catch (e) {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 12),
                          Text('Failed to load template: $e'),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }
              },
              itemBuilder: (BuildContext context) {
                return templates.map((template) {
                  return PopupMenuItem<String>(
                    value: template['id'],
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: (template['color'] as Color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              template['icon'] as IconData,
                              size: 20,
                              color: template['color'] as Color,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  template['title']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  template['category']!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.collections, size: 20, color: Colors.deepPurple),
                    SizedBox(width: 8),
                    Text(
                      'Load Template',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, size: 20, color: Colors.deepPurple),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: const [
          // Left tools panel
          LeftToolsPanel(),
          
          // Center canvas
          Expanded(
            flex: 3,
            child: InteractiveCanvas(),
          ),
          
          // Right properties panel
          RightPropertiesPanel(),
        ],
      ),
    );
  }
}
