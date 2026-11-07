import 'package:sqlite3/sqlite3.dart';

import '../domain/section.dart';

/// Chave única (categoria + nome) para itens ocultos em buscas globais.
String hiddenKey(String group, String name) => '$group\u0000$name';

/// Escolhas do usuário por perfil (categorias e itens ocultos).
/// Fica fora do catálogo para sobreviver a atualizações da lista.
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
    ''');
    return UserData._(db);
  }

  final Database _db;

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

  void close() => _db.close();
}
