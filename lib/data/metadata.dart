import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:sqlite3/sqlite3.dart';

import '../domain/section.dart';
import 'download.dart';

/// Servidor e credenciais da API (`player_api.php`) da lista.
class ApiAccess {
  const ApiAccess(this.base, this.user, this.pass);

  final String base;
  final String user;
  final String pass;
}

String _origin(Uri u) =>
    '${u.scheme}://${u.host}${u.hasPort ? ':${u.port}' : ''}';

/// Descobre servidor, usuário e senha a partir da URL do perfil (`get.php`)
/// ou, se ela não servir, de uma URL de item da própria lista
/// (`http://servidor/usuario/senha/id.ts`).
ApiAccess? deriveApiAccess(String profileUrl, String? sampleItemUrl) {
  final Uri? p = Uri.tryParse(profileUrl.trim());
  if (p != null && p.hasScheme && p.host.isNotEmpty) {
    final String? u = p.queryParameters['username'];
    final String? pw = p.queryParameters['password'];
    if (u != null && u.isNotEmpty && pw != null && pw.isNotEmpty) {
      return ApiAccess(_origin(p), u, pw);
    }
  }
  if (sampleItemUrl == null) return null;
  final Uri? s = Uri.tryParse(sampleItemUrl.trim());
  if (s == null || !s.hasScheme || s.host.isEmpty) return null;
  List<String> segs = s.pathSegments.where((String x) => x.isNotEmpty).toList();
  if (segs.isNotEmpty &&
      (segs.first == 'live' ||
          segs.first == 'movie' ||
          segs.first == 'series')) {
    segs = segs.sublist(1);
  }
  if (segs.length < 3) return null;
  return ApiAccess(_origin(s), segs[0], segs[1]);
}

/// Guia XMLTV do próprio servidor da lista (`xmltv.php`).
String xmltvUrl(ApiAccess a) => Uri.parse(a.base)
    .replace(
      path: '/xmltv.php',
      queryParameters: <String, String>{'username': a.user, 'password': a.pass},
    )
    .toString();

Uri _apiUri(ApiAccess a, String action) => Uri.parse(a.base).replace(
  path: '/player_api.php',
  queryParameters: <String, String>{
    'username': a.user,
    'password': a.pass,
    'action': action,
  },
);

double? _num(Object? v) {
  if (v == null) return null;
  final double? d = double.tryParse(v.toString().trim());
  return (d == null || d <= 0) ? null : d;
}

int? _int(Object? v) {
  if (v == null) return null;
  final int? i = int.tryParse(v.toString().trim());
  return (i == null || i <= 0) ? null : i;
}

final RegExp _yearRe = RegExp(r'(19|20)\d{2}');

int? _year(Object? v) {
  if (v == null) return null;
  final RegExpMatch? m = _yearRe.firstMatch(v.toString());
  return m == null ? null : int.parse(m.group(0)!);
}

num? _max(num? a, num? b) {
  if (a == null) return b;
  if (b == null) return a;
  return a > b ? a : b;
}

/// Endereço http(s) de imagem vindo da API, ou null.
String? _image(Object? v) {
  if (v == null) return null;
  final String t = v.toString().trim();
  return (t.startsWith('http://') || t.startsWith('https://')) ? t : null;
}

/// Bancos gravados antes do pôster das séries não têm a coluna `cover`.
bool _hasSeriesCover(String dbPath) {
  Database? db;
  try {
    db = sqlite3.open(dbPath, mode: OpenMode.readOnly);
    return db
        .select('PRAGMA table_info(series)')
        .any((Row r) => r['name'] == 'cover');
  } on Object {
    return false;
  } finally {
    db?.close();
  }
}

bool metaIsFresh(String dbPath, {Duration maxAge = const Duration(hours: 24)}) {
  final File f = File(dbPath);
  return f.existsSync() &&
      DateTime.now().difference(f.lastModifiedSync()) < maxAge &&
      _hasSeriesCover(dbPath);
}

