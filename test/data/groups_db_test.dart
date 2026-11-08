import 'dart:io';

import 'package:bukanero/data/catalog_db.dart';
import 'package:bukanero/data/groups_db.dart';
import 'package:bukanero/domain/channel.dart';
import 'package:bukanero/domain/section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cartão traz versões de outras categorias, sem as ocultas', () async {
    final Directory dir = Directory.systemTemp.createTempSync('bukanero');
    addTearDown(() => dir.deleteSync(recursive: true));
    // Lista inventada que separa as versões por idioma, não por qualidade.
    final File m3u = File('${dir.path}/a.m3u')
      ..writeAsStringSync('''
#EXTM3U
#EXTINF:-1 tvg-logo="http://s/a.jpg" group-title="Filmes | Dublados",Aventura
http://s/movie/u/p/1.mp4
#EXTINF:-1 tvg-logo="http://s/a.jpg" group-title="Filmes | Legendados",Aventura (Legendado)
http://s/movie/u/p/2.mp4
#EXTINF:-1 tvg-logo="http://s/b.jpg" group-title="Filmes | Dublados",Busca
http://s/movie/u/p/3.mp4
#EXTINF:-1 tvg-logo="http://s/b.jpg" group-title="Filmes | Legendados",Busca (Legendado)
http://s/movie/u/p/4.mp4
#EXTINF:-1 tvg-logo="http://s/c.jpg" group-title="Filmes | Dublados",Cidade
http://s/movie/u/p/5.mp4
#EXTINF:-1 tvg-logo="http://s/c.jpg" group-title="Filmes | Legendados",Cidade (Legendado)
http://s/movie/u/p/6.mp4
''');
    final String catPath = '${dir.path}/c.db';
    final String grpPath = '${dir.path}/g.db';
    await importCatalog(m3u.path, catPath);
    await ensureGroups(catPath, grpPath);
    final CatalogDb db = CatalogDb.open(catPath);
    addTearDown(db.close);
    final GroupIndex gi = GroupIndex.tryOpen(grpPath)!;

    // Só a categoria "Dublados" aberta: o legendado vem junto no cartão.
    final List<Channel> cards = gi.collapse(
      db.items(Section.movies, 'Filmes | Dublados', ''),
      fetch: db.itemsByIds,
    );
    expect(cards.map((Channel c) => c.name), <String>[
      'Aventura',
      'Busca',
      'Cidade',
    ]);
    expect(cards.first.versions.map((ChannelVersion v) => v.label), <String>[
      'Padrão',
      'LEGENDADO',
    ]);

    // Versão oculta pelo usuário fica de fora.
    final List<Channel> noLeg = gi.collapse(
      db.items(Section.movies, 'Filmes | Dublados', ''),
      fetch: db.itemsByIds,
      isHidden: (Channel c) => c.name == 'Busca (Legendado)',
    );
    expect(noLeg[1].isGroup, isFalse);

    // Grupo separado pelo usuário: as versões ficam soltas.
    final List<Channel> apart = gi.collapse(
      db.items(Section.movies, 'Filmes | Dublados', ''),
      fetch: db.itemsByIds,
      separated: <String>{cards.first.groupKey!},
    );
    expect(apart.first.isGroup, isFalse);
    // Cada versão solta sabe de que grupo veio, para juntar de novo.
    final Set<String> sep = <String>{cards.first.groupKey!};
    expect(gi.separatedKey(apart.first, sep), cards.first.groupKey);
    expect(gi.separatedKey(apart.first, <String>{}), isNull);
    expect(gi.nameOfKey(cards.first.groupKey!), 'Aventura');
  });
}
