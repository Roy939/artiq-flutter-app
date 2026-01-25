import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
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
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: CustomPaint(
        painter: DrawingCanvasPainter(
          elements: widget.canvasState.elements,
          tempElement: widget.canvasState.tempElement,
        ),
        child: Container(
          color: Colors.white,
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    final localPosition = details.localPosition;
    _startPoint = localPosition;
    _currentStrokePoints = [localPosition];

    final tool = widget.canvasState.currentTool;

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
}
