import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:artiq_flutter/src/models/template.dart';
import 'package:artiq_flutter/src/models/canvas_models.dart';
import 'package:flutter/material.dart';

class TemplateLoader {
  /// Load a template from JSON file
  static Future<DesignTemplate> loadTemplate(String templateId) async {
    final jsonString = await rootBundle.loadString(
      'assets/templates/data/$templateId.json',
    );
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    
    return _parseTemplate(jsonData);
  }
  
  /// Load all templates
  static Future<List<DesignTemplate>> loadAllTemplates() async {
    final templateIds = [
      'instagram_post_motivational',
      'instagram_post_business',
      'instagram_post_sale',
      'instagram_story_quote',
      'youtube_thumbnail_tutorial',
      'business_card_modern',
      'flyer_event',
      'linkedin_post_hiring',
    ];
    
    final templates = <DesignTemplate>[];
    for (final id in templateIds) {
      try {
        final template = await loadTemplate(id);
        templates.add(template);
      } catch (e) {
        print('Error loading template $id: $e');
      }
    }
    
    return templates;
  }
  
  /// Parse template from JSON
  static DesignTemplate _parseTemplate(Map<String, dynamic> json) {
    final size = json['size'] as Map<String, dynamic>;
    final elementsJson = json['elements'] as List;
    
    final elements = elementsJson
        .map((e) => _parseElement(e as Map<String, dynamic>))
        .toList();
    
    return DesignTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      width: size['width'] as int,
      height: size['height'] as int,
      description: json['description'] as String? ?? '',
      thumbnailUrl: json['thumbnail'] as String?,
      elements: elements,
    );
  }
  
  /// Parse drawing element from JSON
  static DrawingElement _parseElement(Map<String, dynamic> json) {
    final type = json['type'] as String;
    final id = json['id'] as String;
    final color = Color(json['color'] as int);
    final strokeWidth = (json['strokeWidth'] as num).toDouble();
    final createdAt = DateTime.parse(json['createdAt'] as String);
    
    switch (type) {
      case 'rectangle':
        final topLeft = json['topLeft'] as Map<String, dynamic>;
        final bottomRight = json['bottomRight'] as Map<String, dynamic>;
        return DrawingRectangle(
          id: id,
          color: color,
          strokeWidth: strokeWidth,
          createdAt: createdAt,
          topLeft: Offset(
            (topLeft['x'] as num).toDouble(),
            (topLeft['y'] as num).toDouble(),
          ),
          bottomRight: Offset(
            (bottomRight['x'] as num).toDouble(),
            (bottomRight['y'] as num).toDouble(),
          ),
          filled: json['filled'] as bool? ?? false,
        );
        
      case 'circle':
        final center = json['center'] as Map<String, dynamic>;
        return DrawingCircle(
          id: id,
          color: color,
          strokeWidth: strokeWidth,
          createdAt: createdAt,
          center: Offset(
            (center['x'] as num).toDouble(),
            (center['y'] as num).toDouble(),
          ),
          radius: (json['radius'] as num).toDouble(),
          filled: json['filled'] as bool? ?? false,
        );
        
      case 'text':
        final position = json['position'] as Map<String, dynamic>;
        return DrawingText(
          id: id,
          color: color,
          strokeWidth: strokeWidth,
          createdAt: createdAt,
          text: json['text'] as String,
          position: Offset(
            (position['x'] as num).toDouble(),
            (position['y'] as num).toDouble(),
          ),
          fontSize: (json['fontSize'] as num?)?.toDouble() ?? 24.0,
          fontFamily: json['fontFamily'] as String? ?? 'Roboto',
        );
        
      case 'line':
        final start = json['start'] as Map<String, dynamic>;
        final end = json['end'] as Map<String, dynamic>;
        return DrawingLine(
          id: id,
          color: color,
          strokeWidth: strokeWidth,
          createdAt: createdAt,
          start: Offset(
            (start['x'] as num).toDouble(),
            (start['y'] as num).toDouble(),
          ),
          end: Offset(
            (end['x'] as num).toDouble(),
            (end['y'] as num).toDouble(),
          ),
        );
        
      default:
        throw Exception('Unknown element type: $type');
    }
  }
}
