import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:artiq_flutter/src/providers/canvas_state_provider.dart';

/// Left panel with drawing tools
class LeftToolsPanel extends StatelessWidget {
  const LeftToolsPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final canvasState = context.watch<CanvasStateProvider>();
    
    return Container(
      width: 80,
      color: Colors.grey[200],
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildToolButton(
            context,
            icon: Icons.edit,
            label: 'Pen',
            tool: DrawingTool.pen,
            isSelected: canvasState.selectedTool == DrawingTool.pen,
            onTap: () => canvasState.selectTool(DrawingTool.pen),
          ),
          _buildToolButton(
            context,
            icon: Icons.crop_square,
            label: 'Rectangle',
            tool: DrawingTool.rectangle,
            isSelected: canvasState.selectedTool == DrawingTool.rectangle,
            onTap: () => canvasState.selectTool(DrawingTool.rectangle),
          ),
          _buildToolButton(
            context,
            icon: Icons.circle_outlined,
            label: 'Circle',
            tool: DrawingTool.circle,
            isSelected: canvasState.selectedTool == DrawingTool.circle,
            onTap: () => canvasState.selectTool(DrawingTool.circle),
          ),
          _buildToolButton(
            context,
            icon: Icons.remove,
            label: 'Line',
            tool: DrawingTool.line,
            isSelected: canvasState.selectedTool == DrawingTool.line,
            onTap: () => canvasState.selectTool(DrawingTool.line),
          ),
          _buildToolButton(
            context,
            icon: Icons.text_fields,
            label: 'Text',
            tool: DrawingTool.text,
            isSelected: canvasState.selectedTool == DrawingTool.text,
            onTap: () => canvasState.selectTool(DrawingTool.text),
          ),
          _buildToolButton(
            context,
            icon: Icons.cleaning_services,
            label: 'Eraser',
            tool: DrawingTool.eraser,
            isSelected: canvasState.selectedTool == DrawingTool.eraser,
            onTap: () => canvasState.selectTool(DrawingTool.eraser),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required DrawingTool tool,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepPurple : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.deepPurple : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[700],
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
