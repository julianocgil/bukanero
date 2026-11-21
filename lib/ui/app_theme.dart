import 'package:flutter/material.dart';

import '../data/app_settings.dart';
import '../l10n/tr.dart';

/// Cores de destaque disponíveis (o dourado é o do ícone).
const Map<String, Color> accentColors = <String, Color>{
  'gold': Color(0xFFD9AC4F),
  'blue': Color(0xFF5B9BE6),
  'green': Color(0xFF5FBF8F),
  'red': Color(0xFFE0675B),
  'purple': Color(0xFFA98BE6),
};

/// Nome da cor de destaque no idioma do app.
String accentName(String id) => switch (id) {
  'gold' => tr.accentGold,
  'blue' => tr.accentBlue,
  'green' => tr.accentGreen,
  'red' => tr.accentRed,
  _ => tr.accentPurple,
};

/// A aparência escolhida; o app se redesenha quando ela muda.
final ValueNotifier<AppSettings> appearance = ValueNotifier<AppSettings>(
  const AppSettings(),
);

ThemeMode themeModeOf(AppSettings s) => switch (s.theme) {
  'light' => ThemeMode.light,
  'system' => ThemeMode.system,
  _ => ThemeMode.dark,
};

/// O tema escuro em uso: preto ou azul-marinho.
ThemeData darkThemeOf(AppSettings s) {
  final bool black =
      s.theme == 'black' || (s.theme == 'system' && s.darkStyle == 'black');
  return black
      ? bukaneroBlackTheme(accentOf(s))
      : bukaneroDarkTheme(accentOf(s));
}

Color accentOf(AppSettings s) =>
    accentColors[s.accent] ?? accentColors['gold']!;

Color _shade(Color c, double lightness) =>
    HSLColor.fromColor(c).withLightness(lightness).toColor();

/// Tema escuro: fundo azul-marinho liso, cartões sem borda e a cor de
/// destaque só no que importa (selecionado, tocando, favorito).
ThemeData bukaneroDarkTheme([Color accent = const Color(0xFFD9AC4F)]) {
  const Color navy0 = Color(0xFF0B1328);
  const Color navy1 = Color(0xFF0F1A33);
  const Color navy2 = Color(0xFF14213F);
  const Color navy3 = Color(0xFF19284B);
  const Color navy4 = Color(0xFF1F3158);
  const Color text = Color(0xFFE9E6DD);
  final ColorScheme cs = ColorScheme(
    brightness: Brightness.dark,
    primary: accent,
    onPrimary: _shade(accent, 0.1),
    primaryContainer: Color.alphaBlend(accent.withValues(alpha: 0.22), navy1),
    onPrimaryContainer: _shade(accent, 0.82),
    secondary: const Color(0xFF9DB4E6),
    onSecondary: navy0,
    secondaryContainer: navy4,
    onSecondaryContainer: text,
    error: const Color(0xFFFF8A80),
    onError: const Color(0xFF3B0A08),
    surface: navy1,
    onSurface: text,
    onSurfaceVariant: const Color(0xFFA9B0C2),
    surfaceContainerLowest: navy0,
    surfaceContainerLow: navy1,
    surfaceContainer: navy2,
    surfaceContainerHigh: navy3,
    surfaceContainerHighest: navy4,
    outline: const Color(0xFF3B4C74),
    outlineVariant: const Color(0xFF243559),
  );
  return _base(cs, appBar: navy0, divider: const Color(0xFF1C2A4D));
}

/// Tema preto: fundo preto puro (bom à noite e em telas escuras), cartões
/// em cinza bem escuro e a mesma cor de destaque.
ThemeData bukaneroBlackTheme([Color accent = const Color(0xFFD9AC4F)]) {
  const Color text = Color(0xFFECECEC);
  final ColorScheme cs = ColorScheme(
    brightness: Brightness.dark,
    primary: accent,
    onPrimary: _shade(accent, 0.1),
    primaryContainer: Color.alphaBlend(
      accent.withValues(alpha: 0.2),
      Colors.black,
    ),
    onPrimaryContainer: _shade(accent, 0.82),
    secondary: const Color(0xFFBDBDBD),
    onSecondary: Colors.black,
    secondaryContainer: const Color(0xFF2A2A2A),
    onSecondaryContainer: text,
    error: const Color(0xFFFF8A80),
    onError: const Color(0xFF3B0A08),
    surface: Colors.black,
    onSurface: text,
    onSurfaceVariant: const Color(0xFFA8A8A8),
    surfaceContainerLowest: Colors.black,
    surfaceContainerLow: const Color(0xFF0A0A0A),
    surfaceContainer: const Color(0xFF141414),
    surfaceContainerHigh: const Color(0xFF1C1C1C),
    surfaceContainerHighest: const Color(0xFF262626),
    outline: const Color(0xFF4A4A4A),
    outlineVariant: const Color(0xFF2C2C2C),
  );
  return _base(cs, appBar: Colors.black, divider: const Color(0xFF1E1E1E));
}

/// Tema claro: fundo creme, texto azul-marinho e a mesma cor de destaque,
/// um pouco mais escura para ler bem sobre o claro.
ThemeData bukaneroLightTheme([Color accent = const Color(0xFFD9AC4F)]) {
  const Color navyText = Color(0xFF16234A);
  final Color strong = _shade(accent, 0.36);
  final ColorScheme cs = ColorScheme(
    brightness: Brightness.light,
    primary: strong,
    onPrimary: Colors.white,
    primaryContainer: Color.alphaBlend(
      accent.withValues(alpha: 0.25),
      const Color(0xFFFBF8F1),
    ),
    onPrimaryContainer: _shade(accent, 0.22),
    secondary: const Color(0xFF3B5A9A),
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFE3E8F3),
    onSecondaryContainer: navyText,
    error: const Color(0xFFB3261E),
    onError: Colors.white,
    surface: const Color(0xFFF6F3EC),
    onSurface: navyText,
    onSurfaceVariant: const Color(0xFF55607A),
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: const Color(0xFFFBF8F1),
    surfaceContainer: const Color(0xFFEFEADF),
    surfaceContainerHigh: const Color(0xFFE8E2D5),
    surfaceContainerHighest: const Color(0xFFE0D9CA),
    outline: const Color(0xFFB9B2A3),
    outlineVariant: const Color(0xFFD8D1C2),
  );
  return _base(
    cs,
    appBar: const Color(0xFFFBF8F1),
    divider: const Color(0xFFE2DBCC),
  );
}

ThemeData _base(
  ColorScheme cs, {
  required Color appBar,
  required Color divider,
}) {
  return ThemeData(
    colorScheme: cs,
    useMaterial3: true,
    scaffoldBackgroundColor: cs.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: appBar,
      foregroundColor: cs.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: cs.surfaceContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: DividerThemeData(color: divider, thickness: 1, space: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cs.surfaceContainer,
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
        borderSide: BorderSide(color: cs.primary),
      ),
    ),
    listTileTheme: ListTileThemeData(selectedColor: cs.primary),
    tooltipTheme: const TooltipThemeData(
      waitDuration: Duration(milliseconds: 500),
    ),
  );
}
