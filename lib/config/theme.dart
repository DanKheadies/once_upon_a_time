import 'package:flutter/material.dart';

Color black400 = Color(0xFF1c1e1f);
Color black500 = Color(0xFF121212);
Color black900 = Color(0xFF000000);
Color gold500 = Color(0xFFe2c08e);
Color gold700 = Color(0xFFfac801);
Color green500 = Color(0xFF35c759);
Color red500 = Color(0xFFff5c60);
Color white500 = Color(0xFFf5f5f7);

Color parchment1 = Color(0xFF857946);
Color parchment2 = Color(0xFF89764F);
Color parchment3 = Color(0xFF85714D);
Color parchment4 = Color(0xFF827547);

ThemeData darkTheme() {
  return ThemeData.dark().copyWith(
    primaryColor: gold700,
    scaffoldBackgroundColor: black400,
    appBarTheme: AppBarTheme(backgroundColor: black500),
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: gold700,
      onPrimary: gold500,
      secondary: ThemeData.dark().colorScheme.secondary,
      onSecondary: ThemeData.dark().colorScheme.onSecondary,
      error: red500,
      onError: ThemeData.dark().colorScheme.onError,
      surface: white500,
      onSurface: white500,
      inverseSurface: black500,
    ),
    dialogTheme: DialogThemeData(backgroundColor: black400),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: gold700,
        foregroundColor: black500,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: gold700),
    ),
    // textTheme: TextTheme(),
  );
}
