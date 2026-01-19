import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:artiq_flutter/src/models/design.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) => LocalStorageService());

class LocalStorageService {
  static const _designsKey = 'designs';

  Future<List<Design>> getDesigns() async {
    final prefs = await SharedPreferences.getInstance();
    final designsJson = prefs.getStringList(_designsKey) ?? [];
    return designsJson.map((jsonString) => Design.fromJson(jsonDecode(jsonString))).toList();
  }

  Future<void> saveDesigns(List<Design> designs) async {
    final prefs = await SharedPreferences.getInstance();
    final designsJson = designs.map((design) => jsonEncode(design.toJson())).toList();
    await prefs.setStringList(_designsKey, designsJson);
  }

  Future<void> addDesign(Design design) async {
    final designs = await getDesigns();
    designs.add(design);
    await saveDesigns(designs);
  }

  Future<void> updateDesign(Design design) async {
    final designs = await getDesigns();
    final index = designs.indexWhere((d) => d.id == design.id);
    if (index != -1) {
      designs[index] = design;
      await saveDesigns(designs);
    }
  }

  Future<void> deleteDesign(String designId) async {
    final designs = await getDesigns();
    designs.removeWhere((d) => d.id == designId);
    await saveDesigns(designs);
  }

  Future<List<Design>> getUnsyncedDesigns() async {
    final designs = await getDesigns();
    return designs.where((design) => !design.isSynced).toList();
  }
}
