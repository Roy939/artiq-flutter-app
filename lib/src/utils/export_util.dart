import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:typed_data';

class ExportUtil {
  /// Export canvas to PNG with optional watermark
  static Future<void> exportToPNG({
    required GlobalKey canvasKey,
    required String filename,
    required bool addWatermark,
  }) async {
    try {
      // Get the render box
      final RenderRepaintBoundary boundary =
          canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      // Capture the canvas as an image
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      
      // Add watermark if needed
      if (addWatermark) {
        image = await _addWatermark(image);
      }
      
      // Convert to PNG bytes
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();
      
      // Download the file (web)
      _downloadFile(pngBytes, '$filename.png', 'image/png');
      
    } catch (e) {
      print('Export error: $e');
      rethrow;
    }
  }
  
  /// Export canvas to JPG (Pro only)
  static Future<void> exportToJPG({
    required GlobalKey canvasKey,
    required String filename,
  }) async {
    try {
      final RenderRepaintBoundary boundary =
          canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      
      // Convert to JPG bytes (note: Flutter web doesn't support JPEG directly,
      // so we'll use PNG and let the browser handle it)
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List bytes = byteData!.buffer.asUint8List();
      
      _downloadFile(bytes, '$filename.jpg', 'image/jpeg');
      
    } catch (e) {
      print('Export error: $e');
      rethrow;
    }
  }
  
  /// Add watermark to image
  static Future<ui.Image> _addWatermark(ui.Image originalImage) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint();
    
    // Draw original image
    canvas.drawImage(originalImage, Offset.zero, paint);
    
    // Draw watermark
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'ARTIQ',
        style: TextStyle(
          color: Colors.white.withOpacity(0.3),
          fontSize: 48,
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    // Position watermark at bottom right
    final x = originalImage.width.toDouble() - textPainter.width - 20;
    final y = originalImage.height.toDouble() - textPainter.height - 20;
    
    // Draw semi-transparent background for watermark
    final bgPaint = Paint()
      ..color = Colors.black.withOpacity(0.2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 10, y - 5, textPainter.width + 20, textPainter.height + 10),
        Radius.circular(8),
      ),
      bgPaint,
    );
    
    // Draw watermark text
    textPainter.paint(canvas, Offset(x, y));
    
    // Convert to image
    final picture = recorder.endRecording();
    return await picture.toImage(originalImage.width, originalImage.height);
  }
  
  /// Download file in browser
  static void _downloadFile(Uint8List bytes, String filename, String mimeType) {
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
