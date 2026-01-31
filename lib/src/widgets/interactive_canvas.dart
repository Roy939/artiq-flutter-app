import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:artiq_flutter/src/providers/canvas_state_provider.dart';

/// Interactive canvas that supports drawing, clicking to add elements, and dragging to move them
class InteractiveCanvas extends StatefulWidget {
  const InteractiveCanvas({Key? key}) : super(key: key);

  @override
  State<InteractiveCanvas> createState() => _InteractiveCanvasState();
}

class _InteractiveCanvasState extends State<InteractiveCanvas> {
  Offset? _dragStart;
  int? _selectedElementIndex;

  @override
  Widget build(BuildContext context) {
    final canvasState = context.watch<CanvasStateProvider>();
    
    return GestureDetector(
      onPanStart: (details) {
        final position = details.localPosition;
        
        // If eraser is selected, remove element immediately
        if (canvasState.selectedTool == DrawingTool.eraser) {
          final index = _findElementAtPosition(canvasState, position);
          if (index != null) {
            canvasState.removeElement(index);
          }
          return;
        }
        
        // Check if user clicked on an existing element
        _selectedElementIndex = _findElementAtPosition(canvasState, position);
        
        if (_selectedElementIndex != null) {
          // Start dragging the element
          _dragStart = position;
        } else {
          // Start drawing or adding new element
          _handleAddElement(canvasState, position);
        }
      },
      onPanUpdate: (details) {
        // If eraser is selected, continue erasing elements as we drag
        if (canvasState.selectedTool == DrawingTool.eraser) {
          final index = _findElementAtPosition(canvasState, details.localPosition);
          if (index != null) {
            canvasState.removeElement(index);
          }
          return;
        }
        
        if (_selectedElementIndex != null && _dragStart != null) {
          // Drag the selected element
          final delta = details.localPosition - _dragStart!;
          canvasState.moveElement(_selectedElementIndex!, delta);
          _dragStart = details.localPosition;
        } else if (canvasState.selectedTool == DrawingTool.pen) {
          // Continue drawing with pen
          canvasState.addPoint(details.localPosition);
        }
      },
      onPanEnd: (details) {
        _dragStart = null;
        _selectedElementIndex = null;
        
        if (canvasState.selectedTool == DrawingTool.pen) {
          canvasState.finishDrawing();
        }
      },
      child: Container(
        color: Colors.white,
        child: CustomPaint(
          painter: CanvasPainter(canvasState),
          child: Container(),
        ),
      ),
    );
  }

  int? _findElementAtPosition(CanvasStateProvider canvasState, Offset position) {
    // Find element at position (reverse order to check top elements first)
    for (int i = canvasState.elements.length - 1; i >= 0; i--) {
      final element = canvasState.elements[i];
      if (_isPositionInElement(element, position)) {
        return i;
      }
    }
    return null;
  }

  bool _isPositionInElement(CanvasElement element, Offset position) {
    // For path elements, check if position is near any point in the path
    if (element.type == ElementType.path && element.points.isNotEmpty) {
      const threshold = 10.0; // Distance threshold for hit detection
      for (final point in element.points) {
        final distance = (point - position).distance;
        if (distance < threshold) {
          return true;
        }
      }
      return false;
    }
    
    // For other elements, use simple bounding box check
    final bounds = element.bounds;
    return position.dx >= bounds.left &&
        position.dx <= bounds.right &&
        position.dy >= bounds.top &&
        position.dy <= bounds.bottom;
  }

  void _handleAddElement(CanvasStateProvider canvasState, Offset position) {
    switch (canvasState.selectedTool) {
      case DrawingTool.pen:
        canvasState.startDrawing(position);
        break;
      case DrawingTool.rectangle:
        canvasState.addRectangle(position);
        break;
      case DrawingTool.circle:
        canvasState.addCircle(position);
        break;
      case DrawingTool.line:
        canvasState.addLine(position);
        break;
      case DrawingTool.text:
        _showTextDialog(context, canvasState, position);
        break;
      case DrawingTool.eraser:
        // Eraser removes element at position
        final index = _findElementAtPosition(canvasState, position);
        if (index != null) {
          canvasState.removeElement(index);
        }
        break;
    }
  }

  void _showTextDialog(BuildContext context, CanvasStateProvider canvasState, Offset position) {
    final textController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Text'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: 'Enter text'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                canvasState.addText(textController.text, position);
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for rendering canvas elements
class CanvasPainter extends CustomPainter {
  final CanvasStateProvider canvasState;

  CanvasPainter(this.canvasState) : super(repaint: canvasState);

  @override
  void paint(Canvas canvas, Size size) {
    // Paint all completed elements
    for (final element in canvasState.elements) {
      _paintElement(canvas, element);
    }
    
    // Paint current path being drawn (real-time preview)
    if (canvasState.currentPath.length > 1) {
      final paint = Paint()
        ..color = canvasState.currentColor
        ..strokeWidth = canvasState.currentStrokeWidth
        ..style = PaintingStyle.stroke;
      
      final path = Path();
      path.moveTo(canvasState.currentPath.first.dx, canvasState.currentPath.first.dy);
      for (final point in canvasState.currentPath.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  void _paintElement(Canvas canvas, CanvasElement element) {
    final paint = Paint()
      ..color = element.color
      ..strokeWidth = element.strokeWidth
      ..style = element.filled ? PaintingStyle.fill : PaintingStyle.stroke;

    switch (element.type) {
      case ElementType.path:
        if (element.points.length > 1) {
          final path = Path();
          path.moveTo(element.points.first.dx, element.points.first.dy);
          for (final point in element.points.skip(1)) {
            path.lineTo(point.dx, point.dy);
          }
          canvas.drawPath(path, paint);
        }
        break;
      case ElementType.rectangle:
        canvas.drawRect(element.bounds, paint);
        break;
      case ElementType.circle:
        final center = element.bounds.center;
        final radius = (element.bounds.width + element.bounds.height) / 4;
        canvas.drawCircle(center, radius, paint);
        break;
      case ElementType.line:
        canvas.drawLine(
          element.bounds.topLeft,
          element.bounds.bottomRight,
          paint,
        );
        break;
      case ElementType.text:
        final textPainter = TextPainter(
          text: TextSpan(
            text: element.text,
            style: TextStyle(
              color: element.color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, element.bounds.topLeft);
        break;
    }
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) => true;
}
