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

bool metaIsFresh(String dbPath, {Duration maxAge = const Duration(hours: 24)}) {
  final File f = File(dbPath);
  return f.existsSync() &&
      DateTime.now().difference(f.lastModifiedSync()) < maxAge;
}

/// Grava nota, data e ano num banco novo. As séries são ligadas pelo nome
/// (sem acentos e pontuação); se houver nomes repetidos, vale o maior valor.
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
        year INTEGER
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
    }
    final PreparedStatement isr = db.prepare(
      'INSERT OR REPLACE INTO series(mkey, rating, modified, year) '
      'VALUES (?, ?, ?, ?)',
    );
    db.execute('BEGIN');
    agg.forEach((String k, List<num?> v) {
      isr.execute(<Object?>[k, v[0], v[1], v[2]]);
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
Future<void> importMetadata(
  ApiAccess api,
  String dbPath, {
  bool allowInsecure = false,
}) {
  return Isolate.run<void>(() async {
    String? lastError;

    Future<List<Object?>> grab(String action) async {
      final File f = File('$dbPath.$action.json');
      try {
        await downloadFile(
          _apiUri(api, action).toString(),
          f,
          allowInsecure: allowInsecure,
        );
        final Object? data = jsonDecode(
          utf8.decode(await f.readAsBytes(), allowMalformed: true),
        );
        return data is List<Object?> ? data : <Object?>[];
      } on DownloadException catch (e) {
        lastError = e.message;
        return <Object?>[];
      } on FormatException {
        lastError = 'resposta do servidor não reconhecida';
        return <Object?>[];
      } finally {
        if (f.existsSync()) f.deleteSync();
      }
    }

    final List<Object?> vod = await grab('get_vod_streams');
    final List<Object?> series = await grab('get_series');
    if (vod.isEmpty && series.isEmpty) {
      throw DownloadException(
        lastError ?? 'o servidor não devolveu notas nem datas',
      );
    }
    buildMetadataDb(dbPath, vod, series);
  });
}
