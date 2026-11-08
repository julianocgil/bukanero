import 'dart:io';

import 'package:bukanero/data/user_data.dart';
import 'package:bukanero/domain/channel.dart';
import 'package:bukanero/domain/section.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;
  late UserData u;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('bukanero');
    u = UserData.open('${dir.path}/u.db');
  });
  tearDown(() {
    u.close();
    dir.deleteSync(recursive: true);
  });

  test('preferência é guardada e trocada', () {
    expect(u.pref('sort.movies'), isNull);
    u.setPref('sort.movies', 'rating');
    u.setPref('sort.movies', 'year');
    expect(u.pref('sort.movies'), 'year');
  });

  test('recentes: mais novo primeiro, sem repetir, por seção', () {
    const Channel a = Channel(name: 'A', url: 'http://s/a.mp4', group: 'G');
    const Channel b = Channel(name: 'B', url: 'http://s/b.mp4', logo: 'x');
    u.addRecent(Section.movies, a);
    u.addRecent(Section.movies, b);
    u.addRecent(Section.movies, a);
    u.addRecent(Section.series, b);
    expect(u.recent(Section.movies).map((Channel c) => c.name), <String>[
      'A',
      'B',
    ]);
    expect(u.recent(Section.movies).first.group, 'G');
    expect(u.recent(Section.series).single.logo, 'x');

    u.removeRecent(Section.movies, a.url);
    expect(u.recent(Section.movies).map((Channel c) => c.name), <String>['B']);
    expect(u.recent(Section.series), hasLength(1));
  });

  test('recentes guarda só os últimos', () {
    for (int i = 0; i < 5; i++) {
      u.addRecent(
        Section.movies,
        Channel(name: '$i', url: 'http://s/$i.mp4'),
        keep: 3,
      );
    }
    expect(u.recent(Section.movies).map((Channel c) => c.name), <String>[
      '4',
      '3',
      '2',
    ]);
  });

  test('favoritos: marca, lista do mais novo, desmarca, por seção', () {
    const Channel a = Channel(name: 'A', url: 'http://s/a.mp4');
    const Channel b = Channel(name: 'B', url: 'series://B');
    u.setFavorite(Section.movies, a, favorite: true);
    u.setFavorite(Section.series, b, favorite: true);
    expect(u.favorites(Section.movies), <String>{'http://s/a.mp4'});
    expect(u.favoriteList(Section.series), <(String, String)>[
      ('series://B', 'B'),
    ]);
    u.setFavorite(Section.movies, a, favorite: false);
    expect(u.favorites(Section.movies), isEmpty);
    expect(u.favorites(Section.series), hasLength(1));
  });
}
