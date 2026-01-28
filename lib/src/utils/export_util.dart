import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../models/canvas_models.dart';

class ExportUtil {
  // Fixed canvas size (Instagram Post standard)
  static const double _canvasWidth = 1080;
  static const double _canvasHeight = 1080;
  
  /// Export canvas to PNG with optional watermark (Web-compatible)
  static Future<void> exportToPNG({
    required List<DrawingElement> elements,
    required String filename,
    required bool addWatermark,
  }) async {
    try {
      // Create HTML canvas
      final canvas = html.CanvasElement(
        width: _canvasWidth.toInt(),
        height: _canvasHeight.toInt(),
      );
      final ctx = canvas.context2D;
      
      // Draw white background
      ctx.fillStyle = '#FFFFFF';
      ctx.fillRect(0, 0, canvas.width!, canvas.height!);
      
      // Draw all elements
      for (final element in elements) {
        _drawElement(ctx, element);
      }
      
      // Add watermark if needed
      if (addWatermark) {
        _addWatermarkToCanvas(ctx, _canvasWidth, _canvasHeight);
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
  
  /// Export canvas to JPG (Pro only)
  static Future<void> exportToJPG({
    required List<DrawingElement> elements,
    required String filename,
  }) async {
    try {
      final canvas = html.CanvasElement(
        width: _canvasWidth.toInt(),
        height: _canvasHeight.toInt(),
      );
      final ctx = canvas.context2D;
      
      // Draw white background for JPG
      ctx.fillStyle = '#FFFFFF';
      ctx.fillRect(0, 0, canvas.width!, canvas.height!);
      
      // Draw all elements
      for (final element in elements) {
        _drawElement(ctx, element);
      }
      
      // Convert to data URL and download
      final dataUrl = canvas.toDataUrl('image/jpeg', 0.95);
      final anchor = html.AnchorElement(href: dataUrl)
        ..setAttribute('download', '$filename.jpg')
        ..click();
      
    } catch (e) {
      print('Export error: $e');
      rethrow;
    }
  }
  
  /// Draw a single element on the canvas
  static void _drawElement(html.CanvasRenderingContext2D ctx, DrawingElement element) {
    ctx.save();
    
    if (element is DrawingRectangle) {
      final rect = element.rect;
      if (element.filled) {
        ctx.fillStyle = _colorToHex(element.color);
        ctx.fillRect(rect.left, rect.top, rect.width, rect.height);
      } else {
        ctx.strokeStyle = _colorToHex(element.color);
        ctx.lineWidth = element.strokeWidth;
        ctx.strokeRect(rect.left, rect.top, rect.width, rect.height);
      }
    } else if (element is DrawingCircle) {
      ctx.beginPath();
      ctx.arc(
        element.center.dx,
        element.center.dy,
        element.radius,
        0,
        2 * 3.14159,
      );
      if (element.filled) {
        ctx.fillStyle = _colorToHex(element.color);
        ctx.fill();
      } else {
        ctx.strokeStyle = _colorToHex(element.color);
        ctx.lineWidth = element.strokeWidth;
        ctx.stroke();
      }
    } else if (element is DrawingLine) {
      ctx.strokeStyle = _colorToHex(element.color);
      ctx.lineWidth = element.strokeWidth;
      ctx.beginPath();
      ctx.moveTo(element.start.dx, element.start.dy);
      ctx.lineTo(element.end.dx, element.end.dy);
      ctx.stroke();
    } else if (element is DrawingText) {
      ctx.fillStyle = _colorToHex(element.color);
      ctx.font = '${element.fontSize}px ${element.fontFamily}';
      ctx.textAlign = 'left';
      ctx.textBaseline = 'top';
      ctx.fillText(element.text, element.position.dx, element.position.dy);
    } else if (element is DrawingStroke) {
      ctx.strokeStyle = _colorToHex(element.color);
      ctx.lineWidth = element.strokeWidth;
      ctx.beginPath();
      if (element.points.isNotEmpty) {
        ctx.moveTo(element.points.first.dx, element.points.first.dy);
        for (var i = 1; i < element.points.length; i++) {
          ctx.lineTo(element.points[i].dx, element.points[i].dy);
        }
      }
      ctx.stroke();
    }
    
    ctx.restore();
  }
  
  /// Add watermark to canvas
  static void _addWatermarkToCanvas(html.CanvasRenderingContext2D ctx, double width, double height) {
    ctx.save();
    
    // Draw semi-transparent background
    ctx.fillStyle = 'rgba(0, 0, 0, 0.2)';
    ctx.fillRect(width - 150, height - 60, 140, 50);
    
    // Draw watermark text
    ctx.fillStyle = 'rgba(255, 255, 255, 0.7)';
    ctx.font = 'bold 32px Arial';
    ctx.textAlign = 'right';
    ctx.textBaseline = 'bottom';
    ctx.fillText('ARTIQ', width - 20, height - 20);
    
    ctx.restore();
  }
  
  /// Convert Flutter Color to hex string
  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}
