class DesignTemplate {
  final String id;
  final String name;
  final String category;
  final int width;
  final int height;
  final String description;
  final String? thumbnailUrl;

  const DesignTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.width,
    required this.height,
    required this.description,
    this.thumbnailUrl,
  });

  // Helper method to get display size
  String get displaySize => '${width}x${height}px';
  
  // Helper method to get aspect ratio description
  String get aspectRatio {
    if (width == height) return 'Square';
    if (width > height) return 'Landscape';
    return 'Portrait';
  }
}
