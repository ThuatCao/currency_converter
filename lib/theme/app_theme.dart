
import 'package:currency_converter/constants/color_util.dart';
import 'package:flutter/material.dart';

abstract class AppTheme {
  static ThemeData lightTheme(){
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: neutralColor,
      primaryColor: primaryColor,
    );
  }

  static ThemeData darkTheme(){
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: neutralDarkColor,
      primaryColor: primaryColor,
    );
  }
}