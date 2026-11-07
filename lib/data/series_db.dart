import 'dart:io';
import 'dart:isolate';

import 'package:sqlite3/sqlite3.dart';

import '../domain/channel.dart';
import '../domain/section.dart';
import '../domain/series.dart';
import '../domain/sort_mode.dart';

const int _version = 4;

String _escapeLike(String q) =>
    q.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');

/// Ordem dentro de uma categoria (`pos` = posição do 1º episódio na lista).
/// `s` = séries, `m` = notas/datas (se ligadas).
String _orderInGroup(SortMode m) => switch (m) {
  SortMode.listOrder => 's.pos',
  SortMode.listOrderReverse => 's.pos DESC',
  SortMode.nameAsc => 's.nkey, s.pos',
  SortMode.nameDesc => 's.nkey DESC, s.pos',
  SortMode.recent => 'COALESCE(m.modified, 0) DESC, s.pos',
  SortMode.rating => 'COALESCE(m.rating, -1) DESC, s.pos',
  SortMode.year => 'COALESCE(m.year, 0) DESC, s.pos',
};

/// Ordem na busca global, onde a mesma série pode estar em várias categorias.
/// (Dentro do mesmo título a chave `mkey` é a mesma, então `m.*` não varia.)
String _orderGlobal(SortMode m) => switch (m) {
  SortMode.listOrder => 'firstpos',
  SortMode.listOrderReverse => 'firstpos DESC',
  SortMode.nameAsc => 's.nkey, firstpos',
  SortMode.nameDesc => 's.nkey DESC, firstpos',
  SortMode.recent => 'COALESCE(m.modified, 0) DESC, firstpos',
  SortMode.rating => 'COALESCE(m.rating, -1) DESC, firstpos',
  SortMode.year => 'COALESCE(m.year, 0) DESC, firstpos',
};

