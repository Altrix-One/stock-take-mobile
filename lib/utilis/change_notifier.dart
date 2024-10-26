import 'package:flutter/material.dart';

class StockTakeNotifier extends ChangeNotifier {
  String _countType = 'Count type';
  String _scannedData = '';

  String get countType => _countType;
  String get scannedData => _scannedData;

  void setCountType(String newCountType) {
    _countType = newCountType;
    notifyListeners();
  }

  void setScannedData(String newScannedData) {
    _scannedData = newScannedData;
    notifyListeners(); // Notify listeners of the change
  }
}
