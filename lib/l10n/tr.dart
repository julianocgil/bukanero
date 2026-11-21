import 'dart:ui';

import 'app_localizations.dart';

/// Textos do app no idioma em uso. Vale também fora da tela (mensagens de
/// erro de download, por exemplo); num isolate à parte fica em português.
AppLocalizations tr = lookupAppLocalizations(const Locale('pt'));

/// Idiomas oferecidos, com o nome na própria língua.
const Map<String, String> languageNames = <String, String>{
  'pt': 'Português',
  'en': 'English',
  'es': 'Español',
  'fr': 'Français',
  'de': 'Deutsch',
  'it': 'Italiano',
};

/// O idioma escolhido ('system' = o do sistema; se o sistema estiver numa
/// língua que o app não tem, inglês).
Locale resolveLocale(String setting) {
  if (languageNames.containsKey(setting)) return Locale(setting);
  for (final Locale l in PlatformDispatcher.instance.locales) {
    if (languageNames.containsKey(l.languageCode)) {
      return Locale(l.languageCode);
    }
  }
  return const Locale('en');
}

/// Nome de uma versão de cartão ("Padrão" é guardado em português).
String versionName(String label) =>
    label == 'Padrão' ? tr.versionDefault : label;

/// Motivos do agrupamento (guardados em português, separados por vírgula)
/// no idioma em uso.
String reasonsLabel(String reasons) {
  final Map<String, String> names = <String, String>{
    'mesmo nome e canal do guia': tr.reasonSameNameGuide,
    'mesmo nome com número': tr.reasonSameNameNumber,
    'mesmo nome e imagem': tr.reasonSameNameImage,
    'mesmo nome e ano': tr.reasonSameNameYear,
    'família numerada': tr.reasonNumberedFamily,
    'mesmo tvg-id': tr.reasonSameTvgId,
    'mesmo TMDB': tr.reasonSameTmdb,
    'mesmo nome': tr.reasonSameName,
  };
  return <String>[for (final String r in reasons.split(', ')) names[r] ?? r]
      .join(', ');
}
