import 'dart:isolate';

import '../domain/channel.dart';
import '../domain/section.dart';
import '../domain/sort_mode.dart';
import 'catalog_db.dart';
import 'groups_db.dart';
import 'series_db.dart';
import 'user_data.dart';

/// Tudo o que entra na lista da tela, em dados simples que podem ir para
/// outro isolate (lá os bancos são abertos de novo, só para leitura).
class ListRequest {
  const ListRequest({
    required this.catalogPath,
    required this.section,
    required this.group,
    required this.query,
    required this.sort,
    required this.showHidden,
    required this.hiddenGroups,
    required this.hiddenItems,
    required this.allHidden,
    this.seriesPath,
    this.metaPath,
    this.groupsPath,
    this.separated = const <String>{},
    this.favorites,
  });

  final String catalogPath;
  final String? seriesPath;
  final String? metaPath;

  /// Banco dos cartões agrupados; nulo quando o agrupamento está desligado.
  final String? groupsPath;
  final Section section;

  /// Categoria escolhida; nula para todas.
  final String? group;
  final String query;
  final SortMode sort;
  final bool showHidden;
  final Set<String> hiddenGroups;

  /// Ocultos da categoria (nomes) ou, em todas as categorias, as chaves de
  /// [hiddenKey].
  final Set<String> hiddenItems;

  /// Chaves de todos os ocultos da seção (para as versões de outras
  /// categorias que entram num cartão).
  final Set<String> allHidden;
  final Set<String> separated;

  /// Categoria Favoritos: (endereço, nome) do que foi marcado.
  final List<(String, String)>? favorites;
}

/// Monta a lista da tela (já agrupada). Roda bem num isolate: abre e fecha
/// os próprios bancos.
List<Channel> buildList(ListRequest r) {
  final CatalogDb db = CatalogDb.open(r.catalogPath)..sort = r.sort;
  SeriesDb? sdb;
  try {
    final String? meta = r.metaPath;
    if (meta != null) db.attachMeta(meta);
    final String? seriesPath = r.seriesPath;
    if (r.section == Section.series && seriesPath != null) {
      sdb = SeriesDb.open(seriesPath)..sort = r.sort;
      if (meta != null) sdb.attachMeta(meta);
    }
    List<Channel> items = _plainList(r, db, sdb);

    // Versões do mesmo canal/filme viram um cartão só.
    final String? groupsPath = r.groupsPath;
    final GroupIndex? gi = (groupsPath == null || r.section == Section.series)
        ? null
        : GroupIndex.tryOpen(groupsPath);
    if (gi != null) {
      items = gi.collapse(
        items,
        separated: r.separated,
        fetch: db.itemsByIds,
        // Versões de outras categorias: fora as ocultas (item ou categoria).
        isHidden: r.showHidden
            ? null
            : (Channel c) =>
                  r.hiddenGroups.contains(c.group) ||
                  r.allHidden.contains(hiddenKey(c.group ?? '', c.name)),
      );
    }
    return items;
  } finally {
    db.close();
    sdb?.close();
  }
}

List<Channel> _plainList(ListRequest r, CatalogDb db, SeriesDb? sdb) {
  bool isHidden(String g, String n) =>
      r.hiddenGroups.contains(g) || r.hiddenItems.contains(hiddenKey(g, n));
  final Set<String> exclude = r.showHidden ? const <String>{} : r.hiddenItems;

  // Categoria Favoritos: busca no catálogo atual o que foi marcado.
  final List<(String, String)>? favs = r.favorites;
  if (favs != null) {
    final List<Channel> items = r.section == Section.series
        ? (sdb?.byTitles(<String>[for (final (_, String n) in favs) n]) ??
              const <Channel>[])
        : db.itemsByUrls(r.section, <String>[
            for (final (String u, _) in favs) u,
          ]);
    final String q = normalize(r.query.trim());
    return q.isEmpty
        ? items
        : items.where((Channel c) => normalize(c.name).contains(q)).toList();
  }

  final String? group = r.group;
  if (sdb != null) {
    return group != null
        ? sdb.list(group, r.query, exclude: exclude)
        : sdb.search(r.query, isHidden: r.showHidden ? null : isHidden);
  }
  return group != null
      ? db.items(r.section, group, r.query, exclude: exclude)
      : db.search(r.section, r.query, isHidden: r.showHidden ? null : isHidden);
}

/// [buildList] num isolate à parte, para a tela não travar enquanto isso.
Future<List<Channel>> buildListInBackground(ListRequest r) =>
    Isolate.run(() => buildList(r));
