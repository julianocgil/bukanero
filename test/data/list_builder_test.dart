import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:bukanero/data/catalog_db.dart';
import 'package:bukanero/data/list_builder.dart';
import 'package:bukanero/data/user_data.dart';
import 'package:bukanero/domain/channel.dart';
import 'package:bukanero/domain/section.dart';
import 'package:bukanero/domain/sort_mode.dart';

void main() {
  late String dbPath;

  setUp(() async {
    final Directory dir = Directory.systemTemp.createTempSync('bukanero');
    addTearDown(() => dir.deleteSync(recursive: true));
    final File m3u = File('${dir.path}/a.m3u')
      ..writeAsStringSync('''
#EXTM3U
#EXTINF:-1 group-title="Filmes | A",Filme Um
http://s/movie/u/p/1.mp4
#EXTINF:-1 group-title="Filmes | B",Filme Dois
http://s/movie/u/p/2.mp4
#EXTINF:-1 group-title="Filmes | B",Filme Tres
http://s/movie/u/p/3.mp4
''');
    dbPath = '${dir.path}/c.db';
    await importCatalog(m3u.path, dbPath);
  });

  ListRequest req({
    String? group,
    Set<String> hiddenGroups = const <String>{},
    Set<String> hiddenItems = const <String>{},
    List<(String, String)>? favorites,
  }) => ListRequest(
    catalogPath: dbPath,
    section: Section.movies,
    group: group,
    query: '',
    sort: SortMode.listOrder,
    showHidden: false,
    hiddenGroups: hiddenGroups,
    hiddenItems: hiddenItems,
    allHidden: hiddenItems,
    favorites: favorites,
  );

  List<String> names(List<Channel> l) => <String>[
    for (final Channel c in l) c.name,
  ];

  test('todas as categorias, sem os ocultos', () async {
    final List<Channel> all = await buildListInBackground(
      req(
        hiddenGroups: <String>{'Filmes | A'},
        hiddenItems: <String>{hiddenKey('Filmes | B', 'Filme Dois')},
      ),
    );
    expect(names(all), <String>['Filme Tres']);
  });

  test('uma categoria e os favoritos', () async {
    expect(names(buildList(req(group: 'Filmes | B'))), <String>[
      'Filme Dois',
      'Filme Tres',
    ]);
    final List<Channel> favs = buildList(
      req(
        favorites: <(String, String)>[('http://s/movie/u/p/1.mp4', 'Filme Um')],
      ),
    );
    expect(names(favs), <String>['Filme Um']);
  });
}
