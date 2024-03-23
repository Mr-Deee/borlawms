import 'package:flutter/material.dart';

class AppState with ChangeNotifier {
  bool _isSwitched = false;

  bool get isSwitched => _isSwitched;

  void toggleSwitch() {
    _isSwitched = !_isSwitched;
    notifyListeners();
  }
}