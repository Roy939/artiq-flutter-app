import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:ui' as ui;
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
    } else if (element is DrawingImage) {
      _drawImage(canvas, element);
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
      fontFamily: textElement.fontFamily,
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

  void _drawImage(Canvas canvas, DrawingImage imageElement) {
    try {
      // Decode base64 image
      final bytes = base64Decode(imageElement.imageData);
      final codec = ui.instantiateImageCodec(bytes);
      
      // Note: This is synchronous decoding which may cause performance issues
      // For production, consider using a FutureBuilder or caching decoded images
      codec.then((codec) {
        codec.getNextFrame().then((frameInfo) {
          final image = frameInfo.image;
          
          // Draw image at position with specified size
          final srcRect = Rect.fromLTWH(
            0,
            0,
            image.width.toDouble(),
            image.height.toDouble(),
          );
          
          final dstRect = Rect.fromLTWH(
            imageElement.position.dx,
            imageElement.position.dy,
            imageElement.width,
            imageElement.height,
          );
          
          canvas.drawImageRect(image, srcRect, dstRect, Paint());
        });
      });
    } catch (e) {
      // If image fails to decode, draw a placeholder
      final paint = Paint()
        ..color = Colors.grey.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      
      canvas.drawRect(
        Rect.fromLTWH(
          imageElement.position.dx,
          imageElement.position.dy,
          imageElement.width,
          imageElement.height,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(DrawingCanvasPainter oldDelegate) {
    return oldDelegate.elements != elements ||
        oldDelegate.tempElement != tempElement;
  }
}
