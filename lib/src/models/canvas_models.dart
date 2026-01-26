import 'dart:ui';
import 'package:flutter/material.dart' hide Path;

/// Represents a drawing element on the canvas
abstract class DrawingElement {
  final String id;
  final Color color;
  final double strokeWidth;
  final DateTime createdAt;

  DrawingElement({
    required this.id,
    required this.color,
    required this.strokeWidth,
    required this.createdAt,
  });

  /// Convert to JSON for storage
  Map<String, dynamic> toJson();

  /// Create from JSON
  static DrawingElement fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    switch (type) {
      case 'stroke':
        return DrawingStroke.fromJson(json);
      case 'rectangle':
        return DrawingRectangle.fromJson(json);
      case 'circle':
        return DrawingCircle.fromJson(json);
      case 'line':
        return DrawingLine.fromJson(json);
      case 'text':
        return DrawingText.fromJson(json);
      case 'image':
        return DrawingImage.fromJson(json);
      default:
        throw Exception('Unknown drawing element type: $type');
    }
  }
}

/// Represents a freehand stroke (pen drawing)
class DrawingStroke extends DrawingElement {
  final List<Offset> points;

  DrawingStroke({
    required super.id,
    required super.color,
    required super.strokeWidth,
    required super.createdAt,
    required this.points,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'stroke',
      'id': id,
      'color': color.value,
      'strokeWidth': strokeWidth,
      'createdAt': createdAt.toIso8601String(),
      'points': points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
    };
  }

  factory DrawingStroke.fromJson(Map<String, dynamic> json) {
    return DrawingStroke(
      id: json['id'] as String,
      color: Color(json['color'] as int),
      strokeWidth: (json['strokeWidth'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      points: (json['points'] as List)
          .map((p) => Offset(
                (p['x'] as num).toDouble(),
                (p['y'] as num).toDouble(),
              ))
          .toList(),
    );
  }
}

/// Represents a rectangle shape
class DrawingRectangle extends DrawingElement {
  final Offset topLeft;
  final Offset bottomRight;
  final bool filled;

  DrawingRectangle({
    required super.id,
    required super.color,
    required super.strokeWidth,
    required super.createdAt,
    required this.topLeft,
    required this.bottomRight,
    this.filled = false,
  });

  Rect get rect => Rect.fromPoints(topLeft, bottomRight);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'rectangle',
      'id': id,
      'color': color.value,
      'strokeWidth': strokeWidth,
      'createdAt': createdAt.toIso8601String(),
      'topLeft': {'x': topLeft.dx, 'y': topLeft.dy},
      'bottomRight': {'x': bottomRight.dx, 'y': bottomRight.dy},
      'filled': filled,
    };
  }