bool _isCurrent(String seriesPath, String stamp) {
  if (!File(seriesPath).existsSync()) return false;
  Database? db;
  try {
    db = sqlite3.open(seriesPath, mode: OpenMode.readOnly);
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

/// Cria (ou atualiza) o índice de séries a partir do catálogo importado.
/// Só reconstrói quando o catálogo mudou.
Future<void> ensureSeriesIndex(String catalogPath, String seriesPath) {
  return Isolate.run<void>(() {
    final Database cat = sqlite3.open(catalogPath, mode: OpenMode.readOnly);
    try {
      final ResultSet st = cat.select(
        'SELECT value FROM meta WHERE key = ?',
        <Object?>['stamp'],
      );
      final String stamp = '$_version:${st.isEmpty ? '' : st.first['value']}';
      if (_isCurrent(seriesPath, stamp)) return;
      _build(cat, seriesPath, stamp);
    } finally {
      cat.close();
    }
  });
}

void _build(Database cat, String seriesPath, String stamp) {
  final File tmp = File('$seriesPath.tmp');
  if (tmp.existsSync()) tmp.deleteSync();
  final Database db = sqlite3.open(tmp.path);
  try {
    db.execute('''
      CREATE TABLE episodes(
        title TEXT NOT NULL,
        nkey TEXT NOT NULL,
        mkey TEXT NOT NULL,
        season INTEGER NOT NULL,
        episode INTEGER NOT NULL,
        grp TEXT NOT NULL,
        name TEXT NOT NULL,
        url TEXT NOT NULL,
        logo TEXT
      );
      CREATE TABLE meta(key TEXT PRIMARY KEY, value TEXT);
    ''');
    final PreparedStatement ins = db.prepare(
      'INSERT INTO episodes(title, nkey, mkey, season, episode, grp, name, '
      'url, logo) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
    );
    final PreparedStatement sel = cat.prepare(
      'SELECT id, grp, name, url, logo FROM items '
      'WHERE section = ? AND id > ? ORDER BY id LIMIT 20000',
    );
    int lastId = 0;
    db.execute('BEGIN');
    while (true) {
      final ResultSet rs = sel.select(<Object?>[Section.series.index, lastId]);
      if (rs.isEmpty) break;
      for (final Row r in rs) {
        lastId = r['id'] as int;
        final String name = r['name'] as String;
        final EpisodeInfo? info = parseEpisode(name);
        final String title = info?.title ?? name;
        ins.execute(<Object?>[
          title,
          normalize(title),
          matchKey(title),
          info?.season ?? 1,
          info?.episode ?? 1,
          r['grp'],
          name,
          r['url'],
          r['logo'],
        ]);
      }
    }
    db.execute('COMMIT');
    ins.close();
    sel.close();

    // A capa e o endereço vêm do primeiro episódio que tem imagem
    // (o SQLite pega as colunas "soltas" da linha que tem o MIN).
    // `pos` guarda a posição do 1º episódio na lista original.
    db.execute('''
      CREATE INDEX idx_episodes_grp_title ON episodes(grp, title);
      CREATE INDEX idx_episodes_title ON episodes(title);
      CREATE TABLE series(
        grp TEXT NOT NULL,
        title TEXT NOT NULL,
        nkey TEXT NOT NULL,
        mkey TEXT NOT NULL,
        logo TEXT,
        url TEXT NOT NULL,
        episodes INTEGER NOT NULL,
        pos INTEGER NOT NULL DEFAULT 0
      );
      INSERT INTO series(grp, title, nkey, mkey, logo, url, episodes)
        SELECT grp, title, nkey, mkey, logo, url, n FROM (
          SELECT grp, title, nkey, mkey, logo, url, COUNT(*) AS n,
                 MIN(CASE WHEN logo IS NOT NULL AND logo <> ''
                          THEN season * 10000 + episode END) AS m
          FROM episodes GROUP BY grp, title
        );
      -- Imagens de episódio que aparecem em séries diferentes são genéricas
      -- do provedor (a mesma foto em centenas de séries): não servem.
      CREATE TABLE generic_logo(logo TEXT PRIMARY KEY);
      INSERT INTO generic_logo(logo)
        SELECT logo FROM episodes WHERE logo IS NOT NULL AND logo <> ''
        GROUP BY logo HAVING COUNT(DISTINCT title) > 1;
      UPDATE series SET logo = NULL
        WHERE logo IN (SELECT logo FROM generic_logo);
      UPDATE series SET pos = (
        SELECT MIN(rowid) FROM episodes e
        WHERE e.grp = series.grp AND e.title = series.title
      );
      CREATE INDEX idx_series_grp_nkey ON series(grp, nkey);
      CREATE INDEX idx_series_grp_pos ON series(grp, pos);
      CREATE INDEX idx_series_title ON series(title);
    ''');
    db.execute('INSERT INTO meta(key, value) VALUES (?, ?)', <Object?>[
      'stamp',
      stamp,
    ]);
  } finally {
    db.close();
  }
  final File dest = File(seriesPath);
  if (dest.existsSync()) dest.deleteSync();
  tmp.renameSync(seriesPath);
}

/// Consultas de leitura sobre o índice de séries.
class SeriesDb {
  SeriesDb._(this._db);

  factory SeriesDb.open(String path) =>
      SeriesDb._(sqlite3.open(path, mode: OpenMode.readOnly));

  final Database _db;
  bool _metaOn = false;
  bool _coverOn = false;
  bool _infoOn = false;

  /// Ordem usada por [list] e [search].
  SortMode sort = SortMode.nameAsc;

  bool get hasMeta => _metaOn;

  /// Liga o banco de notas e datas (nome interno `mx`).
  bool attachMeta(String path) {
    detachMeta();
    if (!File(path).existsSync()) return false;
    try {
      _db.execute('ATTACH DATABASE ? AS mx', <Object?>[path]);
      _metaOn = true;
      // Bancos de notas antigos não têm o pôster das séries.
      final Set<String> cols = <String>{
        for (final Row r in _db.select('PRAGMA mx.table_info(series)'))
          r['name'] as String,
      };
      _coverOn = cols.contains('cover');
      _infoOn = cols.contains('sid') && cols.contains('plot');
    } on Object {
      _metaOn = false;
      _coverOn = false;
      _infoOn = false;
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
    _coverOn = false;
    _infoOn = false;
  }

  SortMode get _eff => (sort.needsMeta && !_metaOn) ? SortMode.listOrder : sort;

  String get _join => _metaOn ? 'LEFT JOIN mx.series m ON m.mkey = s.mkey' : '';

  String get _rating => _metaOn ? 'm.rating' : 'NULL';

  /// Capa: o pôster da série vindo do servidor; sem ele, a imagem do
  /// primeiro episódio que tem imagem.
  String get _logo =>
      _coverOn ? "COALESCE(NULLIF(m.cover, ''), s.logo)" : 's.logo';

  /// (séries no total, séries com nota), para conferir a ligação por nome.
  (int, int) metaCoverage() {
    if (!_metaOn) return (0, 0);
    final ResultSet rs = _db.select(
      'SELECT COUNT(*) AS total, COUNT(m.rating) AS rated '
      'FROM series s LEFT JOIN mx.series m ON m.mkey = s.mkey',
    );
    return (rs.first['total'] as int, rs.first['rated'] as int);
  }

  /// Quantas séries (não episódios) há em cada categoria.
  Map<String, int> groupCounts() {
    final ResultSet rs = _db.select(
      'SELECT grp, COUNT(*) AS n FROM series GROUP BY grp',
    );
    return <String, int>{
      for (final Row r in rs) r['grp'] as String: r['n'] as int,
    };
  }

  Channel _entry(Row r, String group) {
    final String title = r['title'] as String;
    final int n = r['n'] as int;
    return Channel(
      name: title,
      // Série de um episódio só toca direto; as outras abrem a janela.
      url: n == 1 ? r['url'] as String : '$seriesUrlPrefix$title',
      group: group,
      logo: r['logo'] as String?,
      rating: (r['rating'] as num?)?.toDouble(),
    );
  }

  /// Séries de uma categoria, com filtro opcional pelo título.
  List<Channel> list(
    String group,
    String query, {
    Set<String> exclude = const <String>{},
    int limit = 2000,
  }) {
    final ResultSet rs = _db.select(
      'SELECT s.title AS title, $_logo AS logo, s.url AS url, '
      's.episodes AS n, $_rating AS rating FROM series s $_join '
      'WHERE s.grp = ? AND s.title LIKE ? ESCAPE ? '
      'ORDER BY ${_orderInGroup(_eff)} LIMIT ?',
      <Object?>[group, '%${_escapeLike(query)}%', r'\', limit + exclude.length],
    );
    final List<Channel> out = <Channel>[];
    for (final Row r in rs) {
      if (exclude.contains(r['title'] as String)) continue;
      out.add(_entry(r, group));
      if (out.length >= limit) break;
    }
    return out;
  }

  /// Busca pelo título em todas as categorias (a mesma série vira um só item,
  /// representado pela sua primeira aparição na lista).
  List<Channel> search(
    String query, {
    bool Function(String group, String title)? isHidden,
    int limit = 500,
  }) {
    const int batch = 1000;
    final String like = '%${_escapeLike(query)}%';
    final List<Channel> out = <Channel>[];
    int offset = 0;
    while (out.length < limit) {
      final ResultSet rs = _db.select(
        'SELECT s.title AS title, s.grp AS grp, $_logo AS logo, '
        's.url AS url, SUM(s.episodes) AS n, MIN(s.pos) AS firstpos, '
        '$_rating AS rating '
        'FROM series s $_join WHERE s.title LIKE ? ESCAPE ? '
        'GROUP BY s.title ORDER BY ${_orderGlobal(_eff)} LIMIT ? OFFSET ?',
        <Object?>[like, r'\', batch, offset],
      );
      for (final Row r in rs) {
        final String group = r['grp'] as String;
        if (isHidden != null && isHidden(group, r['title'] as String)) continue;
        out.add(_entry(r, group));
        if (out.length >= limit) break;
      }
      if (rs.length < batch) break;
      offset += batch;
    }
    return out;
  }

  /// Id da série no servidor e a sinopse, quando as notas já chegaram.
  (int?, String?) seriesInfo(String title) {
    if (!_infoOn) return (null, null);
    final ResultSet rs = _db.select(
      'SELECT m.sid AS sid, m.plot AS plot FROM series s '
      'JOIN mx.series m ON m.mkey = s.mkey WHERE s.title = ? LIMIT 1',
      <Object?>[title],
    );
    if (rs.isEmpty) return (null, null);
    return (rs.first['sid'] as int?, rs.first['plot'] as String?);
  }

  /// Episódios de uma série, ordenados, sem repetir temporada e episódio.
  List<Episode> episodes(String title) {
    // Imagem genérica (repetida em outras séries) vira null: a janela usa
    // a imagem da própria série no lugar.
    final ResultSet rs = _db.select(
      'SELECT e.name AS name, e.url AS url, e.season AS season, '
      'e.episode AS episode, '
      'CASE WHEN g.logo IS NULL THEN e.logo END AS logo '
      'FROM episodes e LEFT JOIN generic_logo g ON g.logo = e.logo '
      'WHERE e.title = ? ORDER BY e.season, e.episode, e.rowid',
      <Object?>[title],
    );
    final Set<int> seen = <int>{};
    final List<Episode> out = <Episode>[];
    for (final Row r in rs) {
      final int season = r['season'] as int;
      final int episode = r['episode'] as int;
      if (!seen.add(season * 10000 + episode)) continue;
      out.add(
        Episode(
          name: r['name'] as String,
          url: r['url'] as String,
          season: season,
          episode: episode,
          logo: r['logo'] as String?,
        ),
      );
    }
    return out;
  }

  void close() => _db.close();
}
