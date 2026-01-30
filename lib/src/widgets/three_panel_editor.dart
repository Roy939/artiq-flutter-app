import 'package:flutter/material.dart';
import 'package:artiq_flutter/src/widgets/left_tools_panel.dart';
import 'package:artiq_flutter/src/widgets/interactive_canvas.dart';
import 'package:artiq_flutter/src/widgets/right_properties_panel.dart';

/// Three-panel editor layout: left tools, center canvas, right properties
class ThreePanelEditor extends StatelessWidget {
  const ThreePanelEditor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ARTIQ Editor'),
        backgroundColor: Colors.deepPurple,
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
