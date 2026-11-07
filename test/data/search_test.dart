import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meu_iptv/data/catalog_db.dart';
import 'package:meu_iptv/domain/section.dart';

void main() {
  test('busca em todas as categorias da seção', () async {
    final Directory dir = Directory.systemTemp.createTempSync('meuiptv');
    addTearDown(() => dir.deleteSync(recursive: true));
    final File m3u = File('${dir.path}/a.m3u')
      ..writeAsStringSync('''
#EXTM3U
#EXTINF:-1 group-title="Filmes | A",Matrix 100%
http://s/movie/u/p/1.mp4
#EXTINF:-1 group-title="Filmes | B",Matrix Reloaded
http://s/movie/u/p/2.mp4
#EXTINF:-1 group-title="Filmes | B",Outro Filme
http://s/movie/u/p/3.mp4
#EXTINF:-1 group-title="Canais | X",Matrix TV
http://s/live/u/p/4.ts
''');
    final String dbPath = '${dir.path}/c.db';
    await importCatalog(m3u.path, dbPath);
    final CatalogDb db = CatalogDb.open(dbPath);
    addTearDown(db.close);

    expect(db.search(Section.movies, 'matrix'), hasLength(2));
    expect(db.search(Section.movies, ''), hasLength(3));
    expect(db.search(Section.movies, '100%'), hasLength(1));
    expect(db.search(Section.live, 'matrix'), hasLength(1));
    expect(db.search(Section.series, 'matrix'), isEmpty);
    expect(db.search(Section.movies, 'matrix', limit: 1), hasLength(1));
    expect(
      db.search(
        Section.movies,
        'matrix',
        isHidden: (String g, String n) => g == 'Filmes | B',
      ),
      hasLength(1),
    );
    expect(db.search(Section.movies, 'matrix').first.group, 'Filmes | A');
  });
}
