import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../providers/canvas_state_provider.dart';

class CanvasExportUtil {
  // Canvas size - matches the display canvas
  static const double canvasWidth = 1080;
  static const double canvasHeight = 1080;
  
  /// Export canvas elements to PNG
  static Future<void> exportToPNG({
    required List<CanvasElement> elements,
    required double width,
    required double height,
    String filename = 'artiq_design',
  }) async {
    try {
      // Create HTML canvas
      final canvas = html.CanvasElement(
        width: width.toInt(),
        height: height.toInt(),
      );
      final ctx = canvas.context2D;
      
      // Draw white background
      ctx.fillStyle = '#FFFFFF';
      ctx.fillRect(0, 0, canvas.width!, canvas.height!);
      
      // Draw all elements
      for (final element in elements) {
        _drawElement(ctx, element);
      }
      
      // Convert to data URL and download
      final dataUrl = canvas.toDataUrl('image/png');
      final anchor = html.AnchorElement(href: dataUrl)
        ..setAttribute('download', '$filename.png')
        ..click();
      
    } catch (e) {
      print('Export error: $e');
      rethrow;
    }
  }
  
  /// Draw a single canvas element
  static void _drawElement(html.CanvasRenderingContext2D ctx, CanvasElement element) {
    ctx.save();
    
    switch (element.type) {
      case ElementType.path:
        // Draw pen path
        if (element.points.length > 1) {
          ctx.strokeStyle = _colorToHex(element.color);
          ctx.lineWidth = element.strokeWidth;
          ctx.lineCap = 'round';
          ctx.lineJoin = 'round';
          ctx.beginPath();
          ctx.moveTo(element.points.first.dx, element.points.first.dy);
          for (var i = 1; i < element.points.length; i++) {
            ctx.lineTo(element.points[i].dx, element.points[i].dy);
          }
          ctx.stroke();
        }
        break;
        
      case ElementType.rectangle:
        // Draw rectangle
        final rect = element.bounds;
        if (element.filled) {
          ctx.fillStyle = _colorToHex(element.color);
          ctx.fillRect(rect.left, rect.top, rect.width, rect.height);
        } else {
          ctx.strokeStyle = _colorToHex(element.color);
          ctx.lineWidth = element.strokeWidth;
          ctx.strokeRect(rect.left, rect.top, rect.width, rect.height);
        }
        break;
        
      case ElementType.circle:
        // Draw circle
        final center = element.bounds.center;
        final radius = (element.bounds.width + element.bounds.height) / 4;
        ctx.beginPath();
        ctx.arc(center.dx, center.dy, radius, 0, 2 * 3.14159);
        if (element.filled) {
          ctx.fillStyle = _colorToHex(element.color);
          ctx.fill();
        } else {
          ctx.strokeStyle = _colorToHex(element.color);
          ctx.lineWidth = element.strokeWidth;
          ctx.stroke();
        }
        break;
        
      case ElementType.line:
        // Draw line
        ctx.strokeStyle = _colorToHex(element.color);
        ctx.lineWidth = element.strokeWidth;
        ctx.beginPath();
        ctx.moveTo(element.bounds.topLeft.dx, element.bounds.topLeft.dy);
        ctx.lineTo(element.bounds.bottomRight.dx, element.bounds.bottomRight.dy);
        ctx.stroke();
        break;
        
      case ElementType.text:
        // Draw text
        ctx.fillStyle = _colorToHex(element.color);
        final fontWeight = element.fontWeight == FontWeight.bold || element.fontWeight.index >= 6 ? 'bold' : 'normal';
        ctx.font = '$fontWeight ${element.fontSize}px ${element.fontFamily}';
        ctx.textAlign = 'left';
        ctx.textBaseline = 'top';
        ctx.fillText(element.text, element.bounds.left, element.bounds.top);
        break;
        
      case ElementType.image:
        // Draw image from base64 data
        if (element.imageData != null && element.imageData!.isNotEmpty) {
          final img = html.ImageElement();
          img.src = 'data:image/png;base64,${element.imageData}';
          // Note: For synchronous export, image must be loaded first
          // This is a limitation - images may not appear in export
          try {
            ctx.drawImageScaled(
              img,
              element.bounds.left,
              element.bounds.top,
              element.bounds.width,
              element.bounds.height,
            );
          } catch (e) {
            // If image not loaded, draw placeholder
            ctx.fillStyle = '#CCCCCC';
            ctx.fillRect(
              element.bounds.left,
              element.bounds.top,
              element.bounds.width,
              element.bounds.height,
            );
          }
        }
        break;
    }
    
    ctx.restore();
  }
  
  /// Convert Flutter Color to hex string
  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}
