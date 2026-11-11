import 'package:sqlite3/sqlite3.dart';

import '../domain/channel.dart';
import '../domain/section.dart';

/// Chave única (categoria + nome) para itens ocultos em buscas globais.
String hiddenKey(String group, String name) => '$group\u0000$name';

/// Escolhas do usuário por perfil (categorias e itens ocultos, ordem
/// preferida, assistidos recentemente). Fica fora do catálogo para
/// sobreviver a atualizações da lista.
class UserData {
  UserData._(this._db);

  factory UserData.open(String path) {
    final Database db = sqlite3.open(path);
    db.execute('''
      CREATE TABLE IF NOT EXISTS hidden_groups(
        section INTEGER NOT NULL,
        grp TEXT NOT NULL,
        PRIMARY KEY(section, grp)
      );
      CREATE TABLE IF NOT EXISTS hidden_items(
        section INTEGER NOT NULL,
        grp TEXT NOT NULL,
        name TEXT NOT NULL,
        PRIMARY KEY(section, grp, name)
      );
      CREATE TABLE IF NOT EXISTS prefs(
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      );
      CREATE TABLE IF NOT EXISTS recent(
        section INTEGER NOT NULL,
        url TEXT NOT NULL,
        name TEXT NOT NULL,
        grp TEXT,
        logo TEXT,
        at INTEGER NOT NULL,
        PRIMARY KEY(section, url)
      );
      CREATE TABLE IF NOT EXISTS separated(key TEXT PRIMARY KEY);
      CREATE TABLE IF NOT EXISTS favorite(
        section INTEGER NOT NULL,
        url TEXT NOT NULL,
        name TEXT NOT NULL,
        at INTEGER NOT NULL,
        PRIMARY KEY(section, url)
      );
    ''');
    return UserData._(db);
  }

  final Database _db;

  /// Sobe a cada mudança em ocultos, favoritos ou grupos separados, para a
  /// tela saber quando refazer a lista.
  int get revision => _revision;
  int _revision = 0;

  Set<String> hiddenGroups(Section s) {
    final ResultSet rs = _db.select(
      'SELECT grp FROM hidden_groups WHERE section = ?',
      <Object?>[s.index],
    );
    return <String>{for (final Row r in rs) r['grp'] as String};
  }

  Set<String> hiddenItems(Section s, String group) {
    final ResultSet rs = _db.select(
      'SELECT name FROM hidden_items WHERE section = ? AND grp = ?',
      <Object?>[s.index, group],
    );
    return <String>{for (final Row r in rs) r['name'] as String};
  }

  void setGroupHidden(Section s, String group, {required bool hidden}) {
    _revision++;
    if (hidden) {
      _db.execute(
        'INSERT OR IGNORE INTO hidden_groups(section, grp) VALUES (?, ?)',
        <Object?>[s.index, group],
      );
    } else {
      _db.execute(
        'DELETE FROM hidden_groups WHERE section = ? AND grp = ?',
        <Object?>[s.index, group],
      );
    }
  }

  void setItemHidden(
    Section s,
    String group,
    String name, {
    required bool hidden,
  }) {
    _revision++;
    if (hidden) {
      _db.execute(
        'INSERT OR IGNORE INTO hidden_items(section, grp, name) '
        'VALUES (?, ?, ?)',
        <Object?>[s.index, group, name],
      );
    } else {
      _db.execute(
        'DELETE FROM hidden_items WHERE section = ? AND grp = ? AND name = ?',
        <Object?>[s.index, group, name],
      );
    }
  }

  /// Todos os itens ocultos da seção, como `hiddenKey(categoria, nome)`.
  Set<String> hiddenItemKeys(Section s) {
    final ResultSet rs = _db.select(
      'SELECT grp, name FROM hidden_items WHERE section = ?',
      <Object?>[s.index],
    );
    return <String>{
      for (final Row r in rs)
        hiddenKey(r['grp'] as String, r['name'] as String),
    };
  }

