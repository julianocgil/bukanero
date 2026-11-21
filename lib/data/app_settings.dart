import 'dart:convert';
import 'dart:io';

import 'profile_store.dart';

/// Aparência do app (vale para todos os perfis): tema e cor de destaque.
/// Fica em `settings.json` na pasta de dados; não guarda nada da lista.
class AppSettings {
  const AppSettings({
    this.theme = 'dark',
    this.accent = 'gold',
    this.darkStyle = 'dark',
    this.language = 'system',
  });

  factory AppSettings.fromJson(Map<String, dynamic> j) => AppSettings(
    theme: (j['theme'] as String?) ?? 'dark',
    accent: (j['accent'] as String?) ?? 'gold',
    darkStyle: (j['darkStyle'] as String?) ?? 'dark',
    language: (j['language'] as String?) ?? 'system',
  );

  /// 'dark' (azul-marinho), 'black', 'light' ou 'system'.
  final String theme;

  /// O escuro usado quando o tema segue o sistema: 'dark' ou 'black' (o
  /// último escuro escolhido).
  final String darkStyle;

  /// Nome da cor de destaque ('gold', 'blue', 'green', 'red', 'purple').
  final String accent;

  /// Idioma do app ('pt', 'en', 'es'...) ou 'system'.
  final String language;

  AppSettings copyWith({
    String? theme,
    String? accent,
    String? darkStyle,
    String? language,
  }) => AppSettings(
    theme: theme ?? this.theme,
    accent: accent ?? this.accent,
    darkStyle: darkStyle ?? this.darkStyle,
    language: language ?? this.language,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'theme': theme,
    'accent': accent,
    'darkStyle': darkStyle,
    'language': language,
  };
}

File _file() => File('${dataDir().path}/settings.json');

AppSettings loadAppSettings() {
  try {
    final File f = _file();
    if (!f.existsSync()) return const AppSettings();
    final Object? j = jsonDecode(f.readAsStringSync());
    return j is Map<String, dynamic>
        ? AppSettings.fromJson(j)
        : const AppSettings();
  } on Object {
    return const AppSettings();
  }
}

void saveAppSettings(AppSettings s) {
  try {
    _file().writeAsStringSync(jsonEncode(s.toJson()));
  } on Object {
    // Sem gravar, a escolha vale só até fechar o app.
  }
}
