import 'package:flutter/material.dart';

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
          Container(
            width: 80,
            color: Colors.grey[200],
            child: const Center(
              child: Text(
                'Tools',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          
          // Center Panel - Canvas
          Expanded(
            child: Container(
              color: Colors.white,
              child: const Center(
                child: Text(
                  'Canvas',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ),
            ),
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
