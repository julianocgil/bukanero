import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:sqlite3/sqlite3.dart';

import '../domain/channel.dart';
import '../domain/section.dart';
import 'epg.dart';
import 'm3u/m3u_parser.dart';

const int _schemaVersion = 2;

String _stamp(String path) {
  final FileStat s = File(path).statSync();
  return '$_schemaVersion:${s.size}:${s.modified.millisecondsSinceEpoch}';
}

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
          url TEXT NOT NULL,
          logo TEXT,
          tvg_id TEXT
        );
        CREATE TABLE meta(key TEXT PRIMARY KEY, value TEXT);
      ''');
      final PreparedStatement ins = db.prepare(
        'INSERT INTO items(section, grp, name, url, logo, tvg_id) '
        'VALUES (?, ?, ?, ?, ?, ?)',
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
          c.url,
          c.logo,
          c.tvgId,
        ]);
        if (++n % 20000 == 0) {
          db.execute('COMMIT');
          db.execute('BEGIN');
        }
      }
      db.execute('COMMIT');
      ins.close();

      db.execute('CREATE INDEX idx_items_group ON items(section, grp)');
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
    final String esc = query
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
    final ResultSet rs = _db.select(
      r'SELECT name, url, logo, tvg_id FROM items '
      r'WHERE section = ? AND grp = ? AND name LIKE ? ESCAPE ? '
      r'ORDER BY id LIMIT ?',
      <Object?>[s.index, group, '%$esc%', r'\', limit + exclude.length],
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
        ),
      );
      if (out.length >= limit) break;
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

  /// tvg-id (minúsculo) dos canais ao vivo, para conferir com o guia.
  Set<String> liveTvgIds() {
    final ResultSet rs = _db.select(
      'SELECT DISTINCT lower(tvg_id) AS t FROM items '
      'WHERE section = 0 AND tvg_id IS NOT NULL AND length(tvg_id) > 0',
    );
    return <String>{for (final Row r in rs) r['t'] as String};
  }

  void close() => _db.close();
}
