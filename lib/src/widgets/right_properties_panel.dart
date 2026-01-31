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
          
          // Element properties (shown when element is selected)
          if (canvasState.selectedElementIndex >= 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.edit, size: 16, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Editing Element',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Element color picker
                        const Text(
                          'Element Color',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => _showElementColorPicker(context, canvasState),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: canvasState.elements[canvasState.selectedElementIndex].color,
                              border: Border.all(color: Colors.grey[400]!),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Center(
                              child: Text(
                                'Change Color',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Duplicate button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              canvasState.duplicateSelectedElement();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Element duplicated'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            icon: const Icon(Icons.content_copy, size: 16),
                            label: const Text('Duplicate (Ctrl+D)'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Stroke width for selected element
                        if (canvasState.elements[canvasState.selectedElementIndex].type != ElementType.text &&
                            canvasState.elements[canvasState.selectedElementIndex].type != ElementType.image)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Stroke: ${canvasState.elements[canvasState.selectedElementIndex].strokeWidth.toInt()}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              Slider(
                                value: canvasState.elements[canvasState.selectedElementIndex].strokeWidth,
                                min: 1,
                                max: 20,
                                divisions: 19,
                                activeColor: Colors.blue,
                                onChanged: (value) => canvasState.updateElementStrokeWidth(canvasState.selectedElementIndex, value),
                              ),
                            ],
                          ),
                        
                        // Fill toggle for shapes
                        if (canvasState.elements[canvasState.selectedElementIndex].type == ElementType.rectangle ||
                            canvasState.elements[canvasState.selectedElementIndex].type == ElementType.circle)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Filled',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              Switch(
                                value: canvasState.elements[canvasState.selectedElementIndex].filled,
                                activeColor: Colors.blue,
                                onChanged: (value) => canvasState.toggleElementFill(canvasState.selectedElementIndex),
                              ),
                            ],
                          ),
                        
                        // Text formatting controls
                        if (canvasState.elements[canvasState.selectedElementIndex].type == ElementType.text)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              const Divider(),
                              const SizedBox(height: 8),
                              
                              // Font size
                              Text(
                                'Font Size: ${canvasState.elements[canvasState.selectedElementIndex].fontSize.toInt()}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              Slider(
                                value: canvasState.elements[canvasState.selectedElementIndex].fontSize,
                                min: 12,
                                max: 72,
                                divisions: 60,
                                activeColor: Colors.blue,
                                onChanged: (value) => canvasState.updateTextFontSize(canvasState.selectedElementIndex, value),
                              ),
                              
                              const SizedBox(height: 8),
                              
                              // Font family
                              const Text(
                                'Font Family',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              DropdownButton<String>(
                                value: canvasState.elements[canvasState.selectedElementIndex].fontFamily,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(value: 'Arial', child: Text('Arial')),
                                  DropdownMenuItem(value: 'Times New Roman', child: Text('Times New Roman')),
                                  DropdownMenuItem(value: 'Courier New', child: Text('Courier New')),
                                  DropdownMenuItem(value: 'Georgia', child: Text('Georgia')),
                                  DropdownMenuItem(value: 'Verdana', child: Text('Verdana')),
                                  DropdownMenuItem(value: 'Comic Sans MS', child: Text('Comic Sans MS')),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    canvasState.updateTextFontFamily(canvasState.selectedElementIndex, value);
                                  }
                                },
                              ),
                              
                              const SizedBox(height: 8),
                              
                              // Font weight
                              const Text(
                                'Font Weight',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              DropdownButton<FontWeight>(
                                value: canvasState.elements[canvasState.selectedElementIndex].fontWeight,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(value: FontWeight.normal, child: Text('Normal')),
                                  DropdownMenuItem(value: FontWeight.bold, child: Text('Bold')),
                                  DropdownMenuItem(value: FontWeight.w300, child: Text('Light')),
                                  DropdownMenuItem(value: FontWeight.w900, child: Text('Black')),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    canvasState.updateTextFontWeight(canvasState.selectedElementIndex, value);
                                  }
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          
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
  
  void _showElementColorPicker(BuildContext context, CanvasStateProvider canvasState) {
    if (canvasState.selectedElementIndex < 0) return;
    
    final element = canvasState.elements[canvasState.selectedElementIndex];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Element Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: element.color,
            onColorChanged: (color) => canvasState.updateElementColor(canvasState.selectedElementIndex, color),
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
