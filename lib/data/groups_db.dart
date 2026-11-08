import 'dart:io';
import 'dart:isolate';

import 'package:sqlite3/sqlite3.dart';

import '../domain/channel.dart';
import '../domain/grouping.dart';
import '../domain/section.dart';
import '../domain/stream_id.dart';
import 'epg.dart';

// Mude ao alterar as regras do agrupamento: força recalcular.
const int _version = 3;

String _stamp(String catalogPath, String? epgPath, String? metaPath) {
  String mtime(String? p) => (p != null && File(p).existsSync())
      ? File(p).lastModifiedSync().millisecondsSinceEpoch.toString()
      : '-';
  final Database cat = sqlite3.open(catalogPath, mode: OpenMode.readOnly);
  try {
    final ResultSet rs = cat.select(
      'SELECT value FROM meta WHERE key = ?',
      <Object?>['stamp'],
    );
    final String s = rs.isEmpty ? '' : rs.first['value'] as String;
    return '$_version|$s|${mtime(epgPath)}|${mtime(metaPath)}';
  } finally {
    cat.close();
  }
}

bool _isCurrent(String groupsPath, String stamp) {
  if (!File(groupsPath).existsSync()) return false;
  Database? db;
  try {
    db = sqlite3.open(groupsPath, mode: OpenMode.readOnly);
    final ResultSet rs = db.select(
      'SELECT value FROM meta WHERE key = ?',
      <Object?>['stamp'],
    );
    return rs.isNotEmpty && rs.first['value'] == stamp;
  } on Object {
    return false;
  } finally {
    db?.close();
  }
}

/// Calcula (num isolate) os cartões agrupados de canais e filmes. Só refaz
/// quando a lista, o guia ou as notas mudaram.
Future<void> ensureGroups(
  String catalogPath,
  String groupsPath, {
  String? epgPath,
  String? metaPath,
}) => Isolate.run<void>(() {
  final String stamp = _stamp(catalogPath, epgPath, metaPath);
  if (_isCurrent(groupsPath, stamp)) return;
  _build(catalogPath, groupsPath, stamp, epgPath, metaPath);
});

void _build(
  String catalogPath,
  String groupsPath,
  String stamp,
  String? epgPath,
  String? metaPath,
) {
  final Database cat = sqlite3.open(catalogPath, mode: OpenMode.readOnly);
  final EpgDb? epg = epgPath == null ? null : EpgDb.tryOpen(epgPath);
  final Map<int, int> tmdb = <int, int>{};
  if (metaPath != null && File(metaPath).existsSync()) {
    final Database m = sqlite3.open(metaPath, mode: OpenMode.readOnly);
    try {
      if (m
          .select('PRAGMA table_info(vod)')
          .any((Row r) => r['name'] == 'tmdb')) {
        for (final Row r in m.select(
          'SELECT vod_id, tmdb FROM vod WHERE tmdb IS NOT NULL',
        )) {
          tmdb[r['vod_id'] as int] = r['tmdb'] as int;
        }
      }
    } finally {
      m.close();
    }
  }

  final File tmp = File('$groupsPath.tmp');
  if (tmp.existsSync()) tmp.deleteSync();
  final Database out = sqlite3.open(tmp.path);
  try {
    out.execute('''
      CREATE TABLE card(
        id INTEGER PRIMARY KEY,
        section INTEGER NOT NULL,
        name TEXT NOT NULL,
        key TEXT NOT NULL
      );
      CREATE TABLE member(
        item_id INTEGER PRIMARY KEY,
        card INTEGER NOT NULL,
        label TEXT NOT NULL,
        mark TEXT NOT NULL,
        rank REAL NOT NULL
      );
      CREATE TABLE meta(key TEXT PRIMARY KEY, value TEXT);
    ''');
    final PreparedStatement insCard = out.prepare(
      'INSERT INTO card(id, section, name, key) VALUES (?, ?, ?, ?)',
    );
    final PreparedStatement insMember = out.prepare(
      'INSERT INTO member(item_id, card, label, mark, rank) '
      'VALUES (?, ?, ?, ?, ?)',
    );
    int nextCard = 1;
    out.execute('BEGIN');
    for (final Section s in <Section>[Section.live, Section.movies]) {
      final bool movies = s == Section.movies;
      final List<GroupItem> items = <GroupItem>[
        for (final Row r in cat.select(
          'SELECT id, name, url, logo, tvg_id FROM items WHERE section = ?',
          <Object?>[s.index],
        ))
          _item(r, movies, epg, tmdb),
      ];
      final GroupingResult res = groupItems(items, movies: movies);
      for (final GroupCard c in buildCards(items, res)) {
        final int id = nextCard++;
        insCard.execute(<Object?>[id, s.index, c.name, c.key]);
        for (final CardMember m in c.members) {
          insMember.execute(<Object?>[m.id, id, m.label, m.mark, m.rank]);
        }
      }
    }
    out.execute('INSERT INTO meta(key, value) VALUES (?, ?)', <Object?>[
      'stamp',
      stamp,
    ]);
    out.execute('COMMIT');
    insCard.close();
    insMember.close();
  } finally {
    out.close();
    cat.close();
    epg?.close();
  }
  final File dest = File(groupsPath);
  if (dest.existsSync()) dest.deleteSync();
  tmp.renameSync(groupsPath);
}

