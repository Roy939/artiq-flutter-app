import 'package:flutter/foundation.dart';

class DemoModeProvider extends ChangeNotifier {
  bool _isDemoMode = false;
  
  bool get isDemoMode => _isDemoMode;
  
  void enableDemoMode() {
    _isDemoMode = true;
    notifyListeners();
  }
  
  void disableDemoMode() {
    _isDemoMode = false;
    notifyListeners();
  }
}
