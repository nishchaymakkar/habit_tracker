import 'package:flutter/material.dart';
import 'package:habit_tracker/theme/light_mode.dart';

import 'dark_mode.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = lightMode;


  //get current Theme
  ThemeData get themeData => _themeData;

  // is dark mode
  bool get isDarkMode => _themeData == darkMode;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }
  void toggleTheme(){
    if(_themeData == lightMode){
      _themeData = darkMode;
    }else{
      _themeData = lightMode;
    }
  }
}