GroupItem _item(Row r, bool movies, EpgDb? epg, Map<int, int> tmdb) {
  final String name = r['name'] as String;
  final String? tvg = r['tvg_id'] as String?;
  final int? sid = movies ? streamIdFromUrl(r['url'] as String) : null;
  return GroupItem(
    id: r['id'] as int,
    name: name,
    logo: r['logo'] as String?,
    tvgId: tvg,
    epg: movies ? null : epg?.channelFor(tvg, name),
    tmdb: sid == null ? null : tmdb[sid],
  );
}

/// Uma versão de um cartão, já lida do banco.
class GroupRef {
  const GroupRef(this.card, this.label, this.mark, this.rank);

  final int card;
  final String label;
  final String mark;
  final double rank;
}

/// Os grupos em memória, para juntar os itens na hora de mostrar.
class GroupIndex {
  GroupIndex._(this.members, this.names, this.keys) {
    for (final MapEntry<int, GroupRef> e in members.entries) {
      (_byCard[e.value.card] ??= <int>[]).add(e.key);
    }
  }

  final Map<int, List<int>> _byCard = <int, List<int>>{};

  static GroupIndex? tryOpen(String path) {
    if (!File(path).existsSync()) return null;
    try {
      final Database db = sqlite3.open(path, mode: OpenMode.readOnly);
      try {
        final Map<int, GroupRef> members = <int, GroupRef>{
          for (final Row r in db.select('SELECT * FROM member'))
            r['item_id'] as int: GroupRef(
              r['card'] as int,
              r['label'] as String,
              r['mark'] as String,
              (r['rank'] as num).toDouble(),
            ),
        };
        final Map<int, String> names = <int, String>{};
        final Map<int, String> keys = <int, String>{};
        for (final Row r in db.select('SELECT id, name, key FROM card')) {
          names[r['id'] as int] = r['name'] as String;
          keys[r['id'] as int] = r['key'] as String;
        }
        return GroupIndex._(members, names, keys);
      } finally {
        db.close();
      }
    } on Object {
      return null;
    }
  }

  final Map<int, GroupRef> members;
  final Map<int, String> names;
  final Map<int, String> keys;
  late final Map<String, int> _cardOfKey = <String, int>{
    for (final MapEntry<int, String> e in keys.entries) e.value: e.key,
  };

