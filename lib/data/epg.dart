import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:sqlite3/sqlite3.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';

import '../domain/section.dart';
import 'download.dart';

final RegExp _hdrAttr = RegExp(r'([\w-]+)="([^"]*)"');
final RegExp _nameBrackets = RegExp(r'[\[({][^\])}]*[\])}]');
final RegExp _namePrefix = RegExp(r'^\s*[a-z]{2,3}\s*[:|]\s*');
final RegExp _nameTags = RegExp(
  r'\b(?:uhd|fhd|hd|sd|4k|8k|hevc|h\.?26[45]|hdr|\d{2,3}\s?fps|alt)\b',
);
final RegExp _idCountry = RegExp(r'\.[a-z]{2}$');

/// Chave para ligar o nome do canal da lista ao nome do canal no guia:
/// ignora acentos, marcações de qualidade (HD, FHD, 4K...), texto entre
/// colchetes/parênteses e prefixos de país como `BR:`.
String epgNameKey(String name) {
  final String s = normalize(name)
      .replaceAll(_nameBrackets, ' ')
      .replaceFirst(_namePrefix, '')
      .replaceAll(_nameTags, ' ');
  final String k = matchKey(s);
  return k.isEmpty ? matchKey(name) : k;
}

/// URLs do guia declaradas na primeira linha do M3U (`url-tvg`, `x-tvg-url`).
List<String> epgUrlsFromHeader(String line) {
  if (!line.startsWith('#EXTM3U')) return const <String>[];
  final List<String> urls = <String>[];
  for (final RegExpMatch m in _hdrAttr.allMatches(line)) {
    final String key = m.group(1)!.toLowerCase();
    if (key.contains('tvg') || key.contains('epg') || key.contains('xmltv')) {
      for (final String u in m.group(2)!.split(',')) {
        final String t = u.trim();
        if (t.startsWith('http://') || t.startsWith('https://')) urls.add(t);
      }
    }
  }
  return urls;
}

/// Converte `20261015120000 -0300` (XMLTV) em segundos desde 1970 (UTC).
int? parseXmltvTime(String raw) {
  final RegExpMatch? m = RegExp(
    r'^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})?\s*([+-]\d{4})?',
  ).firstMatch(raw.trim());
  if (m == null) return null;
  final DateTime base = DateTime.utc(
    int.parse(m[1]!),
    int.parse(m[2]!),
    int.parse(m[3]!),
    int.parse(m[4]!),
    int.parse(m[5]!),
    int.parse(m[6] ?? '0'),
  );
  int secs = base.millisecondsSinceEpoch ~/ 1000;
  final String? off = m[7];
  if (off != null) {
    final int sign = off.startsWith('-') ? -1 : 1;
    final int h = int.parse(off.substring(1, 3));
    final int mi = int.parse(off.substring(3, 5));
    secs -= sign * (h * 3600 + mi * 60);
  }
  return secs;
}

class Programme {
  const Programme({
    required this.title,
    required this.start,
    required this.stop,
    this.descr,
  });

  final String title;
  final String? descr;
  final int start;
  final int stop;
}

bool epgIsFresh(String dbPath, {Duration maxAge = const Duration(hours: 12)}) {
  final File f = File(dbPath);
  return f.existsSync() &&
      DateTime.now().difference(f.lastModifiedSync()) < maxAge;
}

String _explain(Exception e) {
  if (e is DownloadException) return e.message;
  if (e is FileSystemException) return 'arquivo do guia não encontrado';
  return 'formato do guia não reconhecido';
}

