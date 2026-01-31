import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:html' as html;
import 'package:artiq_flutter/src/widgets/left_tools_panel.dart';
import 'package:artiq_flutter/src/widgets/interactive_canvas.dart';
import 'package:artiq_flutter/src/widgets/right_properties_panel.dart';
import 'package:artiq_flutter/src/providers/canvas_state_provider.dart';
import 'package:artiq_flutter/src/utils/canvas_export_util.dart';

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
          // Upload Image button
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () async {
                final canvasState = Provider.of<CanvasStateProvider>(context, listen: false);
                
                // Create file input element
                final input = html.FileUploadInputElement()..accept = 'image/*';
                input.click();
                
                input.onChange.listen((e) async {
                  final files = input.files;
                  if (files != null && files.isNotEmpty) {
                    final file = files[0];
                    final reader = html.FileReader();
                    
                    reader.onLoadEnd.listen((e) async {
                      try {
                        final dataUrl = reader.result as String;
                        // Extract base64 data (remove data:image/...;base64, prefix)
                        final base64Data = dataUrl.split(',')[1];
                        
                        // Add image to canvas at center
                        canvasState.addImage(
                          base64Data,
                          const Offset(440, 440), // Center of 1080x1080 canvas
                          width: 200,
                          height: 200,
                        );
                        
                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: const [
                                Icon(Icons.check_circle, color: Colors.white),
                                SizedBox(width: 12),
                                Text('🖼️ Image uploaded successfully!'),
                              ],
                            ),
                            backgroundColor: Colors.blue,
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
                                Text('Upload failed: $e'),
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
                    });
                    
                    reader.readAsDataUrl(file);
                  }
                });
              },
              icon: const Icon(Icons.upload_file, size: 18),
              label: const Text('Upload Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          // Export button
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () async {
                final canvasState = Provider.of<CanvasStateProvider>(context, listen: false);
                
                try {
                  await CanvasExportUtil.exportToPNG(
                    elements: canvasState.elements,
                    width: canvasState.canvasWidth,
                    height: canvasState.canvasHeight,
                    filename: 'artiq_design_${DateTime.now().millisecondsSinceEpoch}',
                  );
                  
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: const [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Text('✅ Design exported successfully!'),
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
                          Text('Export failed: $e'),
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
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Export PNG'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          // Canvas size dropdown
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PopupMenuButton<String>(
              tooltip: 'Canvas Size',
              offset: const Offset(0, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (String sizeId) {
                final canvasState = Provider.of<CanvasStateProvider>(context, listen: false);
                
                // Parse size
                final sizes = {
                  'instagram_square': [1080.0, 1080.0],
                  'instagram_story': [1080.0, 1920.0],
                  'facebook_post': [1200.0, 630.0],
                  'facebook_cover': [820.0, 312.0],
                  'twitter_post': [1200.0, 675.0],
                  'twitter_header': [1500.0, 500.0],
                  'linkedin_post': [1200.0, 627.0],
                  'linkedin_banner': [1584.0, 396.0],
                  'youtube_thumbnail': [1280.0, 720.0],
                  'pinterest_pin': [1000.0, 1500.0],
                };
                
                if (sizes.containsKey(sizeId)) {
                  canvasState.setCanvasSize(sizes[sizeId]![0], sizes[sizeId]![1]);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Canvas resized to ${sizes[sizeId]![0].toInt()}x${sizes[sizeId]![1].toInt()}'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.aspect_ratio, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Canvas Size',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
                  ],
                ),
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  enabled: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'Instagram',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ),
                ),
                const PopupMenuItem(
                  value: 'instagram_square',
                  child: Text('Square (1080x1080)'),
                ),
                const PopupMenuItem(
                  value: 'instagram_story',
                  child: Text('Story (1080x1920)'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  enabled: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'Facebook',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ),
                ),
                const PopupMenuItem(
                  value: 'facebook_post',
                  child: Text('Post (1200x630)'),
                ),
                const PopupMenuItem(
                  value: 'facebook_cover',
                  child: Text('Cover (820x312)'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  enabled: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'Twitter/X',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ),
                ),
                const PopupMenuItem(
                  value: 'twitter_post',
                  child: Text('Post (1200x675)'),
                ),
                const PopupMenuItem(
                  value: 'twitter_header',
                  child: Text('Header (1500x500)'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  enabled: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'LinkedIn',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ),
                ),
                const PopupMenuItem(
                  value: 'linkedin_post',
                  child: Text('Post (1200x627)'),
                ),
                const PopupMenuItem(
                  value: 'linkedin_banner',
                  child: Text('Banner (1584x396)'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  enabled: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'Other',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ),
                ),
                const PopupMenuItem(
                  value: 'youtube_thumbnail',
                  child: Text('YouTube Thumbnail (1280x720)'),
                ),
                const PopupMenuItem(
                  value: 'pinterest_pin',
                  child: Text('Pinterest Pin (1000x1500)'),
                ),
              ],
            ),
          ),
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
