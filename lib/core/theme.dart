import 'package:flutter/material.dart';

abstract final class FurniteTheme {
  static const ink = Color(0xFF43484B), muted = Color(0xFF9B9FC3);
  static const yellow = Color(0xFFFFC657), orange = Color(0xFFF5AA17);
  static const line = Color(0xFFEDEDF3), green = Color(0xFF1CC262);
  static const shadow = BoxShadow(
    color: Color(0x12000000),
    blurRadius: 16,
    offset: Offset(0, 5),
  );
  static ThemeData get data => ThemeData(
    useMaterial3: true,
    fontFamily: 'Muli',
    iconTheme: const IconThemeData(color: ink),
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: yellow,
      primary: orange,
      onPrimary: ink,
      surface: Colors.white,
      onSurface: ink,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 35,
        height: 1.36,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      headlineMedium: TextStyle(
        fontSize: 30,
        height: 1.1,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: ink),
      bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: muted),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
    ),
    dividerTheme: const DividerThemeData(color: line, thickness: 1, space: 32),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: muted, fontSize: 14),
      hintStyle: TextStyle(color: Color(0xFFBDBDBC)),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFD7D7D7)),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: orange, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 14),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: orange),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: ink,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
