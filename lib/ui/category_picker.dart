import 'package:flutter/material.dart';

import '../domain/section.dart';
import 'item_views.dart';

/// Escolha feita no painel: [group] nulo = todas as categorias.
class CategoryChoice {
  const CategoryChoice(this.group);

  final String? group;
}

/// Botão que mostra a categoria atual e abre o painel de categorias.
class CategoryButton extends StatelessWidget {
  const CategoryButton({
    required this.label,
    required this.count,
    required this.onPressed,
    super.key,
  });

  final String label;
  final int? count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return Material(
      color: t.colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.category_outlined,
                size: 20,
                color: t.colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.textTheme.titleSmall?.copyWith(
                    color: t.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              if (count != null)
                Text(
                  '$count',
                  style: t.textTheme.labelMedium?.copyWith(
                    color: t.colorScheme.onSecondaryContainer,
                  ),
                ),
              const SizedBox(width: 4),
              Icon(
                Icons.expand_more,
                color: t.colorScheme.onSecondaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Painel grande com todas as categorias da seção, com busca.
/// Devolve a escolha, ou null se fechado sem escolher.
Future<CategoryChoice?> showCategoryPicker(
  BuildContext context, {
  required String title,
  required List<String> groups,
  required Map<String, int> counts,
  required String? selected,
  required bool Function(String group) isHidden,
  required void Function(String group) onToggleHidden,
}) {
  return showGeneralDialog<CategoryChoice>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Fechar',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (BuildContext ctx, Animation<double> a, Animation<double> b) =>
        _CategoryPanel(
          title: title,
          groups: groups,
          counts: counts,
          selected: selected,
          isHidden: isHidden,
          onToggleHidden: onToggleHidden,
        ),
    transitionBuilder:
        (
          BuildContext ctx,
          Animation<double> a,
          Animation<double> b,
          Widget child,
        ) => FadeTransition(
          opacity: a,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.96,
              end: 1,
            ).animate(CurvedAnimation(parent: a, curve: Curves.easeOut)),
            child: child,
          ),
        ),
  );
}

class _CategoryPanel extends StatefulWidget {
  const _CategoryPanel({
    required this.title,
    required this.groups,
    required this.counts,
    required this.selected,
    required this.isHidden,
    required this.onToggleHidden,
  });

  final String title;
  final List<String> groups;
  final Map<String, int> counts;
  final String? selected;
  final bool Function(String group) isHidden;
  final void Function(String group) onToggleHidden;

  @override
  State<_CategoryPanel> createState() => _CategoryPanelState();
}

class _CategoryPanelState extends State<_CategoryPanel> {
  String _query = '';

  List<String> get _visible {
    final String q = normalize(_query.trim());
    if (q.isEmpty) return widget.groups;
    return <String>[
      for (final String g in widget.groups)
        if (normalize(g).contains(q)) g,
    ];
  }

  void _pick(String? g) => Navigator.pop(context, CategoryChoice(g));

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final List<String> list = _visible;
    final int total = widget.counts.values.fold<int>(
      0,
      (int a, int b) => a + b,
    );
    final Size screen = MediaQuery.sizeOf(context);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 1100,
          maxHeight: screen.height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Material(
            color: t.colorScheme.surface,
            elevation: 12,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          widget.title,
                          style: t.textTheme.headlineSmall,
                        ),
                      ),
                      Text(
                        '${widget.groups.length} categorias',
                        style: t.textTheme.bodySmall,
                      ),
                      IconButton(
                        tooltip: 'Fechar',
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Procurar categoria',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (String v) => setState(() => _query = v),
                    // Enter escolhe a primeira categoria encontrada.
                    onSubmitted: (_) {
                      if (list.isNotEmpty) _pick(list.first);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 320,
                          mainAxisExtent: 60,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                    itemCount: list.length + (_query.isEmpty ? 1 : 0),
                    itemBuilder: (BuildContext context, int i) {
                      if (_query.isEmpty && i == 0) {
                        return _tile(
                          t,
                          label: 'Todas as categorias',
                          count: total,
                          selected: widget.selected == null,
                          icon: Icons.apps,
                          onTap: () => _pick(null),
                        );
                      }
                      final String g = list[i - (_query.isEmpty ? 1 : 0)];
                      final bool hidden = widget.isHidden(g);
                      return _tile(
                        t,
                        label: g,
                        count: widget.counts[g],
                        selected: g == widget.selected,
                        hidden: hidden,
                        onTap: () => _pick(g),
                        trailing: HideMenu(
                          hidden: hidden,
                          onToggle: () =>
                              setState(() => widget.onToggleHidden(g)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tile(
    ThemeData t, {
    required String label,
    required int? count,
    required bool selected,
    required VoidCallback onTap,
    bool hidden = false,
    IconData? icon,
    Widget? trailing,
  }) {
    final Color bg = selected
        ? t.colorScheme.primaryContainer
        : t.colorScheme.surfaceContainerHigh;
    final Color fg = selected
        ? t.colorScheme.onPrimaryContainer
        : t.colorScheme.onSurface;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Opacity(
          opacity: hidden ? 0.5 : 1,
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(icon, size: 18, color: fg),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: t.textTheme.bodyMedium?.copyWith(
                      color: fg,
                      fontWeight: selected ? FontWeight.w600 : null,
                      decoration: hidden ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                if (count != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      '$count',
                      style: t.textTheme.labelMedium?.copyWith(color: fg),
                    ),
                  ),
                trailing ?? const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
