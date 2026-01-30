import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:artiq_flutter/src/widgets/left_tools_panel.dart';
import 'package:artiq_flutter/src/widgets/interactive_canvas.dart';
import 'package:artiq_flutter/src/widgets/right_properties_panel.dart';
import 'package:artiq_flutter/src/widgets/template_gallery_modal.dart';
import 'package:artiq_flutter/src/providers/canvas_state_provider.dart';

/// Three-panel editor layout: left tools, center canvas, right properties
class ThreePanelEditor extends StatelessWidget {
  const ThreePanelEditor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ARTIQ Editor'),
        backgroundColor: Colors.deepPurple,
        actions: [
          // Browse Templates button
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () async {
                // Get Provider reference BEFORE showing dialog
                final canvasState = Provider.of<CanvasStateProvider>(context, listen: false);
                
                final template = await showDialog(
                  context: context,
                  builder: (context) => const TemplateGalleryModal(),
                );
                if (template != null && template['id'] != null) {
                  try {
                    // Load template into canvas
                    canvasState.loadTemplate(template['id']);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✨ Loaded: ${template['title']}'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error loading template: $e'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.collections, size: 20),
              label: const Text('Browse Templates'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.deepPurple,
                elevation: 2,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: const [
          // Left Panel - Tools
          LeftToolsPanel(),
          
          // Center Panel - Interactive Canvas
          Expanded(
            child: InteractiveCanvas(),
          ),
          
          // Right Panel - Properties/Layers
          RightPropertiesPanel(),
        ],
      ),
    );
  }
}
