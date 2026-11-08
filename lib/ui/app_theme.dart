import 'package:flutter/material.dart';

/// Cores do Bukanero, tiradas do ícone: azul-marinho e dourado.
abstract final class BukaneroColors {
  static const Color gold = Color(0xFFD9AC4F);
  static const Color goldSoft = Color(0xFF3A3121);
  static const Color navy0 = Color(0xFF0B1328);
  static const Color navy1 = Color(0xFF0F1A33);
  static const Color navy2 = Color(0xFF14213F);
  static const Color navy3 = Color(0xFF19284B);
  static const Color navy4 = Color(0xFF1F3158);
  static const Color text = Color(0xFFE9E6DD);
  static const Color textSoft = Color(0xFFA9B0C2);
}

/// Tema escuro: fundo azul-marinho liso, cartões sem borda e o dourado só
/// nos destaques (selecionado, tocando, favorito).
ThemeData bukaneroDarkTheme() {
  const ColorScheme cs = ColorScheme(
    brightness: Brightness.dark,
    primary: BukaneroColors.gold,
    onPrimary: Color(0xFF221800),
    primaryContainer: BukaneroColors.goldSoft,
    onPrimaryContainer: Color(0xFFF5D990),
    secondary: Color(0xFF9DB4E6),
    onSecondary: BukaneroColors.navy0,
    secondaryContainer: BukaneroColors.navy4,
    onSecondaryContainer: BukaneroColors.text,
    tertiary: Color(0xFF7FC8B8),
    onTertiary: BukaneroColors.navy0,
    error: Color(0xFFFF8A80),
    onError: Color(0xFF3B0A08),
    surface: BukaneroColors.navy1,
    onSurface: BukaneroColors.text,
    onSurfaceVariant: BukaneroColors.textSoft,
    surfaceContainerLowest: BukaneroColors.navy0,
    surfaceContainerLow: BukaneroColors.navy1,
    surfaceContainer: BukaneroColors.navy2,
    surfaceContainerHigh: BukaneroColors.navy3,
    surfaceContainerHighest: BukaneroColors.navy4,
    outline: Color(0xFF3B4C74),
    outlineVariant: Color(0xFF243559),
  );
  return ThemeData(
    colorScheme: cs,
    useMaterial3: true,
    scaffoldBackgroundColor: BukaneroColors.navy1,
    appBarTheme: const AppBarTheme(
      backgroundColor: BukaneroColors.navy0,
      foregroundColor: BukaneroColors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: BukaneroColors.navy2,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF1C2A4D),
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: BukaneroColors.navy2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: BukaneroColors.gold),
      ),
    ),
    listTileTheme: const ListTileThemeData(selectedColor: BukaneroColors.gold),
    tooltipTheme: const TooltipThemeData(
      waitDuration: Duration(milliseconds: 500),
    ),
  );
}
