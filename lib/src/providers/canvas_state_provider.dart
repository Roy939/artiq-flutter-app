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
  image,
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
  final String? imageData; // Base64 image data for image elements
  final double fontSize; // Font size for text elements
  final String fontFamily; // Font family for text elements
  final FontWeight fontWeight; // Font weight for text elements
  final double rotation; // Rotation angle in radians
  
  CanvasElement({
    String? id,
    required this.type,
    List<Offset>? points,
    Rect? bounds,
    this.color = Colors.black,
    this.strokeWidth = 2.0,
    this.text = '',
    this.filled = false,
    this.imageData,
    this.fontSize = 24.0,
    this.fontFamily = 'Arial',
    this.fontWeight = FontWeight.bold,
    this.rotation = 0.0,
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
    String? imageData,
    double? fontSize,
    String? fontFamily,
    FontWeight? fontWeight,
    double? rotation,
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
      imageData: imageData ?? this.imageData,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      fontWeight: fontWeight ?? this.fontWeight,
      rotation: rotation ?? this.rotation,
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
  
  // Selected element index (-1 means none selected)
  int _selectedElementIndex = -1;
  
  // Resize state
  bool _isResizing = false;
  String _resizeHandle = ''; // 'tl', 'tr', 'bl', 'br' for corners
  Offset _resizeStartPoint = Offset.zero;
  Rect _resizeStartBounds = Rect.zero;
  
  // Line drawing state
  bool _isDrawingLine = false;
  Offset _lineStartPoint = Offset.zero;
  Offset _lineEndPoint = Offset.zero;
  
  // Rotation state
  bool _isRotating = false;
  double _rotationStartAngle = 0.0;
  double _elementStartRotation = 0.0;
  
  // Clipboard for copy/paste
  CanvasElement? _clipboard;
  
  // Canvas size
  double _canvasWidth = 1080.0;
  double _canvasHeight = 1080.0;
  
  // Getters
  DrawingTool get selectedTool => _selectedTool;
  List<CanvasElement> get elements => List.unmodifiable(_elements);
  List<Offset> get currentPath => List.unmodifiable(_currentPath);
  Color get currentColor => _currentColor;
  double get currentStrokeWidth => _currentStrokeWidth;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  int get selectedElementIndex => _selectedElementIndex;
  bool get isResizing => _isResizing;
  bool get isDrawingLine => _isDrawingLine;
  Offset get lineStartPoint => _lineStartPoint;
  Offset get lineEndPoint => _lineEndPoint;
  bool get isRotating => _isRotating;
  double get canvasWidth => _canvasWidth;
  double get canvasHeight => _canvasHeight;
  
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
  
  // Start drawing line
  void startLine(Offset position) {
    _isDrawingLine = true;
    _lineStartPoint = position;
    _lineEndPoint = position;
    notifyListeners();
  }
  
  // Update line end point while dragging
  void updateLine(Offset position) {
    if (_isDrawingLine) {
      _lineEndPoint = position;
      notifyListeners();
    }
  }
  
  // Finish drawing line
  void finishLine() {
    if (_isDrawingLine) {
      _saveState();
      _elements.add(CanvasElement(
        type: ElementType.line,
        bounds: Rect.fromPoints(_lineStartPoint, _lineEndPoint),
        color: _currentColor,
        strokeWidth: _currentStrokeWidth,
      ));
      _isDrawingLine = false;
      _redoStack.clear();
      notifyListeners();
    }
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
  
  // Add image
  void addImage(String base64Data, Offset position, {double width = 200, double height = 200}) {
    _saveState();
    _elements.add(CanvasElement(
      type: ElementType.image,
      imageData: base64Data,
      bounds: Rect.fromLTWH(position.dx, position.dy, width, height),
      color: Colors.transparent,
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
      if (_selectedElementIndex == index) {
        _selectedElementIndex = -1;
      } else if (_selectedElementIndex > index) {
        _selectedElementIndex--;
      }
      _redoStack.clear();
      notifyListeners();
    }
  }
  
  // Select element
  void selectElement(int index) {
    if (index >= -1 && index < _elements.length) {
      _selectedElementIndex = index;
      notifyListeners();
    }
  }
  
  // Start resizing
  void startResize(String handle, Offset point) {
    if (_selectedElementIndex >= 0 && _selectedElementIndex < _elements.length) {
      _isResizing = true;
      _resizeHandle = handle;
      _resizeStartPoint = point;
      _resizeStartBounds = _elements[_selectedElementIndex].bounds;
      notifyListeners();
    }
  }
  
  // Update resize
  void updateResize(Offset currentPoint) {
    if (!_isResizing || _selectedElementIndex < 0) return;
    
    final delta = currentPoint - _resizeStartPoint;
    final element = _elements[_selectedElementIndex];
    Rect newBounds = _resizeStartBounds;
    
    // Calculate new bounds based on which handle is being dragged
    switch (_resizeHandle) {
      case 'tl': // Top-left
        newBounds = Rect.fromLTRB(
          _resizeStartBounds.left + delta.dx,
          _resizeStartBounds.top + delta.dy,
          _resizeStartBounds.right,
          _resizeStartBounds.bottom,
        );
        break;
      case 'tr': // Top-right
        newBounds = Rect.fromLTRB(
          _resizeStartBounds.left,
          _resizeStartBounds.top + delta.dy,
          _resizeStartBounds.right + delta.dx,
          _resizeStartBounds.bottom,
        );
        break;
      case 'bl': // Bottom-left
        newBounds = Rect.fromLTRB(
          _resizeStartBounds.left + delta.dx,
          _resizeStartBounds.top,
          _resizeStartBounds.right,
          _resizeStartBounds.bottom + delta.dy,
        );
        break;
      case 'br': // Bottom-right
        newBounds = Rect.fromLTRB(
          _resizeStartBounds.left,
          _resizeStartBounds.top,
          _resizeStartBounds.right + delta.dx,
          _resizeStartBounds.bottom + delta.dy,
        );
        break;
    }
    
    // Ensure minimum size
    if (newBounds.width.abs() > 20 && newBounds.height.abs() > 20) {
      _elements[_selectedElementIndex] = element.copyWith(bounds: newBounds);
      notifyListeners();
    }
  }
  
  // End resizing
  void endResize() {
    if (_isResizing) {
      _saveState();
      _isResizing = false;
      _resizeHandle = '';
      _redoStack.clear();
      notifyListeners();
    }
  }
  
  // Start rotating
  void startRotate(Offset position) {
    if (_selectedElementIndex >= 0 && _selectedElementIndex < _elements.length) {
      final element = _elements[_selectedElementIndex];
      final center = element.bounds.center;
      
      _isRotating = true;
      _rotationStartAngle = (position - center).direction;
      _elementStartRotation = element.rotation;
      notifyListeners();
    }
  }
  
  // Update rotation
  void updateRotate(Offset position) {
    if (_isRotating && _selectedElementIndex >= 0 && _selectedElementIndex < _elements.length) {
      final element = _elements[_selectedElementIndex];
      final center = element.bounds.center;
      
      final currentAngle = (position - center).direction;
      final angleDelta = currentAngle - _rotationStartAngle;
      final newRotation = _elementStartRotation + angleDelta;
      
      _elements[_selectedElementIndex] = element.copyWith(rotation: newRotation);
      notifyListeners();
    }
  }
  
  // End rotating
  void endRotate() {
    if (_isRotating) {
      _saveState();
      _isRotating = false;
      _redoStack.clear();
      notifyListeners();
    }
  }
  
  // Copy selected element to clipboard
  void copySelectedElement() {
    if (_selectedElementIndex >= 0 && _selectedElementIndex < _elements.length) {
      _clipboard = _elements[_selectedElementIndex];
      // Note: In a real app, you might show a toast/snackbar here
    }
  }
  
  // Paste element from clipboard
  void pasteElement() {
    if (_clipboard != null) {
      _saveState();
      
      // Create a copy with new ID and offset position
      final offset = const Offset(20, 20);
      final newElement = _clipboard!.copyWith(
        id: null, // Will generate new ID
        bounds: _clipboard!.bounds.shift(offset),
      );
      
      _elements.add(newElement);
      
      // Select the newly pasted element
      _selectedElementIndex = _elements.length - 1;
      
      _redoStack.clear();
      notifyListeners();
    }
  }
  
  // Duplicate selected element
  void duplicateSelectedElement() {
    if (_selectedElementIndex >= 0 && _selectedElementIndex < _elements.length) {
      _saveState();
      
      final element = _elements[_selectedElementIndex];
      final offset = const Offset(20, 20);
      
      // Create a copy with new ID and offset position
      final newElement = element.copyWith(
        id: null, // Will generate new ID
        bounds: element.bounds.shift(offset),
      );
      
      _elements.add(newElement);
      
      // Select the newly duplicated element
      _selectedElementIndex = _elements.length - 1;
      
      _redoStack.clear();
      notifyListeners();
    }
  }
  
  // Update element color
  void updateElementColor(int index, Color color) {
    if (index >= 0 && index < _elements.length) {
      _saveState();
      _elements[index] = _elements[index].copyWith(color: color);
      _redoStack.clear();
      notifyListeners();
    }
  }
  
  // Update element stroke width
  void updateElementStrokeWidth(int index, double strokeWidth) {
    if (index >= 0 && index < _elements.length) {
      _elements[index] = _elements[index].copyWith(strokeWidth: strokeWidth);
      notifyListeners();
    }
  }
  
  // Toggle element fill
  void toggleElementFill(int index) {
    if (index >= 0 && index < _elements.length) {
      _saveState();
      final element = _elements[index];
      _elements[index] = element.copyWith(filled: !element.filled);
      _redoStack.clear();
      notifyListeners();
    }
  }
  
  // Update text font size
  void updateTextFontSize(int index, double fontSize) {
    if (index >= 0 && index < _elements.length && _elements[index].type == ElementType.text) {
      _elements[index] = _elements[index].copyWith(fontSize: fontSize);
      notifyListeners();
    }
  }
  
  // Update text font family
  void updateTextFontFamily(int index, String fontFamily) {
    if (index >= 0 && index < _elements.length && _elements[index].type == ElementType.text) {
      _saveState();
      _elements[index] = _elements[index].copyWith(fontFamily: fontFamily);
      _redoStack.clear();
      notifyListeners();
    }
  }
  
  // Update text font weight
  void updateTextFontWeight(int index, FontWeight fontWeight) {
    if (index >= 0 && index < _elements.length && _elements[index].type == ElementType.text) {
      _saveState();
      _elements[index] = _elements[index].copyWith(fontWeight: fontWeight);
      _redoStack.clear();
      notifyListeners();
    }
  }
  
  // Set canvas size
  void setCanvasSize(double width, double height) {
    _canvasWidth = width;
    _canvasHeight = height;
    notifyListeners();
  }
  
  // Clear canvas
  void clearCanvas() {
    _saveState();
    _elements.clear();
    _redoStack.clear();
    notifyListeners();
  }
  
  // Load template
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
  
  // Instagram Post Template - Professional Design
  void _loadInstagramPostTemplate() {
    // Modern dark background
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(50, 50, 1080, 1080),
      color: Color(0xFF1a1a2e),
      strokeWidth: 0,
      filled: true,
    ));
    
    // Accent color bar (top)
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(50, 50, 1080, 8),
      color: Color(0xFF00d4ff),
      strokeWidth: 0,
      filled: true,
    ));
    
    // Main content area with subtle background
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(100, 200, 980, 700),
      color: Color(0xFF16213e),
      strokeWidth: 0,
      filled: true,
    ));
    
    // Headline text (large, bold)
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'ELEVATE YOUR BRAND',
      bounds: const Rect.fromLTWH(150, 350, 880, 100),
      color: Colors.white,
      strokeWidth: 3,
    ));
    
    // Subheadline
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'Professional Design | Premium Quality',
      bounds: const Rect.fromLTWH(150, 480, 880, 60),
      color: Color(0xFF00d4ff),
      strokeWidth: 2,
    ));
    
    // Body text
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'Transform your social media presence',
      bounds: const Rect.fromLTWH(150, 580, 880, 50),
      color: Color(0xFFb8b8b8),
      strokeWidth: 1.5,
    ));
    
    // Decorative geometric element (circle)
    _elements.add(CanvasElement(
      type: ElementType.circle,
      bounds: const Rect.fromLTWH(900, 750, 120, 120),
      color: Color(0xFF00d4ff),
      strokeWidth: 4,
    ));
    
    // Bottom accent line
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(150, 950, 400, 4),
      color: Color(0xFF00d4ff),
      strokeWidth: 0,
      filled: true,
    ));
  }
  
  // Business Presentation Template - Professional Design
  void _loadBusinessPresentationTemplate() {
    // Main background (corporate dark blue)
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(50, 50, 1920, 1080),
      color: Color(0xFF0f2027),
      strokeWidth: 0,
      filled: true,
    ));
    
    // Left accent panel
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(50, 50, 600, 1080),
      color: Color(0xFF203a43),
      strokeWidth: 0,
      filled: true,
    ));
    
    // Gold accent bar
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(50, 50, 12, 1080),
      color: Color(0xFFffd700),
      strokeWidth: 0,
      filled: true,
    ));
    
    // Main title (large, professional)
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'QUARTERLY BUSINESS REVIEW',
      bounds: const Rect.fromLTWH(750, 300, 1100, 120),
      color: Colors.white,
      strokeWidth: 3.5,
    ));
    
    // Subtitle
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'Strategic Insights & Performance Metrics',
      bounds: const Rect.fromLTWH(750, 450, 1100, 70),
      color: Color(0xFFffd700),
      strokeWidth: 2,
    ));
    
    // Company name/presenter info
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'Your Company | 2026',
      bounds: const Rect.fromLTWH(750, 950, 600, 50),
      color: Color(0xFFb8b8b8),
      strokeWidth: 1.5,
    ));
    
    // Decorative circle on left panel
    _elements.add(CanvasElement(
      type: ElementType.circle,
      bounds: const Rect.fromLTWH(250, 450, 200, 200),
      color: Color(0xFFffd700),
      strokeWidth: 3,
    ));
    
    // Accent line under title
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(750, 560, 450, 5),
      color: Color(0xFFffd700),
      strokeWidth: 0,
      filled: true,
    ));
  }
  
  // Facebook Ad Template - Professional Design
  void _loadFacebookAdTemplate() {
    // Gradient background (purple to pink)
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(50, 50, 1200, 1200),
      color: Color(0xFF6a11cb),
      strokeWidth: 0,
      filled: true,
    ));
    
    // Secondary gradient overlay
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(50, 600, 1200, 600),
      color: Color(0xFF2575fc),
      strokeWidth: 0,
      filled: true,
    ));
    
    // Main offer badge
    _elements.add(CanvasElement(
      type: ElementType.circle,
      bounds: const Rect.fromLTWH(350, 300, 500, 500),
      color: Colors.white,
      strokeWidth: 0,
      filled: true,
    ));
    
    // Offer text (large)
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: '50% OFF',
      bounds: const Rect.fromLTWH(450, 450, 300, 100),
      color: Color(0xFF6a11cb),
      strokeWidth: 4,
    ));
    
    // Limited time text
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'LIMITED TIME OFFER',
      bounds: const Rect.fromLTWH(400, 580, 400, 50),
      color: Color(0xFF2575fc),
      strokeWidth: 1.5,
    ));
    
    // CTA button background
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(400, 950, 400, 100),
      color: Color(0xFFffd700),
      strokeWidth: 0,
      filled: true,
    ));
    
    // CTA text
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'SHOP NOW',
      bounds: const Rect.fromLTWH(450, 975, 300, 50),
      color: Color(0xFF1a1a2e),
      strokeWidth: 2.5,
    ));
    
    // Decorative accent circles
    _elements.add(CanvasElement(
      type: ElementType.circle,
      bounds: const Rect.fromLTWH(150, 150, 120, 120),
      color: Color(0xFFffd700),
      strokeWidth: 6,
    ));
    
    _elements.add(CanvasElement(
      type: ElementType.circle,
      bounds: const Rect.fromLTWH(950, 1000, 100, 100),
      color: Color(0xFFffd700),
      strokeWidth: 5,
    ));
  }
  
  // LinkedIn Banner Template - Professional Design
  void _loadLinkedInBannerTemplate() {
    // Professional blue gradient background
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(50, 50, 1584, 396),
      color: Color(0xFF0a66c2),
      strokeWidth: 0,
      filled: true,
    ));
    
    // Darker overlay section
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(50, 50, 800, 396),
      color: Color(0xFF004182),
      strokeWidth: 0,
      filled: true,
    ));
    
    // Name text (large, professional)
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'JANE ANDERSON',
      bounds: const Rect.fromLTWH(900, 120, 650, 80),
      color: Colors.white,
      strokeWidth: 3,
    ));
    
    // Professional title
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'Chief Technology Officer | Innovation Leader',
      bounds: const Rect.fromLTWH(900, 220, 650, 50),
      color: Color(0xFFe8e8e8),
      strokeWidth: 1.8,
    ));
    
    // Expertise/tagline
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'Transforming businesses through technology',
      bounds: const Rect.fromLTWH(900, 290, 650, 40),
      color: Color(0xFFffd700),
      strokeWidth: 1.5,
    ));
    
    // Decorative geometric element
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(150, 150, 500, 8),
      color: Color(0xFFffd700),
      strokeWidth: 0,
      filled: true,
    ));
    
    // Accent circle
    _elements.add(CanvasElement(
      type: ElementType.circle,
      bounds: const Rect.fromLTWH(350, 250, 120, 120),
      color: Color(0xFFffd700),
      strokeWidth: 4,
    ));
  }
  
  // Product Flyer Template - Professional Design
  void _loadProductFlyerTemplate() {
    // Modern gradient background
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(50, 50, 850, 1100),
      color: Color(0xFF141e30),
      strokeWidth: 0,
      filled: true,
    ));
    
    // Top accent bar
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(50, 50, 850, 15),
      color: Color(0xFFff6b6b),
      strokeWidth: 0,
      filled: true,
    ));
    
    // Product showcase area
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(150, 200, 650, 450),
      color: Colors.white,
      strokeWidth: 0,
      filled: true,
    ));
    
    // Product name (bold headline)
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'PREMIUM PRODUCT',
      bounds: const Rect.fromLTWH(150, 700, 650, 90),
      color: Colors.white,
      strokeWidth: 3.5,
    ));
    
    // Product tagline
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'Innovation Meets Excellence',
      bounds: const Rect.fromLTWH(150, 810, 650, 60),
      color: Color(0xFFff6b6b),
      strokeWidth: 2,
    ));
    
    // Features/description
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: '✓ Premium Quality  ✓ Lifetime Warranty  ✓ Free Shipping',
      bounds: const Rect.fromLTWH(150, 900, 650, 50),
      color: Color(0xFFe8e8e8),
      strokeWidth: 1.5,
    ));
    
    // Price badge
    _elements.add(CanvasElement(
      type: ElementType.circle,
      bounds: const Rect.fromLTWH(700, 150, 150, 150),
      color: Color(0xFFff6b6b),
      strokeWidth: 0,
      filled: true,
    ));
    
    // Decorative corner element
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(150, 1000, 300, 6),
      color: Color(0xFFff6b6b),
      strokeWidth: 0,
      filled: true,
    ));
  }
  
  // Business Card Template - Professional Design
  void _loadBusinessCardTemplate() {
    // Card background (elegant dark)
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(200, 250, 1000, 600),
      color: Color(0xFF1a1a2e),
      strokeWidth: 0,
      filled: true,
    ));
    
    // Gold accent strip (left side)
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(200, 250, 15, 600),
      color: Color(0xFFd4af37),
      strokeWidth: 0,
      filled: true,
    ));
    
    // Name (large, prominent)
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'MICHAEL CHEN',
      bounds: const Rect.fromLTWH(280, 380, 650, 80),
      color: Colors.white,
      strokeWidth: 3,
    ));
    
    // Title/position
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'Chief Executive Officer',
      bounds: const Rect.fromLTWH(280, 480, 650, 50),
      color: Color(0xFFd4af37),
      strokeWidth: 2,
    ));
    
    // Company name
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'Global Enterprises Inc.',
      bounds: const Rect.fromLTWH(280, 550, 650, 40),
      color: Color(0xFFb8b8b8),
      strokeWidth: 1.5,
    ));
    
    // Contact info
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'michael.chen@company.com | +1 (555) 123-4567',
      bounds: const Rect.fromLTWH(280, 720, 650, 35),
      color: Color(0xFF888888),
      strokeWidth: 1.2,
    ));
    
    // Decorative circle (logo placeholder)
    _elements.add(CanvasElement(
      type: ElementType.circle,
      bounds: const Rect.fromLTWH(1000, 300, 120, 120),
      color: Color(0xFFd4af37),
      strokeWidth: 3,
    ));
  }
  
  // YouTube Thumbnail Template - Professional Design
  void _loadYouTubeThumbnailTemplate() {
    // Bold background (YouTube red gradient)
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(50, 50, 1280, 720),
      color: Color(0xFFc4302b),
      strokeWidth: 0,
      filled: true,
    ));
    
    // Dark overlay for contrast
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(50, 400, 1280, 370),
      color: Color(0xFF1a1a1a),
      strokeWidth: 0,
      filled: true,
    ));
    
    // Main title (large, eye-catching)
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'ULTIMATE GUIDE',
      bounds: const Rect.fromLTWH(150, 500, 980, 120),
      color: Colors.white,
      strokeWidth: 4,
    ));
    
    // Subtitle/hook
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'Everything You Need to Know in 2026',
      bounds: const Rect.fromLTWH(150, 640, 980, 60),
      color: Color(0xFFffd700),
      strokeWidth: 2,
    ));
    
    // Play button circle (iconic YouTube element)
    _elements.add(CanvasElement(
      type: ElementType.circle,
      bounds: const Rect.fromLTWH(950, 150, 250, 250),
      color: Colors.white,
      strokeWidth: 0,
      filled: true,
    ));
    
    // Play button inner circle
    _elements.add(CanvasElement(
      type: ElementType.circle,
      bounds: const Rect.fromLTWH(980, 180, 190, 190),
      color: Color(0xFFc4302b),
      strokeWidth: 0,
      filled: true,
    ));
    
    // Accent elements
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(150, 450, 200, 12),
      color: Color(0xFFffd700),
      strokeWidth: 0,
      filled: true,
    ));
  }
  
  // Twitter Post Template - Professional Design
  void _loadTwitterPostTemplate() {
    // Clean white background (Twitter style)
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(50, 50, 1200, 675),
      color: Colors.white,
      strokeWidth: 0,
      filled: true,
    ));
    
    // Blue accent header
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(50, 50, 1200, 150),
      color: Color(0xFF1da1f2),
      strokeWidth: 0,
      filled: true,
    ));
    
    // Main tweet text (bold statement)
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'Breaking: Major Announcement',
      bounds: const Rect.fromLTWH(150, 280, 900, 90),
      color: Color(0xFF14171a),
      strokeWidth: 3,
    ));
    
    // Supporting text
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'Join the conversation and share your thoughts',
      bounds: const Rect.fromLTWH(150, 390, 900, 60),
      color: Color(0xFF657786),
      strokeWidth: 1.8,
    ));
    
    // Hashtag section
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: '#Trending #Innovation #2026',
      bounds: const Rect.fromLTWH(150, 500, 900, 50),
      color: Color(0xFF1da1f2),
      strokeWidth: 2,
    ));
    
    // Profile circle placeholder
    _elements.add(CanvasElement(
      type: ElementType.circle,
      bounds: const Rect.fromLTWH(1000, 280, 150, 150),
      color: Color(0xFF1da1f2),
      strokeWidth: 0,
      filled: true,
    ));
    
    // Decorative accent line
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(150, 600, 400, 5),
      color: Color(0xFF1da1f2),
      strokeWidth: 0,
      filled: true,
    ));
  }
  
  // Email Header Template - Professional Design
  void _loadEmailHeaderTemplate() {
    // Professional gradient background
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(50, 100, 1400, 300),
      color: Color(0xFF2c3e50),
      strokeWidth: 0,
      filled: true,
    ));
    
    // Top accent bar
    _elements.add(CanvasElement(
      type: ElementType.rectangle,
      bounds: const Rect.fromLTWH(50, 100, 1400, 8),
      color: Color(0xFF3498db),
      strokeWidth: 0,
      filled: true,
    ));
    
    // Company name (large, professional)
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'ENTERPRISE SOLUTIONS',
      bounds: const Rect.fromLTWH(150, 180, 1100, 80),
      color: Colors.white,
      strokeWidth: 3,
    ));
    
    // Tagline
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'Delivering Excellence in Every Solution',
      bounds: const Rect.fromLTWH(150, 280, 1100, 50),
      color: Color(0xFF3498db),
      strokeWidth: 2,
    ));
    
    // Contact info
    _elements.add(CanvasElement(
      type: ElementType.text,
      text: 'www.company.com | contact@company.com',
      bounds: const Rect.fromLTWH(150, 350, 1100, 35),
      color: Color(0xFFb8b8b8),
      strokeWidth: 1.3,
    ));
    
    // Logo placeholder circle
    _elements.add(CanvasElement(
      type: ElementType.circle,
      bounds: const Rect.fromLTWH(1300, 200, 100, 100),
      color: Color(0xFF3498db),
      strokeWidth: 4,
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
