import 'package:flutter/material.dart';

/// Represents a drawing element on the canvas
class CanvasElement {
  final String id;
  final String type; // 'line', 'rectangle', 'circle', 'text'
  final Offset position;
  final Size? size;
  final Color color;
  final double strokeWidth;
  final String? text;
  
  CanvasElement({
    required this.id,
    required this.type,
    required this.position,
    this.size,
    this.color = Colors.black,
    this.strokeWidth = 2.0,
    this.text,
  });
  
  CanvasElement copyWith({
    String? id,
    String? type,
    Offset? position,
    Size? size,
    Color? color,
    double? strokeWidth,
    String? text,
  }) {
    return CanvasElement(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      size: size ?? this.size,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      text: text ?? this.text,
    );
  }
}

/// Manages the state of the canvas editor
class CanvasStateProvider extends ChangeNotifier {
  // Current tool selection
  String _selectedTool = 'pen';
  
  // Canvas elements
  final List<CanvasElement> _elements = [];
  
  // Undo/Redo stacks
  final List<List<CanvasElement>> _undoStack = [];
  final List<List<CanvasElement>> _redoStack = [];
  
  // Current drawing color
  Color _currentColor = Colors.black;
  
  // Current stroke width
  double _currentStrokeWidth = 2.0;
  
  // Getters
  String get selectedTool => _selectedTool;
  List<CanvasElement> get elements => List.unmodifiable(_elements);
  Color get currentColor => _currentColor;
  double get currentStrokeWidth => _currentStrokeWidth;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  
  // Set selected tool
  void setTool(String tool) {
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
  
  // Add element to canvas
  void addElement(CanvasElement element) {
    _saveState();
    _elements.add(element);
    _redoStack.clear();
    notifyListeners();
  }
  
  // Remove element from canvas
  void removeElement(String id) {
    _saveState();
    _elements.removeWhere((e) => e.id == id);
    _redoStack.clear();
    notifyListeners();
  }
  
  // Update element
  void updateElement(String id, CanvasElement updatedElement) {
    _saveState();
    final index = _elements.indexWhere((e) => e.id == id);
    if (index != -1) {
      _elements[index] = updatedElement;
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
