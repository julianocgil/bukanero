import 'package:flutter_test/flutter_test.dart';
import 'package:bukanero/domain/channel.dart';
import 'package:bukanero/domain/section.dart';

Channel _c(String group, [String url = 'http://s/1']) =>
    Channel(name: 'x', url: url, group: group);

void main() {
  test('canal ao vivo mesmo com Filmes e Séries no nome', () {
    expect(classify(_c('Canais | Filmes e Séries')), Section.live);
  });

  test('séries e novelas', () {
    expect(classify(_c('Series | Netflix')), Section.series);
    expect(classify(_c('Novelas')), Section.series);
  });

  test('filmes', () {
    expect(classify(_c('Filmes | Legendados')), Section.movies);
  });

  test('URL tem prioridade sobre a categoria', () {
    expect(
      classify(_c('Qualquer', 'http://s/movie/u/p/1.mp4')),
      Section.movies,
    );
    expect(
      classify(_c('Qualquer', 'http://s/series/u/p/1.mkv')),
      Section.series,
    );
  });

  test('categoria adulta', () {
    expect(isAdultGroup('Filmes | [XXX] Adultos'), isTrue);
    expect(isAdultGroup('Series | Netflix'), isFalse);
  });
}
