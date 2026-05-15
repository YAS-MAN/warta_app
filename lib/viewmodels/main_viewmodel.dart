import 'package:flutter/material.dart';

class MainViewModel extends ChangeNotifier {
  int _currentIndex = 0; // Default di halaman Home (index 0)

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if (index != 2) { // Index 2 adalah tombol kamera di tengah (bukan tab)
      _currentIndex = index;
      notifyListeners(); // Memberitahu UI untuk merender ulang halaman
    }
  }
}
