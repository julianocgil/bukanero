import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:sqlite3/sqlite3.dart';

import '../domain/channel.dart';
import '../domain/section.dart';
import '../domain/sort_mode.dart';
import '../domain/stream_id.dart';
import 'epg.dart';
import 'm3u/m3u_parser.dart';

const int _schemaVersion = 5;

String _stamp(String path) {
  final FileStat s = File(path).statSync();
  return '$_schemaVersion:${s.size}:${s.modified.millisecondsSinceEpoch}';
}

String _escapeLike(String q) =>
    q.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');

/// Ordem de itens. `i` = tabela de itens, `m` = notas/datas (se ligadas).
String _orderBy(SortMode m) => switch (m) {
  SortMode.listOrder => 'i.id',
  SortMode.listOrderReverse => 'i.id DESC',
  SortMode.nameAsc => 'i.nkey, i.id',
  SortMode.nameDesc => 'i.nkey DESC, i.id',
  SortMode.recent => 'COALESCE(m.added, 0) DESC, i.id',
  SortMode.rating => 'COALESCE(m.rating, -1) DESC, i.id',
  SortMode.year => 'COALESCE(m.year, 0) DESC, i.id',
};

/// True se o banco existe e foi gerado a partir deste mesmo arquivo M3U.
bool catalogIsFresh(String dbPath, String m3uPath) {
  if (!File(dbPath).existsSync()) return false;
  Database? db;
  try {
    db = sqlite3.open(dbPath, mode: OpenMode.readOnly);
    final ResultSet rs = db.select(
      'SELECT value FROM meta WHERE key = ?',
      <Object?>['stamp'],
    );
    return rs.isNotEmpty && rs.first['value'] == _stamp(m3uPath);
  } on Object {
    return false;
  } finally {
    db?.close();
  }
}

Future<List<String>> _readEpgUrls(String path) async {
  final Stream<String> lines = File(path)
      .openRead()
      .transform(const Utf8Decoder(allowMalformed: true))
      .transform(const LineSplitter());
  await for (final String l in lines) {
    final String t = l.replaceFirst('\uFEFF', '').trim();
    if (t.isEmpty) continue;
    return epgUrlsFromHeader(t);
  }
  return const <String>[];
}

