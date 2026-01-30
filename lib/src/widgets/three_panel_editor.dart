import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:artiq_flutter/src/widgets/left_tools_panel.dart';
import 'package:artiq_flutter/src/widgets/interactive_canvas.dart';
import 'package:artiq_flutter/src/widgets/right_properties_panel.dart';
import 'package:artiq_flutter/src/providers/canvas_state_provider.dart';

/// Three-panel editor layout: left tools, center canvas, right properties
class ThreePanelEditor extends StatelessWidget {
  const ThreePanelEditor({Key? key}) : super(key: key);

  // Template list
  static final List<Map<String, String>> templates = [
    {'id': 'instagram_post', 'title': 'Instagram Post'},
    {'id': 'business_presentation', 'title': 'Business Presentation'},
    {'id': 'facebook_ad', 'title': 'Facebook Ad'},
    {'id': 'linkedin_banner', 'title': 'LinkedIn Banner'},
    {'id': 'product_flyer', 'title': 'Product Flyer'},
    {'id': 'business_card', 'title': 'Business Card'},
    {'id': 'youtube_thumbnail', 'title': 'YouTube Thumbnail'},
    {'id': 'twitter_post', 'title': 'Twitter Post'},
    {'id': 'email_header', 'title': 'Email Header'},
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
              onSelected: (String templateId) {
                print('🔍 DEBUG: Template selected: $templateId');
                final canvasState = Provider.of<CanvasStateProvider>(context, listen: false);
                try {
                  canvasState.loadTemplate(templateId);
                  print('🔍 DEBUG: Template loaded successfully');
                } catch (e, stack) {
                  print('🔍 DEBUG: Error loading template: $e');
                  print('🔍 DEBUG: Stack trace: $stack');
                }
              },
              itemBuilder: (BuildContext context) {
                return templates.map((template) {
                  return PopupMenuItem<String>(
                    value: template['id'],
                    child: Row(
                      children: [
                        const Icon(Icons.image, size: 20, color: Colors.deepPurple),
                        const SizedBox(width: 12),
                        Text(template['title']!),
                      ],
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