  factory DrawingRectangle.fromJson(Map<String, dynamic> json) {
    return DrawingRectangle(
      id: json['id'] as String,
      color: Color(json['color'] as int),
      strokeWidth: (json['strokeWidth'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      topLeft: Offset(
        (json['topLeft']['x'] as num).toDouble(),
        (json['topLeft']['y'] as num).toDouble(),
      ),
      bottomRight: Offset(
        (json['bottomRight']['x'] as num).toDouble(),
        (json['bottomRight']['y'] as num).toDouble(),
      ),
      filled: json['filled'] as bool? ?? false,
    );
  }
}

/// Represents a circle shape
class DrawingCircle extends DrawingElement {
  final Offset center;
  final double radius;
  final bool filled;

  DrawingCircle({
    required super.id,
    required super.color,
    required super.strokeWidth,
    required super.createdAt,
    required this.center,
    required this.radius,
    this.filled = false,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'circle',
      'id': id,
      'color': color.value,
      'strokeWidth': strokeWidth,
      'createdAt': createdAt.toIso8601String(),
      'center': {'x': center.dx, 'y': center.dy},
      'radius': radius,
      'filled': filled,
    };
  }

  factory DrawingCircle.fromJson(Map<String, dynamic> json) {
    return DrawingCircle(
      id: json['id'] as String,
      color: Color(json['color'] as int),
      strokeWidth: (json['strokeWidth'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      center: Offset(
        (json['center']['x'] as num).toDouble(),
        (json['center']['y'] as num).toDouble(),
      ),
      radius: (json['radius'] as num).toDouble(),
      filled: json['filled'] as bool? ?? false,
    );
  }
}

/// Represents a straight line
class DrawingLine extends DrawingElement {
  final Offset start;
  final Offset end;

  DrawingLine({
    required super.id,
    required super.color,
    required super.strokeWidth,
    required super.createdAt,
    required this.start,
    required this.end,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'line',
      'id': id,
      'color': color.value,
      'strokeWidth': strokeWidth,
      'createdAt': createdAt.toIso8601String(),
      'start': {'x': start.dx, 'y': start.dy},
      'end': {'x': end.dx, 'y': end.dy},
    };
  }

  factory DrawingLine.fromJson(Map<String, dynamic> json) {
    return DrawingLine(
      id: json['id'] as String,
      color: Color(json['color'] as int),
      strokeWidth: (json['strokeWidth'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      start: Offset(
        (json['start']['x'] as num).toDouble(),
        (json['start']['y'] as num).toDouble(),
      ),
      end: Offset(
        (json['end']['x'] as num).toDouble(),
        (json['end']['y'] as num).toDouble(),
      ),
    );
  }
}

/// Represents a text element
class DrawingText extends DrawingElement {
  final String text;
  final Offset position;
  final double fontSize;

  DrawingText({
    required super.id,
    required super.color,
    required super.strokeWidth,
    required super.createdAt,
    required this.text,
    required this.position,
    this.fontSize = 24.0,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'text',
      'id': id,
      'color': color.value,
      'strokeWidth': strokeWidth,
      'createdAt': createdAt.toIso8601String(),
      'text': text,
      'position': {'x': position.dx, 'y': position.dy},
      'fontSize': fontSize,
    };
  }

  factory DrawingText.fromJson(Map<String, dynamic> json) {
    return DrawingText(
      id: json['id'] as String,
      color: Color(json['color'] as int),
      strokeWidth: (json['strokeWidth'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      text: json['text'] as String,
      position: Offset(
        (json['position']['x'] as num).toDouble(),
        (json['position']['y'] as num).toDouble(),
      ),
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 24.0,
    );
  }
}

/// Represents an uploaded image on the canvas
class DrawingImage extends DrawingElement {
  final String imageData; // Base64 encoded image
  final Offset position;
  final double width;
  final double height;

  DrawingImage({
    required super.id,
    required super.color,
    required super.strokeWidth,
    required super.createdAt,
    required this.imageData,
    required this.position,
    required this.width,
    required this.height,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'image',
      'id': id,
      'color': color.value,
      'strokeWidth': strokeWidth,
      'createdAt': createdAt.toIso8601String(),
      'imageData': imageData,
      'position': {'x': position.dx, 'y': position.dy},
      'width': width,
      'height': height,
    };
  }

  factory DrawingImage.fromJson(Map<String, dynamic> json) {
    return DrawingImage(
      id: json['id'] as String,
      color: Color(json['color'] as int),
      strokeWidth: (json['strokeWidth'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      imageData: json['imageData'] as String,
      position: Offset(
        (json['position']['x'] as num).toDouble(),
        (json['position']['y'] as num).toDouble(),
      ),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );
  }
}

/// Drawing tool types
enum DrawingTool {
  pen,
  rectangle,
  circle,
  line,
  text,
  image,
  eraser,
  select,
}

/// Canvas state
class CanvasState {
  final List<DrawingElement> elements;
  final DrawingTool currentTool;
  final Color currentColor;
  final double currentStrokeWidth;
  final DrawingElement? tempElement; // Element being drawn
  final double zoomLevel; // Canvas zoom level (1.0 = 100%)
  final Offset panOffset; // Canvas pan offset for scrolling

  CanvasState({
    this.elements = const [],
    this.currentTool = DrawingTool.pen,
    this.currentColor = Colors.black,
    this.currentStrokeWidth = 3.0,
    this.tempElement,
    this.zoomLevel = 1.0,
    this.panOffset = Offset.zero,
  });

  CanvasState copyWith({
    List<DrawingElement>? elements,
    DrawingTool? currentTool,
    Color? currentColor,
    double? currentStrokeWidth,
    DrawingElement? tempElement,
    double? zoomLevel,
    Offset? panOffset,
    bool clearTemp = false,
  }) {
    return CanvasState(
      elements: elements ?? this.elements,
      currentTool: currentTool ?? this.currentTool,
      currentColor: currentColor ?? this.currentColor,
      currentStrokeWidth: currentStrokeWidth ?? this.currentStrokeWidth,
      tempElement: clearTemp ? null : (tempElement ?? this.tempElement),
      zoomLevel: zoomLevel ?? this.zoomLevel,
      panOffset: panOffset ?? this.panOffset,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'elements': elements.map((e) => e.toJson()).toList(),
      'currentTool': currentTool.name,
      'currentColor': currentColor.value,
      'currentStrokeWidth': currentStrokeWidth,
    };
  }

  factory CanvasState.fromJson(Map<String, dynamic> json) {
    return CanvasState(
      elements: (json['elements'] as List)
          .map((e) => DrawingElement.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentTool: DrawingTool.values.firstWhere(
        (t) => t.name == json['currentTool'],
        orElse: () => DrawingTool.pen,
      ),
      currentColor: Color(json['currentColor'] as int),
      currentStrokeWidth: (json['currentStrokeWidth'] as num).toDouble(),
    );
  }
}
