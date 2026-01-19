import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:artiq_flutter/src/models/design.dart';
import 'package:artiq_flutter/src/services/local_storage_service.dart';

final designsProvider = StateNotifierProvider<DesignsNotifier, List<Design>>((ref) {
  final localStorageService = ref.watch(localStorageServiceProvider);
  return DesignsNotifier(localStorageService);
});

class DesignsNotifier extends StateNotifier<List<Design>> {
  final LocalStorageService _localStorageService;

  DesignsNotifier(this._localStorageService) : super([]) {
    _loadDesigns();
  }

  Future<void> _loadDesigns() async {
    state = await _localStorageService.getDesigns();
  }

  Future<void> addDesign(Design design) async {
    await _localStorageService.addDesign(design);
    state = [...state, design];
  }

  Future<void> updateDesign(Design design) async {
    await _localStorageService.updateDesign(design);
    state = [      for (final d in state)        if (d.id == design.id) design else d,    ];
  }

  Future<void> deleteDesign(String designId) async {
    await _localStorageService.deleteDesign(designId);
    state = state.where((d) => d.id != designId).toList();
  }

  Future<void> refreshDesigns() async {
    await _loadDesigns();
  }
}
