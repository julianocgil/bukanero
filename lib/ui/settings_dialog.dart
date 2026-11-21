import 'package:flutter/material.dart';

import '../data/app_settings.dart';
import 'app_theme.dart';
import '../l10n/tr.dart';

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

Map<int, String> get _refreshOptions => <int, String>{
  6: tr.refresh6h,
  12: tr.refresh12h,
  24: tr.refresh24h,
  48: tr.refresh2d,
  168: tr.refreshWeekly,
  0: tr.refreshNever,
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
          title: Text(tr.settings),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  section(tr.appearance),
                  SegmentedButton<String>(
                    segments: <ButtonSegment<String>>[
                      ButtonSegment<String>(
                        value: 'dark',
                        icon: Icon(Icons.dark_mode_outlined),
                        label: Text(tr.themeNavy),
                      ),
                      ButtonSegment<String>(
                        value: 'black',
                        icon: Icon(Icons.contrast),
                        label: Text(tr.themeBlack),
                      ),
                      ButtonSegment<String>(
                        value: 'light',
                        icon: Icon(Icons.light_mode_outlined),
                        label: Text(tr.themeLight),
                      ),
                      ButtonSegment<String>(
                        value: 'system',
                        icon: Icon(Icons.brightness_auto_outlined),
                        label: Text(tr.themeSystem),
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
                      for (final MapEntry<String, Color> e
                          in accentColors.entries)
                        Tooltip(
                          message: accentName(e.key),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => setLook(s.copyWith(accent: e.key)),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: e.value,
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
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: s.language,
                    decoration: InputDecoration(labelText: tr.language),
                    items: <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(
                        value: 'system',
                        child: Text(tr.languageSystem),
                      ),
                      for (final MapEntry<String, String> e
                          in languageNames.entries)
                        DropdownMenuItem<String>(
                          value: e.key,
                          child: Text(e.value),
                        ),
                    ],
                    onChanged: (String? v) {
                      if (v != null) setLook(s.copyWith(language: v));
                    },
                  ),
                  section(tr.listSection),
                  DropdownButtonFormField<int>(
                    initialValue: _refreshOptions.containsKey(hours)
                        ? hours
                        : 24,
                    decoration: InputDecoration(labelText: tr.autoRefreshList),
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
                        label: Text(tr.refreshListNow),
                        onPressed: closeThen(a.onRefreshList),
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.event_note),
                        label: Text(tr.refreshGuideNow),
                        onPressed: closeThen(a.onRefreshGuide),
                      ),
                    ],
                  ),
                  section(tr.repeatedVersions),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(tr.groupRepeatedVersions),
                    subtitle: Text(tr.groupingSubtitle),
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
                        label: Text(tr.reviewGroups),
                        onPressed: closeThen(a.onReview),
                      ),
                      if (a.separatedCount() > 0)
                        OutlinedButton.icon(
                          icon: const Icon(Icons.call_split),
                          label: Text(tr.separatedGroups(a.separatedCount())),
                          onPressed: closeThen(a.onSeparated),
                        ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.restart_alt),
                        label: Text(tr.forgetPreferred),
                        onPressed: () {
                          a.onResetVersions();
                          refresh(() {});
                        },
                      ),
                    ],
                  ),
                  section(tr.display),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(tr.showHidden),
                    value: a.showHidden(),
                    onChanged: (_) {
                      a.onShowHidden();
                      refresh(() {});
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(tr.perfMonitor),
                    subtitle: Text(tr.perfMonitorSubtitle),
                    value: a.perfOn(),
                    onChanged: (_) {
                      a.onPerf();
                      refresh(() {});
                    },
                  ),
                  section(tr.profileSection),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.manage_accounts_outlined),
                    label: Text(tr.editCurrentProfile),
                    onPressed: closeThen(a.onEditProfile),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr.close),
            ),
          ],
        );
      },
    ),
  );
}
