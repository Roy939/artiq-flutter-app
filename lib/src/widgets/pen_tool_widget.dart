import 'package:flutter/material.dart';
import 'package:artiq_flutter/src/models/drawing.dart';
import 'package:artiq_flutter/src/widgets/drawing_painter.dart';

class PenToolWidget extends StatefulWidget {
  const PenToolWidget({Key? key}) : super(key: key);

  @override
  PenToolWidgetState createState() => PenToolWidgetState();
}

class PenToolWidgetState extends State<PenToolWidget> {
  List<Drawing> drawings = [];
  Drawing? currentDrawing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          currentDrawing = Drawing(
            points: [details.localPosition],
            color: Colors.black,
            strokeWidth: 5.0,
          );
        });
      },
      onPanUpdate: (details) {
        setState(() {
          currentDrawing = Drawing(
            points: [...currentDrawing!.points, details.localPosition],
            color: currentDrawing!.color,
            strokeWidth: currentDrawing!.strokeWidth,
          );
        });
      },
      onPanEnd: (details) {
        setState(() {
          drawings.add(currentDrawing!);
          currentDrawing = null;
        });
      },
      child: CustomPaint(
        painter: DrawingPainter(drawings: drawings),
        child: Container(),
      ),
    );
  }
}