/// Baixa (ou lê) o XMLTV de cada fonte e guarda só a janela de -3 h a +48 h.
/// Devolve quantos programas foram gravados.
Future<int> importEpg(
  List<String> sources,
  String dbPath, {
  bool allowInsecure = false,
}) {
  return Isolate.run<int>(() async {
    final File tmp = File('$dbPath.tmp');
    if (tmp.existsSync()) tmp.deleteSync();
    final Database db = sqlite3.open(tmp.path);
    int total = 0;
    try {
      db.execute(
        'CREATE TABLE prog(channel TEXT NOT NULL, start INTEGER NOT NULL, '
        'stop INTEGER NOT NULL, title TEXT NOT NULL, descr TEXT)',
      );
      db.execute(
        'CREATE TABLE chan(nkey TEXT NOT NULL, channel TEXT NOT NULL)',
      );
      final PreparedStatement ins = db.prepare(
        'INSERT INTO prog(channel, start, stop, title, descr) '
        'VALUES (?, ?, ?, ?, ?)',
      );
      final PreparedStatement insChan = db.prepare(
        'INSERT INTO chan(nkey, channel) VALUES (?, ?)',
      );
      final int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      int ok = 0;
      String? lastError;
      for (final String src in sources) {
        final bool remote =
            src.startsWith('http://') || src.startsWith('https://');
        final File file = remote ? File('$dbPath.dl') : File(src);
        try {
          if (remote) {
            await downloadFile(src, file, allowInsecure: allowInsecure);
          }
          total += await _parseInto(
            file,
            db,
            ins,
            insChan,
            now - 3 * 3600,
            now + 48 * 3600,
          );
          ok++;
        } on Exception catch (e) {
          lastError = _explain(e);
        } finally {
          if (remote && file.existsSync()) file.deleteSync();
        }
      }
      ins.close();
      insChan.close();
      if (ok == 0) {
        throw DownloadException(
          lastError ?? 'nenhuma fonte de guia disponível',
        );
      }
      db.execute('CREATE INDEX idx_prog ON prog(channel, start)');
      db.execute('CREATE INDEX idx_chan ON chan(nkey)');
    } finally {
      db.close();
    }
    final File dest = File(dbPath);
    if (dest.existsSync()) dest.deleteSync();
    tmp.renameSync(dbPath);
    return total;
  });
}

Future<int> _parseInto(
  File file,
  Database db,
  PreparedStatement ins,
  PreparedStatement insChan,
  int from,
  int to,
) async {
  final RandomAccessFile rf = file.openSync();
  final List<int> magic = rf.readSync(2);
  rf.closeSync();
  Stream<List<int>> bytes = file.openRead();
  if (magic.length == 2 && magic[0] == 0x1f && magic[1] == 0x8b) {
    bytes = bytes.transform(gzip.decoder); // arquivo .xml.gz
  }
  final Stream<XmlNode> nodes = bytes
      .transform(const Utf8Decoder(allowMalformed: true))
      .toXmlEvents()
      .normalizeEvents()
      .selectSubtreeEvents(
        (XmlStartElementEvent e) =>
            e.localName == 'programme' || e.localName == 'channel',
      )
      .toXmlNodes()
      .flatten();

  int n = 0;
  db.execute('BEGIN');
  try {
    await for (final XmlNode node in nodes) {
      if (node is! XmlElement) continue;
      if (node.localName == 'channel') {
        final String? id = node.getAttribute('id')?.trim().toLowerCase();
        if (id == null || id.isEmpty) continue;
        // Nomes de exibição primeiro; o próprio id serve de último recurso.
        for (final XmlElement d in node.findElements('display-name')) {
          final String k = epgNameKey(d.innerText);
          if (k.isNotEmpty) insChan.execute(<Object?>[k, id]);
        }
        final String k = epgNameKey(id.replaceFirst(_idCountry, ''));
        if (k.isNotEmpty) insChan.execute(<Object?>[k, id]);
        continue;
      }
      final String? ch = node.getAttribute('channel');
      final int? st = parseXmltvTime(node.getAttribute('start') ?? '');
      final int? sp = parseXmltvTime(node.getAttribute('stop') ?? '');
      if (ch == null || st == null || sp == null) continue;
      if (sp < from || st > to) continue;
      final String title = node.getElement('title')?.innerText.trim() ?? '';
      if (title.isEmpty) continue;
      String? desc = node.getElement('desc')?.innerText.trim();
      if (desc != null && desc.isEmpty) desc = null;
      if (desc != null && desc.length > 600) desc = desc.substring(0, 600);
      ins.execute(<Object?>[ch.toLowerCase(), st, sp, title, desc]);
      if (++n % 20000 == 0) {
        db.execute('COMMIT');
        db.execute('BEGIN');
      }
    }
    db.execute('COMMIT');
  } on Object {
    db.execute('ROLLBACK');
    rethrow;
  }
  return n;
}

