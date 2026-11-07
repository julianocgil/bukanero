import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:bukanero/data/catalog_db.dart';
import 'package:bukanero/data/metadata.dart';
import 'package:bukanero/data/series_db.dart';
import 'package:bukanero/domain/channel.dart';
import 'package:bukanero/domain/section.dart';
import 'package:bukanero/domain/series.dart';
import 'package:bukanero/domain/sort_mode.dart';
import 'package:bukanero/domain/stream_id.dart';

List<String> _names(List<Channel> l) => l.map((Channel c) => c.name).toList();

void main() {
  test('id do stream no fim da URL', () {
    expect(streamIdFromUrl('http://h:80/u/p/90647.ts'), 90647);
    expect(streamIdFromUrl('http://h/movie/u/p/12.mp4'), 12);
    expect(streamIdFromUrl('http://h/x/abc.mp4'), isNull);
  });

  test('descobre servidor e credenciais', () {
    final ApiAccess? a = deriveApiAccess(
      'http://srv:8080/get.php?username=u1&password=p1&type=m3u_plus',
      null,
    );
    expect(a?.base, 'http://srv:8080');
    expect(a?.user, 'u1');
    expect(a?.pass, 'p1');

    final ApiAccess? b = deriveApiAccess(
      '/home/x/lista.m3u',
      'http://srv:8080/movie/u2/p2/55.mp4',
    );
    expect(b?.user, 'u2');
    expect(b?.pass, 'p2');

    expect(deriveApiAccess('/home/x/lista.m3u', null), isNull);
  });

  test('ordenar filmes por data, nota e ano', () async {
    final Directory dir = Directory.systemTemp.createTempSync('bukanero');
    addTearDown(() => dir.deleteSync(recursive: true));
    final File m3u = File('${dir.path}/a.m3u')
      ..writeAsStringSync('''
#EXTM3U
#EXTINF:-1 group-title="Filmes | A",Antigo
http://s/movie/u/p/101.mp4
#EXTINF:-1 group-title="Filmes | A",Novo
http://s/movie/u/p/102.mp4
#EXTINF:-1 group-title="Filmes | A",Sem Dados
http://s/movie/u/p/103.mp4
#EXTINF:-1 group-title="Filmes | A",Bom
http://s/movie/u/p/104.mp4
''');
    final String catPath = '${dir.path}/c.db';
    final String metaPath = '${dir.path}/m.db';
    await importCatalog(m3u.path, catPath);
    final CatalogDb db = CatalogDb.open(catPath);
    addTearDown(db.close);

    List<String> items() => _names(db.items(Section.movies, 'Filmes | A', ''));

    // Sem as notas ligadas, volta para a ordem da lista.
    db.sort = SortMode.rating;
    expect(items(), <String>['Antigo', 'Novo', 'Sem Dados', 'Bom']);
    expect(db.hasMeta, isFalse);

    buildMetadataDb(metaPath, <Object?>[
      <String, dynamic>{
        'stream_id': '101',
        'rating': '5.0',
        'added': '1500000000',
        'year': '2001',
      },
      <String, dynamic>{
        'stream_id': 102,
        'rating': 6.5,
        'added': '1700000000',
        'year': '2020',
      },
      <String, dynamic>{
        'stream_id': '104',
        'rating': '9',
        'added': '1600000000',
        'year': '2010-05-01',
      },
    ], <Object?>[]);
    expect(db.attachMeta(metaPath), isTrue);

    db.sort = SortMode.rating;
    expect(items(), <String>['Bom', 'Novo', 'Antigo', 'Sem Dados']);
    db.sort = SortMode.recent;
    expect(items(), <String>['Novo', 'Bom', 'Antigo', 'Sem Dados']);
    db.sort = SortMode.year;
    expect(items(), <String>['Novo', 'Bom', 'Antigo', 'Sem Dados']);
    expect(db.metaCoverage(), (4, 3));
    // A nota chega até o cartão, em qualquer ordem.
    db.sort = SortMode.nameAsc;
    expect(
      <String, double?>{
        for (final Channel c in db.items(Section.movies, 'Filmes | A', ''))
          c.name: c.rating,
      },
      <String, double?>{'Antigo': 5, 'Bom': 9, 'Novo': 6.5, 'Sem Dados': null},
    );
    db.sort = SortMode.recent;
    expect(_names(db.search(Section.movies, '')), <String>[
      'Novo',
      'Bom',
      'Antigo',
      'Sem Dados',
    ]);
  });

  test('ordenar séries por data, nota e ano', () async {
    final Directory dir = Directory.systemTemp.createTempSync('bukanero');
    addTearDown(() => dir.deleteSync(recursive: true));
    final File m3u = File('${dir.path}/a.m3u')
      ..writeAsStringSync('''
#EXTM3U
#EXTINF:-1 group-title="Series | A",Alfa S01E01
http://s/series/u/p/1.mp4
#EXTINF:-1 group-title="Series | A",Alfa S01E02
http://s/series/u/p/2.mp4
#EXTINF:-1 group-title="Series | A",Zeta S01E01
http://s/series/u/p/3.mp4
#EXTINF:-1 group-title="Series | A",Zeta S01E02
http://s/series/u/p/4.mp4
#EXTINF:-1 group-title="Series | A",Mike S01E01
http://s/series/u/p/5.mp4
#EXTINF:-1 group-title="Series | A",Mike S01E02
http://s/series/u/p/6.mp4
''');
    final String catPath = '${dir.path}/c.db';
    final String serPath = '${dir.path}/s.db';
    final String metaPath = '${dir.path}/m.db';
    await importCatalog(m3u.path, catPath);
    await ensureSeriesIndex(catPath, serPath);
    final SeriesDb db = SeriesDb.open(serPath);
    addTearDown(db.close);

    buildMetadataDb(metaPath, <Object?>[], <Object?>[
      <String, dynamic>{
        'name': 'ALFA',
        'rating': '5',
        'last_modified': '1600000000',
        'year': '2001',
      },
      // Pontuação diferente do título da lista: mesmo assim deve ligar.
      <String, dynamic>{
        'name': 'Zeta!',
        'rating': '9',
        'last_modified': '1500000000',
        'releaseDate': '2020-03-04',
      },
    ]);
    expect(db.attachMeta(metaPath), isTrue);

    List<String> inGroup() => _names(db.list('Series | A', ''));

    db.sort = SortMode.rating;
    expect(inGroup(), <String>['Zeta', 'Alfa', 'Mike']);
    db.sort = SortMode.recent;
    expect(inGroup(), <String>['Alfa', 'Zeta', 'Mike']);
    db.sort = SortMode.year;
    expect(inGroup(), <String>['Zeta', 'Alfa', 'Mike']);
    expect(db.metaCoverage(), (3, 2));

    db.sort = SortMode.rating;
    expect(_names(db.search('')), <String>['Zeta', 'Alfa', 'Mike']);
    db.sort = SortMode.recent;
    expect(_names(db.search('')), <String>['Alfa', 'Zeta', 'Mike']);
  });

  test('capa da série é o pôster do servidor, não o 1º episódio', () async {
    final Directory dir = Directory.systemTemp.createTempSync('bukanero');
    addTearDown(() => dir.deleteSync(recursive: true));
    final File m3u = File('${dir.path}/a.m3u')
      ..writeAsStringSync('''
#EXTM3U
#EXTINF:-1 tvg-logo="http://s/ep/alfa1.jpg" group-title="Series | A",Alfa S01E01
http://s/series/u/p/1.mp4
#EXTINF:-1 tvg-logo="http://s/ep/alfa2.jpg" group-title="Series | A",Alfa S01E02
http://s/series/u/p/2.mp4
#EXTINF:-1 tvg-logo="http://s/ep/beta1.jpg" group-title="Series | A",Beta S01E01
http://s/series/u/p/3.mp4
#EXTINF:-1 tvg-logo="http://s/ep/beta2.jpg" group-title="Series | A",Beta S01E02
http://s/series/u/p/4.mp4
''');
    final String catPath = '${dir.path}/c.db';
    final String serPath = '${dir.path}/s.db';
    final String metaPath = '${dir.path}/m.db';
    await importCatalog(m3u.path, catPath);
    await ensureSeriesIndex(catPath, serPath);
    final SeriesDb db = SeriesDb.open(serPath);
    addTearDown(db.close);

    Map<String, String?> logos(List<Channel> l) => <String, String?>{
      for (final Channel c in l) c.name: c.logo,
    };

    // Sem notas: fica a imagem do primeiro episódio.
    expect(logos(db.list('Series | A', ''))['Alfa'], 'http://s/ep/alfa1.jpg');

    buildMetadataDb(metaPath, <Object?>[], <Object?>[
      <String, dynamic>{
        'name': 'Alfa',
        'cover': 'http://s/poster/alfa.jpg',
        'series_id': '77',
        'plot': 'Sinopse fictícia.',
      },
      // Sem pôster válido: continua a imagem do episódio.
      <String, dynamic>{'name': 'Beta', 'cover': 'sem-imagem'},
    ]);
    expect(metaIsFresh(metaPath), isTrue);
    expect(db.attachMeta(metaPath), isTrue);
    expect(logos(db.list('Series | A', '')), <String, String?>{
      'Alfa': 'http://s/poster/alfa.jpg',
      'Beta': 'http://s/ep/beta1.jpg',
    });
    expect(logos(db.search(''))['Alfa'], 'http://s/poster/alfa.jpg');
    expect(db.list('Series | A', '').first.rating, isNull);
    // Id e sinopse para buscar os detalhes dos episódios.
    expect(db.seriesInfo('Alfa'), (77, 'Sinopse fictícia.'));
    expect(db.seriesInfo('Beta'), (null, null));
    // As imagens dos episódios continuam as próprias.
    expect(db.episodes('Alfa').map((Episode e) => e.logo), <String>[
      'http://s/ep/alfa1.jpg',
      'http://s/ep/alfa2.jpg',
    ]);
  });

  test('banco de notas antigo, sem pôster, conta como velho', () {
    final Directory dir = Directory.systemTemp.createTempSync('bukanero');
    addTearDown(() => dir.deleteSync(recursive: true));
    final String metaPath = '${dir.path}/m.db';
    final Database old = sqlite3.open(metaPath)
      ..execute(
        'CREATE TABLE series(mkey TEXT PRIMARY KEY, rating REAL, '
        'modified INTEGER, year INTEGER)',
      );
    old.close();
    expect(metaIsFresh(metaPath), isFalse);
  });
}