  /// Chave do grupo separado de onde [c] veio (para "juntar de novo"), ou
  /// null se ele não está num grupo separado.
  String? separatedKey(Channel c, Set<String> separated) {
    final GroupRef? g = c.itemId == null ? null : members[c.itemId];
    final String? k = g == null ? null : keys[g.card];
    return (k != null && separated.contains(k)) ? k : null;
  }

  /// Nome do cartão de um grupo, pela chave (para listar os separados).
  String? nameOfKey(String key) {
    final int? card = _cardOfKey[key];
    return card == null ? null : names[card];
  }

  /// Junta as versões de [items] em cartões, na posição da primeira que
  /// aparece (respeitando a ordem escolhida). Grupos em [separated] ficam
  /// soltos; um grupo com uma versão só vira o próprio item.
  ///
  /// Com [fetch], o cartão traz também as versões que estão em outras
  /// categorias (ex.: o 4K numa categoria só de 4K); [isHidden] deixa de
  /// fora as que o usuário ocultou.
  List<Channel> collapse(
    List<Channel> items, {
    Set<String> separated = const <String>{},
    Map<int, Channel> Function(Iterable<int> ids)? fetch,
    bool Function(Channel c)? isHidden,
  }) {
    final List<Object> slots = <Object>[];
    final Map<int, List<(GroupRef, Channel)>> byCard =
        <int, List<(GroupRef, Channel)>>{};
    for (final Channel c in items) {
      final GroupRef? g = c.itemId == null ? null : members[c.itemId];
      if (g == null || separated.contains(keys[g.card])) {
        slots.add(c);
        continue;
      }
      final List<(GroupRef, Channel)>? l = byCard[g.card];
      if (l == null) {
        byCard[g.card] = <(GroupRef, Channel)>[(g, c)];
        slots.add(g.card);
      } else {
        l.add((g, c));
      }
    }
    if (fetch != null && byCard.isNotEmpty) {
      final List<int> missing = <int>[];
      for (final MapEntry<int, List<(GroupRef, Channel)>> e in byCard.entries) {
        final Set<int> have = <int>{
          for (final (GroupRef, Channel) m in e.value) m.$2.itemId!,
        };
        for (final int id in _byCard[e.key] ?? const <int>[]) {
          if (!have.contains(id)) missing.add(id);
        }
      }
      if (missing.isNotEmpty) {
        final Map<int, Channel> extra = fetch(missing);
        for (final int id in missing) {
          final Channel? c = extra[id];
          final GroupRef? g = members[id];
          if (c == null || g == null) continue;
          if (isHidden?.call(c) ?? false) continue;
          byCard[g.card]!.add((g, c));
        }
      }
    }
    return <Channel>[
      for (final Object s in slots)
        s is Channel ? s : _card(s as int, byCard[s]!),
    ];
  }

  Channel _card(int card, List<(GroupRef, Channel)> ms) {
    if (ms.length == 1) return ms.first.$2;
    ms.sort(
      ((GroupRef, Channel) a, (GroupRef, Channel) b) =>
          a.$1.rank.compareTo(b.$1.rank),
    );
    final Channel best = ms.first.$2;
    String? firstOf(String? Function(Channel) f) {
      for (final (GroupRef, Channel) m in ms) {
        final String? v = f(m.$2);
        if (v != null && v.isNotEmpty) return v;
      }
      return null;
    }

    double? rating;
    for (final (GroupRef, Channel) m in ms) {
      rating ??= m.$2.rating;
    }
    return Channel(
      name: names[card] ?? best.name,
      url: best.url,
      group: best.group,
      logo: firstOf((Channel c) => c.logo),
      tvgId: firstOf((Channel c) => c.tvgId),
      rating: rating,
      itemId: best.itemId,
      versions: <ChannelVersion>[
        for (final (GroupRef, Channel) m in ms)
          ChannelVersion(m.$1.label, m.$2, mark: m.$1.mark),
      ],
      groupKey: keys[card],
    );
  }
}