/// Consultas de leitura sobre o guia importado.
class EpgDb {
  EpgDb._(this._db);

  static EpgDb? tryOpen(String path) {
    if (!File(path).existsSync()) return null;
    try {
      return EpgDb._(sqlite3.open(path, mode: OpenMode.readOnly));
    } on Object {
      return null;
    }
  }

  final Database _db;
  late final Set<String> _ids = channelIds();
  late final Map<String, String> _byName = _loadNames();
  final Map<String, String?> _resolved = <String, String?>{};

  /// Guias importados antes da ligação por nome não têm a tabela `chan`.
  bool get hasNames => _db
      .select(
        "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'chan'",
      )
      .isNotEmpty;

  Map<String, String> _loadNames() {
    if (!hasNames) return const <String, String>{};
    final Map<String, String> m = <String, String>{};
    final ResultSet rs = _db.select(
      'SELECT nkey, channel FROM chan ORDER BY rowid',
    );
    for (final Row r in rs) {
      m.putIfAbsent(r['nkey'] as String, () => r['channel'] as String);
    }
    return m;
  }

  Set<String> channelIds() {
    final ResultSet rs = _db.select('SELECT DISTINCT channel FROM prog');
    return <String>{for (final Row r in rs) r['channel'] as String};
  }

  /// Canal do guia para um item da lista: pelo tvg-id e, sem ele, pelo nome.
  String? channelFor(String? tvgId, String name) {
    if (tvgId != null && tvgId.isNotEmpty) {
      final String id = tvgId.toLowerCase();
      if (_ids.contains(id)) return id;
    }
    if (name.isEmpty) return null;
    return _resolved.putIfAbsent(name, () => _byName[epgNameKey(name)]);
  }

  /// Quantos itens da lista têm programação no guia.
  int matchCount(Iterable<(String?, String)> channels) {
    int n = 0;
    for (final (String? id, String name) in channels) {
      if (channelFor(id, name) != null) n++;
    }
    return n;
  }

  /// Programas do canal do guia [channel] que passam entre [from] e [to].
  List<Programme> programmes(String channel, int from, int to) {
    final ResultSet rs = _db.select(
      'SELECT start, stop, title, descr FROM prog '
      'WHERE channel = ? AND stop > ? AND start < ? ORDER BY start',
      <Object?>[channel, from, to],
    );
    return <Programme>[
      for (final Row r in rs)
        Programme(
          title: r['title'] as String,
          descr: r['descr'] as String?,
          start: r['start'] as int,
          stop: r['stop'] as int,
        ),
    ];
  }

  /// (programa atual, próximo programa) do canal, pelo tvg-id ou pelo nome.
  (Programme?, Programme?) nowNext(
    String? tvgId,
    int nowSecs, {
    String name = '',
  }) {
    final String? ch = channelFor(tvgId, name);
    if (ch == null) return (null, null);
    final ResultSet rs = _db.select(
      'SELECT start, stop, title, descr FROM prog '
      'WHERE channel = ? AND stop > ? ORDER BY start LIMIT 2',
      <Object?>[ch, nowSecs],
    );
    Programme? cur;
    Programme? next;
    for (final Row r in rs) {
      final Programme p = Programme(
        title: r['title'] as String,
        descr: r['descr'] as String?,
        start: r['start'] as int,
        stop: r['stop'] as int,
      );
      if (cur == null && p.start <= nowSecs) {
        cur = p;
      } else {
        next ??= p;
      }
    }
    return (cur, next);
  }

  void close() => _db.close();
}
