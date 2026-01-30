import 'package:flutter/material.dart';
import 'package:artiq_flutter/src/widgets/left_tools_panel.dart';
import 'package:artiq_flutter/src/widgets/interactive_canvas.dart';

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
        children: [
          // Left Panel - Tools
          const LeftToolsPanel(),
          
          // Center Panel - Interactive Canvas
          const Expanded(
            child: InteractiveCanvas(),
          ),
          
          // Right Panel - Properties/Layers
          Container(
            width: 300,
            color: Colors.grey[100],
            child: const Center(
              child: Text(
                'Properties',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