/// Importa o M3U para um banco novo. Grava num arquivo temporário e só
/// renomeia no fim, então uma importação interrompida não corrompe nada.
Future<void> importCatalog(String m3uPath, String dbPath) {
  return Isolate.run<void>(() async {
    final File tmp = File('$dbPath.tmp');
    if (tmp.existsSync()) tmp.deleteSync();
    final List<String> epg = await _readEpgUrls(m3uPath);
    final Database db = sqlite3.open(tmp.path);
    try {
      db.execute('''
        CREATE TABLE items(
          id INTEGER PRIMARY KEY,
          section INTEGER NOT NULL,
          grp TEXT NOT NULL,
          name TEXT NOT NULL,
          nkey TEXT NOT NULL,
          url TEXT NOT NULL,
          logo TEXT,
          tvg_id TEXT,
          sid INTEGER
        );
        CREATE TABLE meta(key TEXT PRIMARY KEY, value TEXT);
      ''');
      final PreparedStatement ins = db.prepare(
        'INSERT INTO items(section, grp, name, nkey, url, logo, tvg_id, sid) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      );
      final Stream<String> lines = File(m3uPath)
          .openRead()
          .transform(const Utf8Decoder(allowMalformed: true))
          .transform(const LineSplitter());

      db.execute('BEGIN');
      int n = 0;
      await for (final Channel c in parseM3u(lines)) {
        ins.execute(<Object?>[
          classify(c).index,
          c.group ?? '(sem grupo)',
          c.name,
          normalize(c.name),
          c.url,
          c.logo,
          c.tvgId,
          streamIdFromUrl(c.url),
        ]);
        if (++n % 20000 == 0) {
          db.execute('COMMIT');
          db.execute('BEGIN');
        }
      }
      db.execute('COMMIT');
      ins.close();

      db.execute('CREATE INDEX idx_items_group ON items(section, grp)');
      db.execute('CREATE INDEX idx_items_nkey ON items(section, grp, nkey)');
      db.execute('INSERT INTO meta(key, value) VALUES (?, ?)', <Object?>[
        'stamp',
        _stamp(m3uPath),
      ]);
      db.execute('INSERT INTO meta(key, value) VALUES (?, ?)', <Object?>[
        'epg',
        epg.join('\n'),
      ]);
    } finally {
      db.close();
    }
    final File dest = File(dbPath);
    if (dest.existsSync()) dest.deleteSync();
    tmp.renameSync(dbPath);
  });
}

/// Consultas de leitura sobre o catálogo importado.
class CatalogDb {
  CatalogDb._(this._db);

  factory CatalogDb.open(String path) =>
      CatalogDb._(sqlite3.open(path, mode: OpenMode.readOnly));

  final Database _db;
  bool _metaOn = false;

  /// Ordem usada por [items] e [search].
  SortMode sort = SortMode.listOrder;

  /// True se o banco de notas e datas está ligado.
  bool get hasMeta => _metaOn;

  /// Liga o banco de notas e datas (nome interno `mx`). Refaça após uma
  /// nova importação, porque o arquivo antigo foi substituído.
  bool attachMeta(String path) {
    detachMeta();
    if (!File(path).existsSync()) return false;
    try {
      _db.execute('ATTACH DATABASE ? AS mx', <Object?>[path]);
      _metaOn = true;
    } on Object {
      _metaOn = false;
    }
    return _metaOn;
  }

  void detachMeta() {
    if (!_metaOn) return;
    try {
      _db.execute('DETACH DATABASE mx');
    } on Object {
      // Nada a fazer: segue sem as notas.
    }
    _metaOn = false;
  }

  // Sem notas disponíveis, volta para a ordem da lista.
  SortMode get _eff => (sort.needsMeta && !_metaOn) ? SortMode.listOrder : sort;

  String get _join => _metaOn ? 'LEFT JOIN mx.vod m ON m.vod_id = i.sid' : '';

  // Só filmes têm nota: o id de um canal ao vivo pode coincidir com o de um
  // filme.
  String get _rating => _metaOn
      ? 'CASE WHEN i.section = ${Section.movies.index} THEN m.rating END'
      : 'NULL';

  /// (filmes no total, filmes com nota), para conferir se a ligação funcionou.
  (int, int) metaCoverage() {
    if (!_metaOn) return (0, 0);
    final ResultSet rs = _db.select(
      'SELECT COUNT(*) AS total, COUNT(m.rating) AS rated '
      'FROM items i LEFT JOIN mx.vod m ON m.vod_id = i.sid '
      'WHERE i.section = ?',
      <Object?>[Section.movies.index],
    );
    return (rs.first['total'] as int, rs.first['rated'] as int);
  }

  /// Uma URL qualquer da lista (para descobrir servidor e credenciais).
  String? sampleItemUrl() {
    final ResultSet rs = _db.select('SELECT url FROM items LIMIT 1');
    return rs.isEmpty ? null : rs.first['url'] as String;
  }

  Map<String, int> groupCounts(Section s) {
    final ResultSet rs = _db.select(
      'SELECT grp, COUNT(*) AS n FROM items WHERE section = ? GROUP BY grp',
      <Object?>[s.index],
    );
    return <String, int>{
      for (final Row r in rs) r['grp'] as String: r['n'] as int,
    };
  }

  /// Itens de uma categoria, com filtro opcional por nome (máx. [limit]).
  /// Nomes em [exclude] (ocultos pelo usuário) ficam de fora.
  List<Channel> items(
    Section s,
    String group,
    String query, {
    Set<String> exclude = const <String>{},
    int limit = 2000,
  }) {
    final ResultSet rs = _db.select(
      'SELECT i.name AS name, i.url AS url, i.logo AS logo, '
      'i.tvg_id AS tvg_id, $_rating AS rating FROM items i $_join '
      'WHERE i.section = ? AND i.grp = ? AND i.name LIKE ? ESCAPE ? '
      'ORDER BY ${_orderBy(_eff)} LIMIT ?',
      <Object?>[
        s.index,
        group,
        '%${_escapeLike(query)}%',
        r'\',
        limit + exclude.length,
      ],
    );
    final List<Channel> out = <Channel>[];
    for (final Row r in rs) {
      final String name = r['name'] as String;
      if (exclude.contains(name)) continue;
      out.add(
        Channel(
          name: name,
          url: r['url'] as String,
          group: group,
          logo: r['logo'] as String?,
          tvgId: r['tvg_id'] as String?,
          rating: (r['rating'] as num?)?.toDouble(),
        ),
      );
      if (out.length >= limit) break;
    }
    return out;
  }

  /// Busca pelo nome em todas as categorias de uma seção (máx. [limit]).
  /// [isHidden] recebe (categoria, nome) e decide se o item fica de fora.
  List<Channel> search(
    Section s,
    String query, {
    bool Function(String group, String name)? isHidden,
    int limit = 500,
  }) {
    const int batch = 2000;
    final String like = '%${_escapeLike(query)}%';
    final List<Channel> out = <Channel>[];
    int offset = 0;
    while (out.length < limit) {
      final ResultSet rs = _db.select(
        'SELECT i.grp AS grp, i.name AS name, i.url AS url, i.logo AS logo, '
        'i.tvg_id AS tvg_id, $_rating AS rating FROM items i $_join '
        'WHERE i.section = ? AND i.name LIKE ? ESCAPE ? '
        'ORDER BY ${_orderBy(_eff)} LIMIT ? OFFSET ?',
        <Object?>[s.index, like, r'\', batch, offset],
      );
      for (final Row r in rs) {
        final String group = r['grp'] as String;
        final String name = r['name'] as String;
        if (isHidden != null && isHidden(group, name)) continue;
        out.add(
          Channel(
            name: name,
            url: r['url'] as String,
            group: group,
            logo: r['logo'] as String?,
            tvgId: r['tvg_id'] as String?,
            rating: (r['rating'] as num?)?.toDouble(),
          ),
        );
        if (out.length >= limit) break;
      }
      if (rs.length < batch) break;
      offset += batch;
    }
    return out;
  }

  /// URLs de guia (EPG) declaradas no cabeçalho do M3U.
  List<String> epgUrls() {
    final ResultSet rs = _db.select(
      'SELECT value FROM meta WHERE key = ?',
      <Object?>['epg'],
    );
    if (rs.isEmpty) return const <String>[];
    final String v = (rs.first['value'] as String?) ?? '';
    return v.isEmpty ? const <String>[] : v.split('\n');
  }

  /// (tvg-id, nome) dos canais ao vivo, para conferir com o guia.
  List<(String?, String)> liveChannels() {
    final ResultSet rs = _db.select(
      'SELECT tvg_id, name FROM items WHERE section = 0 ORDER BY id',
    );
    return <(String?, String)>[
      for (final Row r in rs) (r['tvg_id'] as String?, r['name'] as String),
    ];
  }

  void close() => _db.close();
}
