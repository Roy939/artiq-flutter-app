import 'package:flutter/material.dart';
import 'package:artiq_flutter/src/widgets/three_panel_editor.dart';

/// Simple editor screen that uses the 3-panel layout
class SimpleEditorScreen extends StatelessWidget {
  const SimpleEditorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ThreePanelEditor();
  }
}
