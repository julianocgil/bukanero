import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:bukanero/data/catalog_db.dart';
import 'package:bukanero/domain/section.dart';

void main() {
  test('importa, detecta mudança e consulta', () async {
    final Directory dir = Directory.systemTemp.createTempSync('bukanero');
    addTearDown(() => dir.deleteSync(recursive: true));
    final File m3u = File('${dir.path}/a.m3u')
      ..writeAsStringSync('''
#EXTM3U
#EXTINF:-1 group-title="Canais | A",Um
http://s/1
#EXTINF:-1 group-title="Canais | A",Dois
http://s/2
#EXTINF:-1 group-title="Filmes | B",Filme 100%
http://s/movie/u/p/3.mp4
''');
    final String dbPath = '${dir.path}/c.db';

    expect(catalogIsFresh(dbPath, m3u.path), isFalse);
    await importCatalog(m3u.path, dbPath);
    expect(catalogIsFresh(dbPath, m3u.path), isTrue);

    final CatalogDb db = CatalogDb.open(dbPath);
    addTearDown(db.close);
    expect(db.groupCounts(Section.live), <String, int>{'Canais | A': 2});
    expect(db.groupCounts(Section.movies), <String, int>{'Filmes | B': 1});
    expect(db.items(Section.live, 'Canais | A', 'um'), hasLength(1));
    expect(db.items(Section.movies, 'Filmes | B', '100%'), hasLength(1));
    expect(db.items(Section.movies, 'Filmes | B', 'zzz'), isEmpty);

    m3u.writeAsStringSync('#EXTM3U\n#EXTINF:-1,Outro\nhttp://s/9\n');
    expect(catalogIsFresh(dbPath, m3u.path), isFalse);
  });
}
