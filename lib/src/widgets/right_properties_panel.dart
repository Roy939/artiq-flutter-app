import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:artiq_flutter/src/providers/canvas_state_provider.dart';

/// Right panel with properties, layers, and controls
class RightPropertiesPanel extends StatelessWidget {
  const RightPropertiesPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final canvasState = context.watch<CanvasStateProvider>();
    
    return Container(
      width: 300,
      color: Colors.grey[100],
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: const Text(
              'Properties',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          
          // Undo/Redo buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: canvasState.canUndo ? canvasState.undo : null,
                    icon: const Icon(Icons.undo),
                    label: const Text('Undo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: canvasState.canRedo ? canvasState.redo : null,
                    icon: const Icon(Icons.redo),
                    label: const Text('Redo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Color picker
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Color',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _showColorPicker(context, canvasState),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: canvasState.currentColor,
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Tap to change color',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Stroke width slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stroke Width: ${canvasState.currentStrokeWidth.toInt()}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: canvasState.currentStrokeWidth,
                  min: 1,
                  max: 20,
                  divisions: 19,
                  activeColor: Colors.deepPurple,
                  onChanged: (value) => canvasState.setStrokeWidth(value),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Clear canvas button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showClearConfirmation(context, canvasState),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Clear Canvas'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Layers section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Layers',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${canvasState.elements.length} items',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Layers list
          Expanded(
            child: canvasState.elements.isEmpty
                ? Center(
                    child: Text(
                      'No layers yet\nStart drawing!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: canvasState.elements.length,
                    itemBuilder: (context, index) {
                      final element = canvasState.elements[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            _getIconForElementType(element.type),
                            color: element.color,
                          ),
                          title: Text(_getNameForElementType(element.type)),
                          subtitle: element.type == ElementType.text
                              ? Text(element.text, maxLines: 1, overflow: TextOverflow.ellipsis)
                              : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => canvasState.removeElement(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context, CanvasStateProvider canvasState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: canvasState.currentColor,
            onColorChanged: (color) => canvasState.setColor(color),
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, CanvasStateProvider canvasState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Canvas?'),
        content: const Text('This will remove all elements. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              canvasState.clearCanvas();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  IconData _getIconForElementType(ElementType type) {
    switch (type) {
      case ElementType.path:
        return Icons.edit;
      case ElementType.rectangle:
        return Icons.crop_square;
      case ElementType.circle:
        return Icons.circle_outlined;
      case ElementType.line:
        return Icons.remove;
      case ElementType.text:
        return Icons.text_fields;
    }
  }

  String _getNameForElementType(ElementType type) {
    switch (type) {
      case ElementType.path:
        return 'Drawing';
      case ElementType.rectangle:
        return 'Rectangle';
      case ElementType.circle:
        return 'Circle';
      case ElementType.line:
        return 'Line';
      case ElementType.text:
        return 'Text';
    }
  }
}
