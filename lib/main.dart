import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

import 'data/app_settings.dart';
import 'l10n/app_localizations.dart';
import 'l10n/tr.dart';
import 'ui/app_theme.dart';
import 'ui/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  appearance.value = loadAppSettings();
  runApp(const BukaneroApp());
}

class BukaneroApp extends StatelessWidget {
  const BukaneroApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Trocar o tema, a cor ou o idioma nas Configurações redesenha o app
    // na hora.
    return ValueListenableBuilder<AppSettings>(
      valueListenable: appearance,
      builder: (BuildContext context, AppSettings s, Widget? _) {
        final Locale locale = resolveLocale(s.language);
        tr = lookupAppLocalizations(locale);
        return MaterialApp(
          title: 'Bukanero',
          debugShowCheckedModeBanner: false,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: bukaneroLightTheme(accentOf(s)),
          darkTheme: darkThemeOf(s),
          themeMode: themeModeOf(s),
          home: const HomePage(),
        );
      },
    );
  }
}
