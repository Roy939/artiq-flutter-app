import 'dart:convert';
import '../utils/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:artiq_flutter/src/data/designs_provider.dart';
import 'package:artiq_flutter/src/models/design.dart';
import 'package:artiq_flutter/src/models/canvas_models.dart';
import 'package:artiq_flutter/src/models/template.dart';
import 'package:artiq_flutter/src/widgets/drawing_canvas.dart';
import 'package:artiq_flutter/src/widgets/drawing_toolbar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateDesignScreen extends ConsumerStatefulWidget {
  final DesignTemplate? templateToUse;
  final Design? existingDesign;
  
  const CreateDesignScreen({Key? key, this.templateToUse, this.existingDesign}) : super(key: key);

  @override
  _CreateDesignScreenState createState() => _CreateDesignScreenState();
}

class _CreateDesignScreenState extends ConsumerState<CreateDesignScreen> {
  final _titleController = TextEditingController();
  CanvasState _canvasState = CanvasState();
  final List<CanvasState> _undoStack = [];
  final List<CanvasState> _redoStack = [];

  @override
  void initState() {
    super.initState();
    
    // Initialize canvas with existing design if provided
    if (widget.existingDesign != null) {
      print('[ARTIQ DEBUG] Loading existing design: ${widget.existingDesign!.title}');
      try {
        _canvasState = CanvasState.fromJson(jsonDecode(widget.existingDesign!.content));
        _titleController.text = widget.existingDesign!.title;
        print('[ARTIQ DEBUG] Design loaded with ${_canvasState.elements.length} elements');
      } catch (e) {
        print('[ARTIQ ERROR] Failed to load design: $e');
      }
    }
    // Initialize canvas with template elements if template is provided
    else if (widget.templateToUse != null) {
      print('[ARTIQ DEBUG] Loading template: ${widget.templateToUse!.name}');
      print('[ARTIQ DEBUG] Template has ${widget.templateToUse!.elements.length} elements');
      _canvasState = CanvasState(
        elements: List.from(widget.templateToUse!.elements),
      );
      // Set default title from template name
      _titleController.text = widget.templateToUse!.name;
      print('[ARTIQ DEBUG] Canvas initialized with ${_canvasState.elements.length} elements');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _updateCanvasState(CanvasState newState) {
    setState(() {
      // Save current state to undo stack when elements change
      if (newState.elements.length != _canvasState.elements.length) {
        _undoStack.add(_canvasState);
        _redoStack.clear();
      }
      _canvasState = newState;
    });
  }

  void _undo() {
    if (_undoStack.isNotEmpty) {
      setState(() {
        _redoStack.add(_canvasState);
        _canvasState = _undoStack.removeLast();
      });
    }
  }

  void _redo() {
    if (_redoStack.isNotEmpty) {
      setState(() {
        _undoStack.add(_canvasState);
        _canvasState = _redoStack.removeLast();
      });
    }
  }

  void _clear() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Canvas'),
        content: const Text('Are you sure you want to clear the entire canvas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _undoStack.add(_canvasState);
                _redoStack.clear();
                _canvasState = _canvasState.copyWith(elements: []);
              });
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _exportPNG() {
    // For web, users can right-click on canvas and save as image
    // For mobile/desktop, we would need additional packages like screenshot or image
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Right-click on canvas and select "Save image as..." to export'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _saveDesign() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to save designs')),
      );
      return;
    }

    if (_canvasState.elements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Canvas is empty! Draw something first.')),
      );
      return;
    }

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title for your design')),
      );
      return;
    }

    try {
      final newDesign = Design(
        id: const Uuid().v4(),
        userId: user.uid,
        title: title,
        content: jsonEncode(_canvasState.toJson()),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: false,
      );

      await ref.read(designsProvider.notifier).addDesign(newDesign);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Design saved successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving design: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Design'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDesign,
            tooltip: 'Save Design',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveLayout.getMaxContentWidth(context),
          ),
          child: Column(
            children: [
              // Title input
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Design Title',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
              ),
              // Drawing canvas
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: DrawingCanvas(
                      canvasState: _canvasState,
                      onStateChanged: _updateCanvasState,
                    ),
                  ),
                ),
              ),
              // Toolbar
              DrawingToolbar(
                canvasState: _canvasState,
                onStateChanged: _updateCanvasState,
                onUndo: _undo,
                onRedo: _redo,
                onClear: _clear,
                onExport: _exportPNG,
                canUndo: _undoStack.isNotEmpty,
                canRedo: _redoStack.isNotEmpty,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
