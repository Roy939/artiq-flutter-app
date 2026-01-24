import 'dart:convert';
import '../utils/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:artiq_flutter/src/data/designs_provider.dart';
import 'package:artiq_flutter/src/models/design.dart';
import 'package:artiq_flutter/src/widgets/pen_tool_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateDesignScreen extends ConsumerStatefulWidget {
  const CreateDesignScreen({Key? key}) : super(key: key);

  @override
  _CreateDesignScreenState createState() => _CreateDesignScreenState();
}

class _CreateDesignScreenState extends ConsumerState<CreateDesignScreen> {
  final _titleController = TextEditingController();
  final _penToolKey = GlobalKey<PenToolWidgetState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Design'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('You must be logged in to save designs')),
                );
                return;
              }
              
              final drawings = _penToolKey.currentState?.drawings;
              if (drawings != null && drawings.isNotEmpty) {
                final newDesign = Design(
                  id: const Uuid().v4(),
                  userId: user.uid,
                  title: _titleController.text,
                  content: jsonEncode(drawings.map((d) => {
                    'points': d.points.map((p) => {'dx': p.dx, 'dy': p.dy}).toList(),
                    'color': d.color.value,
                    'strokeWidth': d.strokeWidth,
                  }).toList()),
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  isSynced: false,
                );
                await ref.read(designsProvider.notifier).addDesign(newDesign);
                Navigator.of(context).pop();
              }
            },
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: PenToolWidget(key: _penToolKey),
          ),
        ],
          ),
        ),
      ),
    );
  }
}
