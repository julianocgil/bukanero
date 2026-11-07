import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meu_iptv/data/catalog_db.dart';
import 'package:meu_iptv/data/series_db.dart';
import 'package:meu_iptv/domain/channel.dart';
import 'package:meu_iptv/domain/section.dart';
import 'package:meu_iptv/domain/sort_mode.dart';

List<String> _names(List<Channel> l) => l.map((Channel c) => c.name).toList();

void main() {
  test('ordenação de filmes', () async {
    final Directory dir = Directory.systemTemp.createTempSync('meuiptv');
    addTearDown(() => dir.deleteSync(recursive: true));
    final File m3u = File('${dir.path}/a.m3u')
      ..writeAsStringSync('''
#EXTM3U
#EXTINF:-1 group-title="Filmes | A",Zebra
http://s/movie/u/p/1.mp4
#EXTINF:-1 group-title="Filmes | A",Ágata
http://s/movie/u/p/2.mp4
#EXTINF:-1 group-title="Filmes | A",banana
http://s/movie/u/p/3.mp4
#EXTINF:-1 group-title="Filmes | A",Abacaxi
http://s/movie/u/p/4.mp4
''');
    final String dbPath = '${dir.path}/c.db';
    await importCatalog(m3u.path, dbPath);
    final CatalogDb db = CatalogDb.open(dbPath);
    addTearDown(db.close);

    List<String> items() => _names(db.items(Section.movies, 'Filmes | A', ''));

    db.sort = SortMode.listOrder;
    expect(items(), <String>['Zebra', 'Ágata', 'banana', 'Abacaxi']);
    db.sort = SortMode.listOrderReverse;
    expect(items(), <String>['Abacaxi', 'banana', 'Ágata', 'Zebra']);
    db.sort = SortMode.nameAsc;
    expect(items(), <String>['Abacaxi', 'Ágata', 'banana', 'Zebra']);
    db.sort = SortMode.nameDesc;
    expect(items(), <String>['Zebra', 'banana', 'Ágata', 'Abacaxi']);

    db.sort = SortMode.nameAsc;
    expect(_names(db.search(Section.movies, 'a')), <String>[
      'Abacaxi',
      'Ágata',
      'banana',
      'Zebra',
    ]);
  });

  test('ordenação de séries', () async {
    final Directory dir = Directory.systemTemp.createTempSync('meuiptv');
    addTearDown(() => dir.deleteSync(recursive: true));
    final File m3u = File('${dir.path}/a.m3u')
      ..writeAsStringSync('''
#EXTM3U
#EXTINF:-1 group-title="Series | A",Zeta S01E01
http://s/series/u/p/1.mp4
#EXTINF:-1 group-title="Series | A",Zeta S01E02
http://s/series/u/p/2.mp4
#EXTINF:-1 group-title="Series | A",Alfa S01E01
http://s/series/u/p/3.mp4
#EXTINF:-1 group-title="Series | A",Alfa S01E02
http://s/series/u/p/4.mp4
#EXTINF:-1 group-title="Series | A",Mike S01E01
http://s/series/u/p/5.mp4
#EXTINF:-1 group-title="Series | A",Mike S01E02
http://s/series/u/p/6.mp4
''');
    final String catPath = '${dir.path}/c.db';
    final String serPath = '${dir.path}/s.db';
    await importCatalog(m3u.path, catPath);
    await ensureSeriesIndex(catPath, serPath);
    final SeriesDb db = SeriesDb.open(serPath);
    addTearDown(db.close);

    List<String> inGroup() => _names(db.list('Series | A', ''));

    db.sort = SortMode.listOrder;
    expect(inGroup(), <String>['Zeta', 'Alfa', 'Mike']);
    db.sort = SortMode.listOrderReverse;
    expect(inGroup(), <String>['Mike', 'Alfa', 'Zeta']);
    db.sort = SortMode.nameAsc;
    expect(inGroup(), <String>['Alfa', 'Mike', 'Zeta']);
    db.sort = SortMode.nameDesc;
    expect(inGroup(), <String>['Zeta', 'Mike', 'Alfa']);

    db.sort = SortMode.listOrder;
    expect(_names(db.search('')), <String>['Zeta', 'Alfa', 'Mike']);
    db.sort = SortMode.nameDesc;
    expect(_names(db.search('')), <String>['Zeta', 'Mike', 'Alfa']);
  });
}
