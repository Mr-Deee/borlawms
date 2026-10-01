import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  bool _isSwitched = false;
  bool get isSwitched => _isSwitched;

  /// ✅ NEW: Set the switch directly.
  /// Used by the Firebase listener in homepage.dart to keep the UI
  /// in sync with `availableWMS/<uid>`.
  void setSwitch(bool value) {
    if (_isSwitched == value) return;
    _isSwitched = value;
    notifyListeners();
  }

  /// Flip the switch (kept for compatibility with other screens)
  Future<void> toggleSwitch() async {
    _isSwitched = !_isSwitched;
    notifyListeners();
  }
}