/// Grava nota, data e ano num banco novo, e o pôster das séries. As séries
/// são ligadas pelo nome (sem acentos e pontuação); se houver nomes
/// repetidos, vale o maior valor e o primeiro pôster.
void buildMetadataDb(String dbPath, List<Object?> vod, List<Object?> series) {
  final File tmp = File('$dbPath.tmp');
  if (tmp.existsSync()) tmp.deleteSync();
  final Database db = sqlite3.open(tmp.path);
  try {
    db.execute('''
      CREATE TABLE vod(
        vod_id INTEGER PRIMARY KEY,
        rating REAL,
        added INTEGER,
        year INTEGER
      );
      CREATE TABLE series(
        mkey TEXT PRIMARY KEY,
        rating REAL,
        modified INTEGER,
        year INTEGER,
        cover TEXT
      );
    ''');

    final PreparedStatement iv = db.prepare(
      'INSERT OR REPLACE INTO vod(vod_id, rating, added, year) '
      'VALUES (?, ?, ?, ?)',
    );
    db.execute('BEGIN');
    for (final Object? o in vod) {
      if (o is! Map<String, dynamic>) continue;
      final int? id = _int(o['stream_id']);
      if (id == null) continue;
      iv.execute(<Object?>[
        id,
        _num(o['rating']),
        _int(o['added']),
        _year(o['year']),
      ]);
    }
    db.execute('COMMIT');
    iv.close();

    final Map<String, List<num?>> agg = <String, List<num?>>{};
    final Map<String, String> covers = <String, String>{};
    for (final Object? o in series) {
      if (o is! Map<String, dynamic>) continue;
      final String key = matchKey((o['name'] ?? o['title'] ?? '').toString());
      if (key.isEmpty) continue;
      final List<num?> cur = agg[key] ??= <num?>[null, null, null];
      cur[0] = _max(cur[0], _num(o['rating']));
      cur[1] = _max(cur[1], _int(o['last_modified']));
      cur[2] = _max(
        cur[2],
        _year(o['year'] ?? o['releaseDate'] ?? o['release_date']),
      );
      final String? cover = _image(o['cover']);
      if (cover != null) covers.putIfAbsent(key, () => cover);
    }
    final PreparedStatement isr = db.prepare(
      'INSERT OR REPLACE INTO series(mkey, rating, modified, year, cover) '
      'VALUES (?, ?, ?, ?, ?)',
    );
    db.execute('BEGIN');
    agg.forEach((String k, List<num?> v) {
      isr.execute(<Object?>[k, v[0], v[1], v[2], covers[k]]);
    });
    db.execute('COMMIT');
    isr.close();
  } finally {
    db.close();
  }
  final File dest = File(dbPath);
  if (dest.existsSync()) dest.deleteSync();
  tmp.renameSync(dbPath);
}

/// Consulta a API do servidor e grava as notas e datas em [dbPath].
///
/// Os downloads ficam no isolate principal (para [gate] poder dar a vez ao
/// vídeo); só a leitura dos JSONs grandes vai para outro isolate.
Future<void> importMetadata(
  ApiAccess api,
  String dbPath, {
  bool allowInsecure = false,
  DownloadGate? gate,
}) async {
  String? lastError;
  final List<File> files = <File>[];
  Future<String?> grab(String action) async {
    final File f = File('$dbPath.$action.json');
    files.add(f);
    try {
      await downloadFile(
        _apiUri(api, action).toString(),
        f,
        allowInsecure: allowInsecure,
        gate: gate,
      );
      return f.path;
    } on DownloadCancelled {
      rethrow;
    } on DownloadException catch (e) {
      lastError = e.message;
      return null;
    }
  }

  try {
    final String? vodPath = await grab('get_vod_streams');
    final String? seriesPath = await grab('get_series');
    await _buildInIsolate(vodPath, seriesPath, lastError, dbPath);
  } finally {
    for (final File f in files) {
      if (f.existsSync()) f.deleteSync();
    }
  }
}

// Em função à parte: o que vai para o outro isolate leva só estes valores
// (nunca o [gate], que segura a tela inteira).
Future<void> _buildInIsolate(
  String? vodPath,
  String? seriesPath,
  String? downloadError,
  String dbPath,
) => Isolate.run<void>(
  () => _parseAndBuild(vodPath, seriesPath, downloadError, dbPath),
);

Future<void> _parseAndBuild(
  String? vodPath,
  String? seriesPath,
  String? downloadError,
  String dbPath,
) async {
  String? parseError;
  Future<List<Object?>> read(String? path) async {
    if (path == null) return <Object?>[];
    try {
      final Object? data = jsonDecode(
        utf8.decode(await File(path).readAsBytes(), allowMalformed: true),
      );
      return data is List<Object?> ? data : <Object?>[];
    } on FormatException {
      parseError = 'resposta do servidor não reconhecida';
      return <Object?>[];
    }
  }

  final List<Object?> vod = await read(vodPath);
  final List<Object?> series = await read(seriesPath);
  if (vod.isEmpty && series.isEmpty) {
    throw DownloadException(
      downloadError ?? parseError ?? 'o servidor não devolveu notas nem datas',
    );
  }
  buildMetadataDb(dbPath, vod, series);
}
