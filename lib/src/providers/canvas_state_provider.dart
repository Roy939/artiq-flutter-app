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
  
  // Load template - NEW METHOD
  void loadTemplate(String templateId) {
    _saveState();
    _elements.clear();
    
    // Generate template elements based on template ID
    switch (templateId) {
      case 'instagram_post':
        _loadInstagramPostTemplate();
        break;
      case 'business_presentation':
        _loadBusinessPresentationTemplate();
        break;
      case 'facebook_ad':
        _loadFacebookAdTemplate();
        break;
      case 'linkedin_banner':
        _loadLinkedInBannerTemplate();
        break;
      case 'product_flyer':
        _loadProductFlyerTemplate();
        break;
      case 'business_card':
        _loadBusinessCardTemplate();
        break;
      case 'youtube_thumbnail':
        _loadYouTubeThumbnailTemplate();
        break;
      case 'twitter_post':
        _loadTwitterPostTemplate();
        break;
      case 'email_header':
        _loadEmailHeaderTemplate();
        break;
      default:
        _loadDefaultTemplate();
    }
    
    _redoStack.clear();
    notifyListeners();
  }
  
  // Instagram Post Template
  void _loadInstagramPostTemplate() {
    // Background rectangle
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(50, 50, 400, 400),
      color: Colors.blue.shade400,
      strokeWidth: 0,
      filled: true,
    ));
    
    // Title text
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'Your Brand',
      bounds: const Rect.fromLTWH(100, 150, 300, 60),
      color: Colors.white,
      strokeWidth: 2,
    ));
    
    // Subtitle text
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'Instagram Post',
      bounds: const Rect.fromLTWH(100, 220, 300, 40),
      color: Colors.white70,
      strokeWidth: 1.5,
    ));
    
    // Decorative circle
    _elements.add(CanvasElement(
      type: ElementType.circle,
      bounds: const Rect.fromLTWH(350, 320, 80, 80),
      color: Colors.white,
      strokeWidth: 3,
    ));
  }
  
  // Business Presentation Template
  void _loadBusinessPresentationTemplate() {
    // Background
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(50, 50, 500, 350),
      color: Colors.purple.shade300,
      strokeWidth: 0,
      filled: true,
    ));
    
    // Title
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'Presentation Title',
      bounds: const Rect.fromLTWH(100, 120, 400, 60),
      color: Colors.white,
      strokeWidth: 2,
    ));
    
    // Subtitle
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'Your Company Name',
      bounds: const Rect.fromLTWH(100, 190, 400, 40),
      color: Colors.white70,
      strokeWidth: 1.5,
    ));
    
    // Decorative line
    _elements.add(CanvasElement(
      type: ElementType.line,
      bounds: Rect.fromPoints(const Offset(100, 250), const Offset(500, 250)),
      color: Colors.white,
      strokeWidth: 2,
    ));
  }
  
  // Facebook Ad Template
  void _loadFacebookAdTemplate() {
    // Background
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(50, 50, 400, 400),
      color: Colors.pink.shade300,
      strokeWidth: 0,
      filled: true,
    ));
    
    // Sale badge circle
    _elements.add(CanvasElement(
      type: ElementType.circle,
      bounds: const Rect.fromLTWH(150, 100, 200, 200),
      color: Colors.white,
      strokeWidth: 4,
    ));
    
    // Sale text
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: '50% OFF',
      bounds: const Rect.fromLTWH(180, 170, 140, 60),
      color: Colors.pink.shade600,
      strokeWidth: 2,
    ));
    
    // CTA text
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'Shop Now',
      bounds: const Rect.fromLTWH(150, 330, 200, 40),
      color: Colors.white,
      strokeWidth: 1.5,
    ));
  }
  
  // LinkedIn Banner Template
  void _loadLinkedInBannerTemplate() {
    // Background
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(50, 100, 500, 200),
      color: Colors.cyan.shade400,
      strokeWidth: 0,
      filled: true,
    ));
    
    // Name text
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'Your Name',
      bounds: const Rect.fromLTWH(100, 150, 400, 50),
      color: Colors.white,
      strokeWidth: 2,
    ));
    
    // Title text
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'Professional Title',
      bounds: const Rect.fromLTWH(100, 210, 400, 35),
      color: Colors.white70,
      strokeWidth: 1.5,
    ));
  }
  
  // Product Flyer Template
  void _loadProductFlyerTemplate() {
    // Background
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(50, 50, 350, 500),
      color: Colors.orange.shade300,
      strokeWidth: 0,
      filled: true,
    ));
    
    // Product area
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(100, 100, 250, 200),
      color: Colors.white,
      strokeWidth: 3,
    ));
    
    // Product name
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'Product Name',
      bounds: const Rect.fromLTWH(100, 330, 250, 50),
      color: Colors.white,
      strokeWidth: 2,
    ));
    
    // Description
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'Amazing features',
      bounds: const Rect.fromLTWH(100, 390, 250, 35),
      color: Colors.white70,
      strokeWidth: 1.5,
    ));
  }
  
  // Business Card Template
  void _loadBusinessCardTemplate() {
    // Card background
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(100, 150, 400, 250),
      color: Colors.teal.shade400,
      strokeWidth: 0,
      filled: true,
    ));
    
    // Name
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'John Doe',
      bounds: const Rect.fromLTWH(150, 220, 300, 50),
      color: Colors.white,
      strokeWidth: 2,
    ));
    
    // Title
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'CEO & Founder',
      bounds: const Rect.fromLTWH(150, 280, 300, 35),
      color: Colors.white70,
      strokeWidth: 1.5,
    ));
    
    // Decorative element
    _elements.add(CanvasElement(
      type: ElementType.circle,
      bounds: const Rect.fromLTWH(420, 170, 60, 60),
      color: Colors.white,
      strokeWidth: 2,
    ));
  }
  
  // YouTube Thumbnail Template
  void _loadYouTubeThumbnailTemplate() {
    // Background
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(50, 100, 500, 280),
      color: Colors.red.shade400,
      strokeWidth: 0,
      filled: true,
    ));
    
    // Title
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'VIDEO TITLE',
      bounds: const Rect.fromLTWH(100, 200, 400, 60),
      color: Colors.white,
      strokeWidth: 2,
    ));
    
    // Play button circle
    _elements.add(CanvasElement(
      type: ElementType.circle,
      bounds: const Rect.fromLTWH(450, 280, 80, 80),
      color: Colors.white,
      strokeWidth: 4,
    ));
  }
  
  // Twitter Post Template
  void _loadTwitterPostTemplate() {
    // Background
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(50, 50, 400, 300),
      color: Colors.lightBlue.shade300,
      strokeWidth: 0,
      filled: true,
    ));
    
    // Tweet text
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'Your Tweet Here',
      bounds: const Rect.fromLTWH(100, 140, 300, 50),
      color: Colors.white,
      strokeWidth: 2,
    ));
    
    // Hashtag
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: '#YourHashtag',
      bounds: const Rect.fromLTWH(100, 200, 300, 35),
      color: Colors.white70,
      strokeWidth: 1.5,
    ));
  }
  
  // Email Header Template
  void _loadEmailHeaderTemplate() {
    // Background
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(50, 100, 500, 180),
      color: Colors.indigo.shade400,
      strokeWidth: 0,
      filled: true,
    ));
    
    // Company name
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'Company Name',
      bounds: const Rect.fromLTWH(100, 150, 400, 50),
      color: Colors.white,
      strokeWidth: 2,
    ));
    
    // Tagline
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'Your tagline here',
      bounds: const Rect.fromLTWH(100, 210, 400, 35),
      color: Colors.white70,
      strokeWidth: 1.5,
    ));
  }
  
  // Default template
  void _loadDefaultTemplate() {
    // Simple welcome template
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'Start Designing!',
      bounds: const Rect.fromLTWH(150, 200, 300, 60),
      color: Colors.deepPurple,
      strokeWidth: 2,
    ));
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
