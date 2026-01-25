import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/canvas_models.dart';

class DrawingToolbar extends StatelessWidget {
  final CanvasState canvasState;
  final Function(CanvasState) onStateChanged;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onClear;
  final bool canUndo;
  final bool canRedo;

  const DrawingToolbar({
    super.key,
    required this.canvasState,
    required this.onStateChanged,
    required this.onUndo,
    required this.onRedo,
    required this.onClear,
    required this.canUndo,
    required this.canRedo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tool selection row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildToolButton(
                context,
                icon: Icons.edit,
                tool: DrawingTool.pen,
                label: 'Pen',
              ),
              _buildToolButton(
                context,
                icon: Icons.crop_square,
                tool: DrawingTool.rectangle,
                label: 'Rectangle',
              ),
              _buildToolButton(
                context,
                icon: Icons.circle_outlined,
                tool: DrawingTool.circle,
                label: 'Circle',
              ),
              _buildToolButton(
                context,
                icon: Icons.remove,
                tool: DrawingTool.line,
                label: 'Line',
              ),
              _buildToolButton(
                context,
                icon: Icons.text_fields,
                tool: DrawingTool.text,
                label: 'Text',
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Controls row
          Row(
            children: [
              // Color picker
              InkWell(
                onTap: () => _showColorPicker(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: canvasState.currentColor,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Stroke width
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Width: ${canvasState.currentStrokeWidth.toInt()}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Slider(
                      value: canvasState.currentStrokeWidth,
                      min: 1,
                      max: 20,
                      divisions: 19,
                      onChanged: (value) {
                        onStateChanged(
                          canvasState.copyWith(currentStrokeWidth: value),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Undo/Redo/Clear
              IconButton(
                icon: const Icon(Icons.undo),
                onPressed: canUndo ? onUndo : null,
                tooltip: 'Undo',
              ),
              IconButton(
                icon: const Icon(Icons.redo),
                onPressed: canRedo ? onRedo : null,
                tooltip: 'Redo',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onClear,
                tooltip: 'Clear',
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(
    BuildContext context, {
    required IconData icon,
    required DrawingTool tool,
    required String label,
  }) {
    final isSelected = canvasState.currentTool == tool;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black87,
            ),
            onPressed: () {
              onStateChanged(canvasState.copyWith(currentTool: tool));
            },
            tooltip: label,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isSelected ? Theme.of(context).primaryColor : Colors.black54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: canvasState.currentColor,
            onColorChanged: (color) {
              onStateChanged(canvasState.copyWith(currentColor: color));
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
