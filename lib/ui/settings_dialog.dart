import 'package:flutter/material.dart';

import '../data/app_settings.dart';
import 'app_theme.dart';

/// O que a tela de Configurações lê e faz na tela principal.
class SettingsActions {
  const SettingsActions({
    required this.grouping,
    required this.onGrouping,
    required this.showHidden,
    required this.onShowHidden,
    required this.perfOn,
    required this.onPerf,
    required this.refreshHours,
    required this.onRefreshHours,
    required this.onRefreshList,
    required this.onRefreshGuide,
    required this.onReview,
    required this.separatedCount,
    required this.onSeparated,
    required this.onResetVersions,
    required this.onEditProfile,
  });

  final bool Function() grouping;
  final VoidCallback onGrouping;
  final bool Function() showHidden;
  final VoidCallback onShowHidden;
  final bool Function() perfOn;
  final VoidCallback onPerf;
  final int Function() refreshHours;
  final ValueChanged<int> onRefreshHours;
  final VoidCallback onRefreshList;
  final VoidCallback onRefreshGuide;
  final VoidCallback onReview;
  final int Function() separatedCount;
  final VoidCallback onSeparated;
  final VoidCallback onResetVersions;
  final VoidCallback onEditProfile;
}

const Map<int, String> _refreshOptions = <int, String>{
  6: 'A cada 6 horas',
  12: 'A cada 12 horas',
  24: 'A cada 24 horas',
  48: 'A cada 2 dias',
  168: 'Uma vez por semana',
  0: 'Nunca (só quando eu pedir)',
};

Future<void> showSettings(BuildContext context, SettingsActions a) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext ctx) => StatefulBuilder(
      builder: (BuildContext ctx, StateSetter refresh) {
        final ThemeData t = Theme.of(ctx);
        final AppSettings s = appearance.value;
        void setLook(AppSettings n) {
          appearance.value = n;
          saveAppSettings(n);
          refresh(() {});
        }

        // Ação que fecha a tela (abre outra janela ou começa algo).
        VoidCallback closeThen(VoidCallback f) => () {
          Navigator.pop(ctx);
          f();
        };

        Widget section(String title) => Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
          child: Text(
            title,
            style: t.textTheme.titleSmall?.copyWith(
              color: t.colorScheme.primary,
            ),
          ),
        );

        final int hours = a.refreshHours();
        return AlertDialog(
          title: const Text('Configurações'),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  section('Aparência'),
                  SegmentedButton<String>(
                    segments: const <ButtonSegment<String>>[
                      ButtonSegment<String>(
                        value: 'dark',
                        icon: Icon(Icons.dark_mode_outlined),
                        label: Text('Azul'),
                      ),
                      ButtonSegment<String>(
                        value: 'black',
                        icon: Icon(Icons.contrast),
                        label: Text('Preto'),
                      ),
                      ButtonSegment<String>(
                        value: 'light',
                        icon: Icon(Icons.light_mode_outlined),
                        label: Text('Claro'),
                      ),
                      ButtonSegment<String>(
                        value: 'system',
                        icon: Icon(Icons.brightness_auto_outlined),
                        label: Text('Do sistema'),
                      ),
                    ],
                    selected: <String>{s.theme},
                    // Azul ou Preto também viram o escuro do modo "do sistema".
                    onSelectionChanged: (Set<String> v) => setLook(
                      s.copyWith(
                        theme: v.first,
                        darkStyle: (v.first == 'dark' || v.first == 'black')
                            ? v.first
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: <Widget>[
                      for (final MapEntry<String, (String, Color)> e
                          in accentColors.entries)
                        Tooltip(
                          message: e.value.$1,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => setLook(s.copyWith(accent: e.key)),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: e.value.$2,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: s.accent == e.key
                                      ? t.colorScheme.onSurface
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: s.accent == e.key
                                  ? const Icon(Icons.check, size: 18)
                                  : null,
                            ),
                          ),
                        ),
                    ],
                  ),
                  section('Lista'),
                  DropdownButtonFormField<int>(
                    initialValue: _refreshOptions.containsKey(hours)
                        ? hours
                        : 24,
                    decoration: const InputDecoration(
                      labelText: 'Atualizar a lista sozinho',
                    ),
                    items: <DropdownMenuItem<int>>[
                      for (final MapEntry<int, String> e
                          in _refreshOptions.entries)
                        DropdownMenuItem<int>(
                          value: e.key,
                          child: Text(e.value),
                        ),
                    ],
                    onChanged: (int? v) {
                      if (v != null) a.onRefreshHours(v);
                    },
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      OutlinedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Atualizar a lista agora'),
                        onPressed: closeThen(a.onRefreshList),
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.event_note),
                        label: const Text('Atualizar o guia agora'),
                        onPressed: closeThen(a.onRefreshGuide),
                      ),
                    ],
                  ),
                  section('Versões repetidas'),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Agrupar versões repetidas'),
                    subtitle: const Text(
                      'HD, FHD, 4K, dublado, legendado... num cartão só',
                    ),
                    value: a.grouping(),
                    onChanged: (_) {
                      a.onGrouping();
                      refresh(() {});
                    },
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      OutlinedButton.icon(
                        icon: const Icon(Icons.fact_check_outlined),
                        label: const Text('Revisar agrupamentos'),
                        onPressed: closeThen(a.onReview),
                      ),
                      if (a.separatedCount() > 0)
                        OutlinedButton.icon(
                          icon: const Icon(Icons.call_split),
                          label: Text(
                            'Grupos separados (${a.separatedCount()})',
                          ),
                          onPressed: closeThen(a.onSeparated),
                        ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.restart_alt),
                        label: const Text('Esquecer versões preferidas'),
                        onPressed: () {
                          a.onResetVersions();
                          refresh(() {});
                        },
                      ),
                    ],
                  ),
                  section('Exibição'),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Mostrar itens ocultos'),
                    value: a.showHidden(),
                    onChanged: (_) {
                      a.onShowHidden();
                      refresh(() {});
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Monitor de desempenho (FPS)'),
                    subtitle: const Text(
                      'Painel sobre o vídeo e histórico em desempenho.csv',
                    ),
                    value: a.perfOn(),
                    onChanged: (_) {
                      a.onPerf();
                      refresh(() {});
                    },
                  ),
                  section('Perfil'),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.manage_accounts_outlined),
                    label: const Text('Editar perfil atual'),
                    onPressed: closeThen(a.onEditProfile),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    ),
  );
}
