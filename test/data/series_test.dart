import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:bukanero/data/catalog_db.dart';
import 'package:bukanero/data/series_db.dart';
import 'package:bukanero/domain/channel.dart';
import 'package:bukanero/domain/series.dart';

void main() {
  _genericLogoTest();
  test('reconhece temporada e episódio no nome', () {
    final EpisodeInfo? a = parseEpisode('Rick and Morty The Anime S01E10');
    expect(a?.title, 'Rick and Morty The Anime');
    expect(a?.season, 1);
    expect(a?.episode, 10);
    expect(parseEpisode('Show - S02E03 - Titulo')?.title, 'Show');
    expect(parseEpisode('Filme Qualquer 2020'), isNull);
    expect(parseEpisode('S01E01'), isNull);
  });

  test('agrupa episódios em séries', () async {
    final Directory dir = Directory.systemTemp.createTempSync('bukanero');
    addTearDown(() => dir.deleteSync(recursive: true));
    final File m3u = File('${dir.path}/a.m3u')
      ..writeAsStringSync('''
#EXTM3U
#EXTINF:-1 tvg-logo="http://x/a.png" group-title="Series | A",Rick S01E02
http://s/series/u/p/2.mp4
#EXTINF:-1 tvg-logo="http://x/b.png" group-title="Series | A",Rick S01E01
http://s/series/u/p/1.mp4
#EXTINF:-1 group-title="Series | A",Rick S02E01
http://s/series/u/p/3.mp4
#EXTINF:-1 group-title="Series | B",Rick S01E01
http://s/series/u/p/4.mp4
#EXTINF:-1 group-title="Series | A",Documentario Solto
http://s/series/u/p/5.mp4
''');
    final String catPath = '${dir.path}/c.db';
    final String serPath = '${dir.path}/s.db';
    await importCatalog(m3u.path, catPath);
    await ensureSeriesIndex(catPath, serPath);
    await ensureSeriesIndex(catPath, serPath); // já atual: não reconstrói

    final SeriesDb db = SeriesDb.open(serPath);
    addTearDown(db.close);

    expect(db.groupCounts(), <String, int>{'Series | A': 2, 'Series | B': 1});

    final List<Channel> a = db.list('Series | A', '');
    expect(a.map((Channel c) => c.name), <String>[
      'Documentario Solto',
      'Rick',
    ]);
    expect(a[0].url, 'http://s/series/u/p/5.mp4');
    expect(a[1].url, '${seriesUrlPrefix}Rick');
    expect(a[1].logo, 'http://x/b.png');

    final List<Channel> g = db.search('rick');
    expect(g, hasLength(1));
    expect(g.first.group, 'Series | A');
    expect(
      db.search('rick', isHidden: (String grp, String t) => t == 'Rick'),
      isEmpty,
    );

    final List<Episode> eps = db.episodes('Rick');
    expect(eps.map((Episode e) => '${e.season}x${e.episode}'), <String>[
      '1x1',
      '1x2',
      '2x1',
    ]);
    expect(eps.first.url, 'http://s/series/u/p/1.mp4');
  });
}

void _genericLogoTest() {
  test('imagem de episódio repetida em outra série é ignorada', () async {
    final Directory dir = Directory.systemTemp.createTempSync('bukanero');
    addTearDown(() => dir.deleteSync(recursive: true));
    final File m3u = File('${dir.path}/a.m3u')
      ..writeAsStringSync('''
#EXTM3U
#EXTINF:-1 tvg-logo="http://s/generica.jpg" group-title="Series | A",Alfa S01E01
http://s/series/u/p/1.mp4
#EXTINF:-1 tvg-logo="http://s/alfa2.jpg" group-title="Series | A",Alfa S01E02
http://s/series/u/p/2.mp4
#EXTINF:-1 tvg-logo="http://s/generica.jpg" group-title="Series | A",Beta S01E01
http://s/series/u/p/3.mp4
''');
    final String catPath = '${dir.path}/c.db';
    final String serPath = '${dir.path}/s.db';
    await importCatalog(m3u.path, catPath);
    await ensureSeriesIndex(catPath, serPath);
    final SeriesDb db = SeriesDb.open(serPath);
    addTearDown(db.close);
    expect(db.episodes('Alfa').map((Episode e) => e.logo), <String?>[
      null,
      'http://s/alfa2.jpg',
    ]);
    expect(db.episodes('Beta').single.logo, isNull);
  });
}