  String? pref(String key) {
    final ResultSet rs = _db.select(
      'SELECT value FROM prefs WHERE key = ?',
      <Object?>[key],
    );
    return rs.isEmpty ? null : rs.first['value'] as String;
  }

  void setPref(String key, String value) => _db.execute(
    'INSERT OR REPLACE INTO prefs(key, value) VALUES (?, ?)',
    <Object?>[key, value],
  );

  /// Guarda [c] como assistido agora (sobe para o começo se já estava).
  /// Só os [keep] mais recentes de cada seção ficam guardados.
  void addRecent(Section s, Channel c, {int keep = 30}) {
    _db.execute(
      'INSERT OR REPLACE INTO recent(section, url, name, grp, logo, at) '
      'VALUES (?, ?, ?, ?, ?, ?)',
      <Object?>[
        s.index,
        c.url,
        c.name,
        c.group,
        c.logo,
        DateTime.now().microsecondsSinceEpoch,
      ],
    );
    _db.execute(
      'DELETE FROM recent WHERE section = ? AND url NOT IN ('
      'SELECT url FROM recent WHERE section = ? ORDER BY at DESC LIMIT ?)',
      <Object?>[s.index, s.index, keep],
    );
  }

  /// Assistidos recentemente, do mais novo para o mais antigo.
  List<Channel> recent(Section s, {int limit = 30}) {
    final ResultSet rs = _db.select(
      'SELECT url, name, grp, logo FROM recent WHERE section = ? '
      'ORDER BY at DESC LIMIT ?',
      <Object?>[s.index, limit],
    );
    return <Channel>[
      for (final Row r in rs)
        Channel(
          name: r['name'] as String,
          url: r['url'] as String,
          group: r['grp'] as String?,
          logo: r['logo'] as String?,
        ),
    ];
  }

  void removeRecent(Section s, String url) => _db.execute(
    'DELETE FROM recent WHERE section = ? AND url = ?',
    <Object?>[s.index, url],
  );

  /// Grupos que o usuário mandou separar (chave do cartão).
  Set<String> separatedGroups() => <String>{
    for (final Row r in _db.select('SELECT key FROM separated'))
      r['key'] as String,
  };

  void setSeparated(String key, {required bool separated}) {
    _revision++;
    if (separated) {
      _db.execute('INSERT OR IGNORE INTO separated(key) VALUES (?)', <Object?>[
        key,
      ]);
    } else {
      _db.execute('DELETE FROM separated WHERE key = ?', <Object?>[key]);
    }
  }

  /// Endereços favoritos da seção (o de um cartão agrupado é o da versão
  /// que ele mostra; o de uma série é `series://título`).
  Set<String> favorites(Section s) => <String>{
    for (final Row r in _db.select(
      'SELECT url FROM favorite WHERE section = ?',
      <Object?>[s.index],
    ))
      r['url'] as String,
  };

  /// Favoritos da seção, do mais novo para o mais antigo.
  List<(String, String)> favoriteList(Section s) => <(String, String)>[
    for (final Row r in _db.select(
      'SELECT url, name FROM favorite WHERE section = ? ORDER BY at DESC',
      <Object?>[s.index],
    ))
      (r['url'] as String, r['name'] as String),
  ];

  void setFavorite(Section s, Channel c, {required bool favorite}) {
    _revision++;
    if (favorite) {
      _db.execute(
        'INSERT OR REPLACE INTO favorite(section, url, name, at) '
        'VALUES (?, ?, ?, ?)',
        <Object?>[
          s.index,
          c.url,
          c.name,
          DateTime.now().microsecondsSinceEpoch,
        ],
      );
    } else {
      _db.execute(
        'DELETE FROM favorite WHERE section = ? AND url = ?',
        <Object?>[s.index, c.url],
      );
    }
  }

  void close() => _db.close();
}
