import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:artiq_flutter/src/api/api_service.dart';
import 'package:artiq_flutter/src/services/local_storage_service.dart';
import 'package:artiq_flutter/src/models/design.dart';
import 'package:firebase_auth/firebase_auth.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final apiService = ApiService();
  final localStorageService = ref.watch(localStorageServiceProvider);
  return SyncService(apiService, localStorageService);
});

class SyncService {
  final ApiService _apiService;
  final LocalStorageService _localStorageService;

  SyncService(this._apiService, this._localStorageService);

  Future<void> syncDesigns() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return; // No internet connection
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return; // Not logged in
    }

    final unsyncedDesigns = await _localStorageService.getUnsyncedDesigns();

    for (final design in unsyncedDesigns) {
      try {
        if (design.isSynced == false) {
          // This is a new or updated design
          final syncedDesign = await _apiService.createDesign(design);
          await _localStorageService.updateDesign(syncedDesign.copyWith(isSynced: true));
        }
      } catch (e) {
        print('Failed to sync design ${design.id}: $e');
      }
    }

    try {
      final remoteDesigns = await _apiService.getDesigns(user.uid);
      await _localStorageService.saveDesigns(remoteDesigns);
    } catch (e) {
      print('Failed to fetch remote designs: $e');
    }
  }
}
