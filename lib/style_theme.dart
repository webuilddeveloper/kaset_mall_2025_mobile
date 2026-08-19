import 'package:flutter/material.dart';
import 'package:kasetmall/shared/app_theme.dart';

class Styles {
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    return isDarkTheme ? AppTheme.dark() : AppTheme.light();
  }
}
