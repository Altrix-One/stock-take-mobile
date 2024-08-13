import 'package:flutter/material.dart';

class StockTakeNotifier extends ChangeNotifier {
  String _countType = 'Count type';

  String get countType => _countType;

  void setCountType(String newCountType) {
    _countType = newCountType;
    notifyListeners();
  }
}
