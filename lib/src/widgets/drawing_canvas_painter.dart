import 'package:flutter/material.dart';
import '../models/canvas_models.dart';

/// Custom painter for rendering the drawing canvas
class DrawingCanvasPainter extends CustomPainter {
  final List<DrawingElement> elements;
  final DrawingElement? tempElement;

  DrawingCanvasPainter({
    required this.elements,
    this.tempElement,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw all completed elements
    for (final element in elements) {
      _drawElement(canvas, element);
    }

    // Draw temporary element being created
    if (tempElement != null) {
      _drawElement(canvas, tempElement!);
    }
  }

  void _drawElement(Canvas canvas, DrawingElement element) {
    final paint = Paint()
      ..color = element.color
      ..strokeWidth = element.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (element is DrawingStroke) {
      _drawStroke(canvas, element, paint);
    } else if (element is DrawingRectangle) {
      _drawRectangle(canvas, element, paint);
    } else if (element is DrawingCircle) {
      _drawCircle(canvas, element, paint);
    } else if (element is DrawingLine) {
      _drawLine(canvas, element, paint);
    } else if (element is DrawingText) {
      _drawText(canvas, element);
    }
  }

  void _drawStroke(Canvas canvas, DrawingStroke stroke, Paint paint) {
    if (stroke.points.isEmpty) return;

    paint.style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(stroke.points.first.dx, stroke.points.first.dy);

    for (int i = 1; i < stroke.points.length; i++) {
      final p1 = stroke.points[i - 1];
      final p2 = stroke.points[i];

      // Use quadratic bezier for smoother curves
      if (i < stroke.points.length - 1) {
        final midPoint = Offset(
          (p1.dx + p2.dx) / 2,
          (p1.dy + p2.dy) / 2,
        );
        path.quadraticBezierTo(p1.dx, p1.dy, midPoint.dx, midPoint.dy);
      } else {
        path.lineTo(p2.dx, p2.dy);
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawRectangle(Canvas canvas, DrawingRectangle rectangle, Paint paint) {
    paint.style = rectangle.filled ? PaintingStyle.fill : PaintingStyle.stroke;
    canvas.drawRect(rectangle.rect, paint);
  }

  void _drawCircle(Canvas canvas, DrawingCircle circle, Paint paint) {
    paint.style = circle.filled ? PaintingStyle.fill : PaintingStyle.stroke;
    canvas.drawCircle(circle.center, circle.radius, paint);
  }

  void _drawLine(Canvas canvas, DrawingLine line, Paint paint) {
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(line.start, line.end, paint);
  }

  void _drawText(Canvas canvas, DrawingText textElement) {
    final textStyle = TextStyle(
      color: textElement.color,
      fontSize: textElement.fontSize,
      fontWeight: FontWeight.bold,
    );

    final textSpan = TextSpan(
      text: textElement.text,
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout();
    
    // Center the text at the specified position
    final offset = Offset(
      textElement.position.dx - (textPainter.width / 2),
      textElement.position.dy - (textPainter.height / 2),
    );
    
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(DrawingCanvasPainter oldDelegate) {
    return oldDelegate.elements != elements ||
        oldDelegate.tempElement != tempElement;
  }
}
