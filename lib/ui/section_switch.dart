import 'package:flutter/material.dart';

import '../domain/section.dart';

/// Troca entre Ao vivo, Filmes e Séries: uma pílula em que a seção ativa
/// mostra ícone e nome em dourado; as outras, só o ícone.
class SectionSwitch extends StatelessWidget {
  const SectionSwitch({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final Section selected;
  final ValueChanged<Section> onChanged;

  static const Map<Section, (IconData, String)> _items =
      <Section, (IconData, String)>{
        Section.live: (Icons.live_tv_rounded, 'Ao vivo'),
        Section.movies: (Icons.movie_outlined, 'Filmes'),
        Section.series: (Icons.video_library_outlined, 'Séries'),
      };

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final MapEntry<Section, (IconData, String)> e in _items.entries)
            _pill(context, e.key, e.value.$1, e.value.$2),
        ],
      ),
    );
  }

  Widget _pill(BuildContext context, Section s, IconData icon, String label) {
    final ThemeData t = Theme.of(context);
    final bool on = s == selected;
    final Color fg = on
        ? t.colorScheme.primary
        : t.colorScheme.onSurfaceVariant;
    return Tooltip(
      message: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: on ? null : () => onChanged(s),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(horizontal: on ? 14 : 10, vertical: 8),
          decoration: BoxDecoration(
            color: on ? t.colorScheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 20, color: fg),
              // O nome só na seção ativa: as outras ficam compactas.
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                child: on
                    ? Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(
                          label,
                          style: t.textTheme.labelLarge?.copyWith(
                            color: fg,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
