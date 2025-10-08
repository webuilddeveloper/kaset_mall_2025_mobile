import 'package:flutter/material.dart';

class Styles {
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    return ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: isDarkTheme ? Colors.black : Color(0xFF1794D2),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        background: isDarkTheme ? Color(0xFF505050) : Colors.white,
        primary: isDarkTheme ? Color(0xff3B3B3B) : Color(0xffF1F5FB),
        secondary: isDarkTheme ? Colors.black : Colors.white,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: isDarkTheme ? Color(0xFFE4E4E4) : Color(0xFF707070),
        selectionColor: isDarkTheme ? Colors.white : Colors.black,
      ),
      indicatorColor: isDarkTheme ? Color(0xff0E1D36) : Color(0xffCBDCF8),
      hintColor: isDarkTheme ? Color(0xff280C0B) : Color(0xFF505050),
      highlightColor: isDarkTheme ? Color(0xff372901) : Color(0xffc0c0c0),
      hoverColor: isDarkTheme ? Color(0xff9CE0F6) : Color(0xff4285F4),
      focusColor: isDarkTheme ? Color(0xff0B2512) : Color(0xffA8DAB5),
      disabledColor: Colors.grey,
      cardColor: isDarkTheme ? Color(0xFF151515) : Colors.white,
      canvasColor: isDarkTheme ? Colors.black : Colors.grey[50],
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      buttonTheme: Theme.of(context).buttonTheme.copyWith(
          colorScheme: isDarkTheme ? ColorScheme.dark() : ColorScheme.light()),
      appBarTheme: AppBarTheme(
        elevation: 0.0,
      ),
    );
  }
}
