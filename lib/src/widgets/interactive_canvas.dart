import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:typed_data';
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
        
        // Check if clicking on a resize handle of selected element
        if (canvasState.selectedElementIndex >= 0) {
          final handle = _getResizeHandleAt(canvasState.elements[canvasState.selectedElementIndex], position);
          if (handle != null) {
            canvasState.startResize(handle, position);
            return;
          }
        }
        
        // Check if user clicked on an existing element
        _selectedElementIndex = _findElementAtPosition(canvasState, position);
        
        if (_selectedElementIndex != null) {
          // Select the element and start dragging
          canvasState.selectElement(_selectedElementIndex!);
          _dragStart = position;
        } else {
          // Deselect if clicking empty space
          canvasState.selectElement(-1);
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
        
        // Handle resizing
        if (canvasState.isResizing) {
          canvasState.updateResize(details.localPosition);
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
        // End resizing if in resize mode
        if (canvasState.isResizing) {
          canvasState.endResize();
          return;
        }
        
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
  
  String? _getResizeHandleAt(CanvasElement element, Offset position) {
    // Only resizable for elements with bounds (not paths)
    if (element.type == ElementType.path) return null;
    
    const handleSize = 10.0;
    final bounds = element.bounds;
    
    // Check each corner
    if ((position - bounds.topLeft).distance < handleSize) return 'tl';
    if ((position - bounds.topRight).distance < handleSize) return 'tr';
    if ((position - bounds.bottomLeft).distance < handleSize) return 'bl';
    if ((position - bounds.bottomRight).distance < handleSize) return 'br';
    
    return null;
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
  final Map<String, ui.Image> _imageCache = {};

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
    
    // Draw selection and resize handles for selected element
    if (canvasState.selectedElementIndex >= 0 && 
        canvasState.selectedElementIndex < canvasState.elements.length) {
      final element = canvasState.elements[canvasState.selectedElementIndex];
      
      // Only show resize handles for non-path elements
      if (element.type != ElementType.path) {
        _drawSelectionAndHandles(canvas, element);
      }
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
              fontSize: element.fontSize,
              fontWeight: element.fontWeight,
              fontFamily: element.fontFamily,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, element.bounds.topLeft);
        break;
      case ElementType.image:
        // Draw image if available, otherwise placeholder
        if (element.imageData != null && element.imageData!.isNotEmpty) {
          // Try to get from cache
          final cachedImage = _imageCache[element.id];
          if (cachedImage != null) {
            canvas.drawImageRect(
              cachedImage,
              Rect.fromLTWH(0, 0, cachedImage.width.toDouble(), cachedImage.height.toDouble()),
              element.bounds,
              Paint(),
            );
          } else {
            // Load image asynchronously
            _loadImage(element.id, element.imageData!);
            // Draw placeholder while loading
            final placeholderPaint = Paint()
              ..color = Colors.grey.withOpacity(0.3)
              ..style = PaintingStyle.fill;
            canvas.drawRect(element.bounds, placeholderPaint);
          }
        } else {
          // Draw placeholder for missing image data
          final placeholderPaint = Paint()
            ..color = Colors.grey.withOpacity(0.3)
            ..style = PaintingStyle.fill;
          canvas.drawRect(element.bounds, placeholderPaint);
        }
        break;
    }
  }

  /// Draw selection border and resize handles
  void _drawSelectionAndHandles(Canvas canvas, CanvasElement element) {
    final bounds = element.bounds;
    
    // Draw selection border
    final borderPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(bounds, borderPaint);
    
    // Draw resize handles at corners
    final handlePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    
    const handleSize = 8.0;
    final handles = [
      bounds.topLeft,
      bounds.topRight,
      bounds.bottomLeft,
      bounds.bottomRight,
    ];
    
    for (final handle in handles) {
      canvas.drawCircle(handle, handleSize / 2, handlePaint);
      // Draw white border around handle for visibility
      final whiteBorder = Paint()
        ..color = Colors.white
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(handle, handleSize / 2, whiteBorder);
    }
  }
  
  /// Load image from base64 data
  Future<void> _loadImage(String id, String base64Data) async {
    try {
      final bytes = base64Decode(base64Data);
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      _imageCache[id] = frame.image;
      // Trigger repaint
      canvasState.notifyListeners();
    } catch (e) {
      print('Error loading image: $e');
    }
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) => true;
}
