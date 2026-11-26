import 'package:flutter/material.dart';

/// 시안(파란 테마·둥근 카드)에 맞춘 색상. 화면에서 직접 쓰는 색은 여기서만 정의한다.
const brandBlue = Color(0xFF2F6BFF);
const brandBlueDark = Color(0xFF1C3FA8);
const surfaceTint = Color(0xFFEEF3FF);

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: brandBlue, primary: brandBlue);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFFF5F8FF),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Color(0xFFF5F8FF),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(color: Color(0xFF1B2440), fontSize: 18, fontWeight: FontWeight.w700),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE3EAFB)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: surfaceTint,
      surfaceTintColor: Colors.transparent,
    ),
  );
}
