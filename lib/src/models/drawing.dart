import 'package:flutter/material.dart';

class Drawing {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  Drawing({required this.points, required this.color, required this.strokeWidth});
}
