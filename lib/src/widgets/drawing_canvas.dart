import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import '../models/canvas_models.dart';
import 'drawing_canvas_painter.dart';

class DrawingCanvas extends StatefulWidget {
  final CanvasState canvasState;
  final Function(CanvasState) onStateChanged;

  const DrawingCanvas({
    super.key,
    required this.canvasState,
    required this.onStateChanged,
  });

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  final _uuid = const Uuid();
  Offset? _startPoint;
  List<Offset> _currentStrokePoints = [];

  @override
  Widget build(BuildContext context) {
    // Get canvas size from template or default
    final canvasWidth = widget.canvasState.elements.isNotEmpty
        ? _getCanvasWidth()
        : 800.0;
    final canvasHeight = widget.canvasState.elements.isNotEmpty
        ? _getCanvasHeight()
        : 600.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate scale to fit canvas in viewport
        final scaleX = constraints.maxWidth / canvasWidth;
        final scaleY = constraints.maxHeight / canvasHeight;
        final scale = (scaleX < scaleY ? scaleX : scaleY).clamp(0.1, 1.0);

        return Transform.scale(
          scale: scale,
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: canvasWidth,
            height: canvasHeight,
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: CustomPaint(
                foregroundPainter: DrawingCanvasPainter(
                  elements: widget.canvasState.elements,
                  tempElement: widget.canvasState.tempElement,
                ),
                child: Container(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onPanStart(DragStartDetails details) {
    final localPosition = details.localPosition;
    _startPoint = localPosition;
    _currentStrokePoints = [localPosition];

    final tool = widget.canvasState.currentTool;
    print('[ARTIQ DEBUG] Tool selected: $tool at position $localPosition');

    if (tool == DrawingTool.text) {
      // Show dialog to enter text
      _showTextDialog(localPosition);
      return;
    }

    if (tool == DrawingTool.image) {
      // Show image picker
      _showImagePicker(localPosition);
      return;
    }

    if (tool == DrawingTool.pen) {
      // Start a new stroke
      final stroke = DrawingStroke(
        id: _uuid.v4(),
        color: widget.canvasState.currentColor,
        strokeWidth: widget.canvasState.currentStrokeWidth,
        createdAt: DateTime.now(),
        points: [localPosition],
      );
      widget.onStateChanged(
        widget.canvasState.copyWith(tempElement: stroke),
      );
    } else if (tool == DrawingTool.rectangle) {
      // Initialize rectangle
      final rectangle = DrawingRectangle(
        id: _uuid.v4(),
        color: widget.canvasState.currentColor,
        strokeWidth: widget.canvasState.currentStrokeWidth,
        createdAt: DateTime.now(),
        topLeft: localPosition,
        bottomRight: localPosition,
        filled: true,
      );
      widget.onStateChanged(
        widget.canvasState.copyWith(tempElement: rectangle),
      );
    } else if (tool == DrawingTool.circle) {
      // Initialize circle
      final circle = DrawingCircle(
        id: _uuid.v4(),
        color: widget.canvasState.currentColor,
        strokeWidth: widget.canvasState.currentStrokeWidth,
        createdAt: DateTime.now(),
        center: localPosition,
        radius: 0,
        filled: true,
      );
      widget.onStateChanged(
        widget.canvasState.copyWith(tempElement: circle),
      );
    } else if (tool == DrawingTool.line) {
      // Initialize line
      final line = DrawingLine(
        id: _uuid.v4(),
        color: widget.canvasState.currentColor,
        strokeWidth: widget.canvasState.currentStrokeWidth,
        createdAt: DateTime.now(),
        start: localPosition,
        end: localPosition,
      );
      widget.onStateChanged(
        widget.canvasState.copyWith(tempElement: line),
      );
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final localPosition = details.localPosition;
    final tool = widget.canvasState.currentTool;

    if (tool == DrawingTool.pen) {
      // Add point to current stroke
      _currentStrokePoints.add(localPosition);
      final stroke = DrawingStroke(
        id: (widget.canvasState.tempElement as DrawingStroke?)?.id ??
            _uuid.v4(),
        color: widget.canvasState.currentColor,
        strokeWidth: widget.canvasState.currentStrokeWidth,
        createdAt: DateTime.now(),
        points: List.from(_currentStrokePoints),
      );
      widget.onStateChanged(
        widget.canvasState.copyWith(tempElement: stroke),
      );
    } else if (tool == DrawingTool.rectangle && _startPoint != null) {
      // Update rectangle
      final rectangle = DrawingRectangle(
        id: (widget.canvasState.tempElement as DrawingRectangle?)?.id ??
            _uuid.v4(),
        color: widget.canvasState.currentColor,
        strokeWidth: widget.canvasState.currentStrokeWidth,
        createdAt: DateTime.now(),
        topLeft: _startPoint!,
        bottomRight: localPosition,
        filled: true,
      );
      widget.onStateChanged(
        widget.canvasState.copyWith(tempElement: rectangle),
      );
    } else if (tool == DrawingTool.circle && _startPoint != null) {
      // Update circle
      final radius = (localPosition - _startPoint!).distance;
      final circle = DrawingCircle(
        id: (widget.canvasState.tempElement as DrawingCircle?)?.id ??
            _uuid.v4(),
        color: widget.canvasState.currentColor,
        strokeWidth: widget.canvasState.currentStrokeWidth,
        createdAt: DateTime.now(),
        center: _startPoint!,
        radius: radius,
        filled: true,
      );
      widget.onStateChanged(
        widget.canvasState.copyWith(tempElement: circle),
      );
    } else if (tool == DrawingTool.line && _startPoint != null) {
      // Update line
      final line = DrawingLine(
        id: (widget.canvasState.tempElement as DrawingLine?)?.id ?? _uuid.v4(),
        color: widget.canvasState.currentColor,
        strokeWidth: widget.canvasState.currentStrokeWidth,
        createdAt: DateTime.now(),
        start: _startPoint!,
        end: localPosition,
      );
      widget.onStateChanged(
        widget.canvasState.copyWith(tempElement: line),
      );
    }
  }

  void _onPanEnd(DragEndDetails details) {
    // Finalize the element
    if (widget.canvasState.tempElement != null) {
      final newElements = [
        ...widget.canvasState.elements,
        widget.canvasState.tempElement!,
      ];
      widget.onStateChanged(
        widget.canvasState.copyWith(
          elements: newElements,
          clearTemp: true,
        ),
      );
    }

    _startPoint = null;
    _currentStrokePoints = [];
  }

  void _showTextDialog(Offset position) {
    final textController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Text'),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter your text...',
            border: OutlineInputBorder(),
          ),
          maxLines: null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final text = textController.text.trim();
              if (text.isNotEmpty) {
                final textElement = DrawingText(
                  id: _uuid.v4(),
                  color: widget.canvasState.currentColor,
                  strokeWidth: widget.canvasState.currentStrokeWidth,
                  createdAt: DateTime.now(),
                  text: text,
                  position: position,
                  fontSize: 24.0,
                );
                
                final newElements = [
                  ...widget.canvasState.elements,
                  textElement,
                ];
                
                widget.onStateChanged(
                  widget.canvasState.copyWith(elements: newElements),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  double _getCanvasWidth() {
    double maxX = 800.0;
    for (final element in widget.canvasState.elements) {
      if (element is DrawingRectangle) {
        final right = element.bottomRight.dx;
        if (right > maxX) maxX = right;
      } else if (element is DrawingCircle) {
        final right = element.center.dx + element.radius;
        if (right > maxX) maxX = right;
      } else if (element is DrawingLine) {
        final right = element.end.dx > element.start.dx ? element.end.dx : element.start.dx;
        if (right > maxX) maxX = right;
      } else if (element is DrawingText) {
        final right = element.position.dx + (element.text.length * element.fontSize * 0.6);
        if (right > maxX) maxX = right;
      }
    }
    return maxX;
  }

  double _getCanvasHeight() {
    double maxY = 600.0;
    for (final element in widget.canvasState.elements) {
      if (element is DrawingRectangle) {
        final bottom = element.bottomRight.dy;
        if (bottom > maxY) maxY = bottom;
      } else if (element is DrawingCircle) {
        final bottom = element.center.dy + element.radius;
        if (bottom > maxY) maxY = bottom;
      } else if (element is DrawingLine) {
        final bottom = element.end.dy > element.start.dy ? element.end.dy : element.start.dy;
        if (bottom > maxY) maxY = bottom;
      } else if (element is DrawingText) {
        final bottom = element.position.dy + element.fontSize;
        if (bottom > maxY) maxY = bottom;
      }
    }
    return maxY;
  }

  Future<void> _showImagePicker(Offset position) async {
    // For web, we need to use file_picker package
    try {
      // Import at top: import 'package:file_picker/file_picker.dart';
      // Import at top: import 'dart:convert';
      
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          // Convert to base64
          final base64Image = base64Encode(file.bytes!);
          
          // Create image element
          final image = DrawingImage(
            id: _uuid.v4(),
            color: Colors.transparent,
            strokeWidth: 0,
            createdAt: DateTime.now(),
            imageData: base64Image,
            position: position,
            width: 200, // Default width
            height: 200, // Default height
          );

          // Add to canvas
          final newElements = [...widget.canvasState.elements, image];
          widget.onStateChanged(
            widget.canvasState.copyWith(elements: newElements),
          );
        }
      }
    } catch (e) {
      print('[ARTIQ ERROR] Image upload failed: $e');
    }
  }
}
