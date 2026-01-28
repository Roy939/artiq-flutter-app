import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import '../models/canvas_models.dart';

class ExportUtil {
  /// Export canvas to PNG with optional watermark (Web-compatible)
  static Future<void> exportToPNG({
    required CanvasState canvasState,
    required String filename,
    required bool addWatermark,
  }) async {
    try {
      // Create HTML canvas
      final canvas = html.CanvasElement(
        width: canvasState.width.toInt(),
        height: canvasState.height.toInt(),
      );
      final ctx = canvas.context2D;
      
      // Draw background
      ctx.fillStyle = _colorToHex(canvasState.backgroundColor);
      ctx.fillRect(0, 0, canvas.width!, canvas.height!);
      
      // Draw all elements
      for (final element in canvasState.elements) {
        _drawElement(ctx, element);
      }
      
      // Add watermark if needed
      if (addWatermark) {
        _addWatermarkToCanvas(ctx, canvas.width!.toDouble(), canvas.height!.toDouble());
      }
      
      // Convert to blob and download
      canvas.toBlob((blob) {
        if (blob != null) {
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.AnchorElement(href: url)
            ..setAttribute('download', '$filename.png')
            ..click();
          html.Url.revokeObjectUrl(url);
        }
      }, 'image/png');
      
    } catch (e) {
      print('Export error: $e');
      rethrow;
    }
  }
  
  /// Export canvas to JPG (Pro only)
  static Future<void> exportToJPG({
    required CanvasState canvasState,
    required String filename,
  }) async {
    try {
      final canvas = html.CanvasElement(
        width: canvasState.width.toInt(),
        height: canvasState.height.toInt(),
      );
      final ctx = canvas.context2D;
      
      // Draw white background for JPG
      ctx.fillStyle = '#FFFFFF';
      ctx.fillRect(0, 0, canvas.width!, canvas.height!);
      
      // Draw background color
      ctx.fillStyle = _colorToHex(canvasState.backgroundColor);
      ctx.fillRect(0, 0, canvas.width!, canvas.height!);
      
      // Draw all elements
      for (final element in canvasState.elements) {
        _drawElement(ctx, element);
      }
      
      // Convert to blob and download
      canvas.toBlob((blob) {
        if (blob != null) {
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.AnchorElement(href: url)
            ..setAttribute('download', '$filename.jpg')
            ..click();
          html.Url.revokeObjectUrl(url);
        }
      }, 'image/jpeg', 0.95);
      
    } catch (e) {
      print('Export error: $e');
      rethrow;
    }
  }
  
  /// Draw a single element on the canvas
  static void _drawElement(html.CanvasRenderingContext2D ctx, DrawingElement element) {
    ctx.save();
    
    if (element is RectangleElement) {
      ctx.fillStyle = _colorToHex(element.color);
      ctx.fillRect(
        element.offset.dx,
        element.offset.dy,
        element.size.width,
        element.size.height,
      );
    } else if (element is CircleElement) {
      ctx.fillStyle = _colorToHex(element.color);
      ctx.beginPath();
      ctx.arc(
        element.center.dx,
        element.center.dy,
        element.radius,
        0,
        2 * 3.14159,
      );
      ctx.fill();
    } else if (element is LineElement) {
      ctx.strokeStyle = _colorToHex(element.color);
      ctx.lineWidth = element.strokeWidth;
      ctx.beginPath();
      ctx.moveTo(element.start.dx, element.start.dy);
      ctx.lineTo(element.end.dx, element.end.dy);
      ctx.stroke();
    } else if (element is TextElement) {
      ctx.fillStyle = _colorToHex(element.color);
      ctx.font = '${element.fontSize}px ${element.fontFamily}';
      ctx.textAlign = 'left';
      ctx.textBaseline = 'top';
      ctx.fillText(element.text, element.offset.dx, element.offset.dy);
    } else if (element is PathElement) {
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
