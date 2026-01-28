import 'dart:convert';
import '../utils/responsive_layout.dart';
import '../utils/export_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:uuid/uuid.dart';
import 'package:artiq_flutter/src/data/designs_provider.dart';
import 'package:artiq_flutter/src/models/design.dart';
import 'package:artiq_flutter/src/models/canvas_models.dart';
import 'package:artiq_flutter/src/models/template.dart';
import 'package:artiq_flutter/src/widgets/drawing_canvas.dart';
import 'package:artiq_flutter/src/widgets/drawing_toolbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:artiq_flutter/src/providers/subscription_provider.dart';
import 'package:artiq_flutter/src/models/subscription_model.dart';

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
    // Show export options dialog
    _showExportDialog();
  }

  void _showExportDialog() {
    final subscriptionProvider = provider.Provider.of<SubscriptionProvider>(context, listen: false);
    final tier = subscriptionProvider.currentTier;
    final isFree = tier == SubscriptionTier.free;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Design'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isFree)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Free tier exports include watermark. Upgrade to Pro for watermark-free exports!',
                        style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                      ),
                    ),
                  ],
                ),
              ),
            const Text('Choose export format:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.blue),
              title: const Text('PNG'),
              subtitle: Text(isFree ? 'High quality (with watermark)' : 'High quality, transparent background'),
              onTap: () {
                Navigator.pop(context);
                _exportAs('png');
              },
            ),
            ListTile(
              leading: Icon(Icons.image, color: isFree ? Colors.grey : Colors.green),
              title: Row(
                children: [
                  const Text('JPG'),
                  if (isFree) ...[const SizedBox(width: 8), const Icon(Icons.lock, size: 16, color: Colors.grey)],
                ],
              ),
              subtitle: const Text('Smaller file size, white background'),
              enabled: !isFree,
              onTap: isFree ? null : () {
                Navigator.pop(context);
                _exportAs('jpg');
              },
            ),
            ListTile(
              leading: Icon(Icons.picture_as_pdf, color: isFree ? Colors.grey : Colors.red),
              title: Row(
                children: [
                  const Text('PDF'),
                  if (isFree) ...[const SizedBox(width: 8), const Icon(Icons.lock, size: 16, color: Colors.grey)],
                ],
              ),
              subtitle: const Text('Document format, printable'),
              enabled: !isFree,
              onTap: isFree ? null : () {
                Navigator.pop(context);
                _exportAs('pdf');
              },
            ),
          ],
        ),
        actions: [
          if (isFree)
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                subscriptionProvider.openCheckout(context);
              },
              icon: const Icon(Icons.star, color: Colors.blue),
              label: const Text('Upgrade to Pro'),
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportAs(String format) async {
    try {
      final subscriptionProvider = provider.Provider.of<SubscriptionProvider>(context, listen: false);
      final isFree = subscriptionProvider.currentTier == SubscriptionTier.free;
      final filename = _titleController.text.isEmpty ? 'artiq_design' : _titleController.text;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exporting as $format...'),
          duration: const Duration(seconds: 2),
        ),
      );
      
      if (format == 'png') {
        await ExportUtil.exportToPNG(
          elements: _canvasState.elements,
          filename: filename,
          addWatermark: !subscription.isPro,
        );
      } else if (format == 'jpg') {
        await ExportUtil.exportToJPG(
          elements: _canvasState.elements,
          filename: filename,
        );
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Exported as $format successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
