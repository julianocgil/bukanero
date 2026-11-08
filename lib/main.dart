import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

import 'data/app_settings.dart';
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
    // Trocar o tema ou a cor nas Configurações redesenha o app na hora.
    return ValueListenableBuilder<AppSettings>(
      valueListenable: appearance,
      builder: (BuildContext context, AppSettings s, Widget? _) => MaterialApp(
        title: 'Bukanero',
        debugShowCheckedModeBanner: false,
        theme: bukaneroLightTheme(accentOf(s)),
        darkTheme: darkThemeOf(s),
        themeMode: themeModeOf(s),
        home: const HomePage(),
      ),
    );
  }
}
