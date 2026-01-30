import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Drawing tool types
enum DrawingTool {
  pen,
  rectangle,
  circle,
  line,
  text,
  eraser,
}

/// Element types
enum ElementType {
  path,
  rectangle,
  circle,
  line,
  text,
}

/// Represents a drawing element on the canvas
class CanvasElement {
  final String id;
  final ElementType type;
  final List<Offset> points; // For paths and lines
  final Rect bounds; // For shapes and text
  final Color color;
  final double strokeWidth;
  final String text; // For text elements
  final bool filled;
  
  CanvasElement({
    String? id,
    required this.type,
    List<Offset>? points,
    Rect? bounds,
    this.color = Colors.black,
    this.strokeWidth = 2.0,
    this.text = '',
    this.filled = false,
  })  : id = id ?? _uuid.v4(),
        points = points ?? [],
        bounds = bounds ?? Rect.zero;
  
  CanvasElement copyWith({
    String? id,
    ElementType? type,
    List<Offset>? points,
    Rect? bounds,
    Color? color,
    double? strokeWidth,
    String? text,
    bool? filled,
  }) {
    return CanvasElement(
      id: id ?? this.id,
      type: type ?? this.type,
      points: points ?? this.points,
      bounds: bounds ?? this.bounds,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      text: text ?? this.text,
      filled: filled ?? this.filled,
    );
  }
}

/// Manages the state of the canvas editor
class CanvasStateProvider extends ChangeNotifier {
  // Current tool selection
  DrawingTool _selectedTool = DrawingTool.pen;
  
  // Canvas elements
  final List<CanvasElement> _elements = [];
  
  // Current drawing path (for pen tool)
  List<Offset> _currentPath = [];
  
  // Undo/Redo stacks
  final List<List<CanvasElement>> _undoStack = [];
  final List<List<CanvasElement>> _redoStack = [];
  
  // Current drawing color
  Color _currentColor = Colors.black;
  
  // Current stroke width
  double _currentStrokeWidth = 2.0;
  
  // Getters
  DrawingTool get selectedTool => _selectedTool;
  List<CanvasElement> get elements => List.unmodifiable(_elements);
  Color get currentColor => _currentColor;
  double get currentStrokeWidth => _currentStrokeWidth;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  
  // Select tool
  void selectTool(DrawingTool tool) {
    _selectedTool = tool;
    notifyListeners();
  }
  
  // Set current color
  void setColor(Color color) {
    _currentColor = color;
    notifyListeners();
  }
  
  // Set current stroke width
  void setStrokeWidth(double width) {
    _currentStrokeWidth = width;
    notifyListeners();
  }
  
  // Start drawing with pen
  void startDrawing(Offset point) {
    _currentPath = [point];
  }
  
  // Add point to current path
  void addPoint(Offset point) {
    _currentPath.add(point);
    notifyListeners();
  }
  
  // Finish drawing and add to elements
  void finishDrawing() {
    if (_currentPath.length > 1) {
      _saveState();
      _elements.add(CanvasElement(
        type: ElementType.path,
        points: List.from(_currentPath),
        color: _currentColor,
        strokeWidth: _currentStrokeWidth,
      ));
      _currentPath = [];
      _redoStack.clear();
      notifyListeners();
    }
  }
  
  // Add rectangle
  void addRectangle(Offset position) {
    _saveState();
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: Rect.fromLTWH(position.dx, position.dy, 100, 100),
      color: _currentColor,
      strokeWidth: _currentStrokeWidth,
    ));
    _redoStack.clear();
    notifyListeners();
  }
  
  // Add circle
  void addCircle(Offset position) {
    _saveState();
    _elements.add(CanvasElement(
      type: ElementType.circle,
      bounds: Rect.fromLTWH(position.dx, position.dy, 100, 100),
      color: _currentColor,
      strokeWidth: _currentStrokeWidth,
    ));
    _redoStack.clear();
    notifyListeners();
  }
  
  // Add line
  void addLine(Offset position) {
    _saveState();
    _elements.add(CanvasElement(
      type: ElementType.line,
      bounds: Rect.fromPoints(position, position + const Offset(100, 100)),
      color: _currentColor,
      strokeWidth: _currentStrokeWidth,
    ));
    _redoStack.clear();
    notifyListeners();
  }
  
  // Add text
  void addText(String text, Offset position) {
    _saveState();
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: text,
      bounds: Rect.fromLTWH(position.dx, position.dy, 200, 50),
      color: _currentColor,
    ));
    _redoStack.clear();
    notifyListeners();
  }
  
  // Move element by delta
  void moveElement(int index, Offset delta) {
    if (index >= 0 && index < _elements.length) {
      final element = _elements[index];
      final newBounds = element.bounds.shift(delta);
      final newPoints = element.points.map((p) => p + delta).toList();
      
      _elements[index] = element.copyWith(
        bounds: newBounds,
        points: newPoints,
      );
      notifyListeners();
    }
  }
  
  // Remove element by index
  void removeElement(int index) {
    if (index >= 0 && index < _elements.length) {
      _saveState();
      _elements.removeAt(index);
      _redoStack.clear();
      notifyListeners();
    }
  }
  
  // Clear canvas
  void clearCanvas() {
    _saveState();
    _elements.clear();
    _redoStack.clear();
    notifyListeners();
  }
  
  // Undo
  void undo() {
    if (_undoStack.isNotEmpty) {
      _redoStack.add(List.from(_elements));
      _elements.clear();
      _elements.addAll(_undoStack.removeLast());
      notifyListeners();
    }
  }
  
  // Redo
  void redo() {
    if (_redoStack.isNotEmpty) {
      _undoStack.add(List.from(_elements));
      _elements.clear();
      _elements.addAll(_redoStack.removeLast());
      notifyListeners();
    }
  }
  
  // Save current state to undo stack
  void _saveState() {
    _undoStack.add(List.from(_elements));
    if (_undoStack.length > 50) {
      _undoStack.removeAt(0);
    }
  }
}
