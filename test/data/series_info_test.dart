import 'package:bukanero/data/series_info.dart';
import 'package:bukanero/domain/series.dart';
import 'package:bukanero/ui/series_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('episódios num mapa por temporada', () {
    final SeriesExtra x = parseSeriesInfo(<String, dynamic>{
      'info': <String, dynamic>{
        'plot': 'Uma série fictícia.',
        'backdrop_path': <Object?>['http://s/fundo.jpg'],
      },
      'episodes': <String, dynamic>{
        '1': <Object?>[
          <String, dynamic>{
            'season': 1,
            'episode_num': '2',
            'info': <String, dynamic>{
              'movie_image': 'http://s/e2.jpg',
              'plot': 'O segundo.',
              'duration': '00:42:10',
              'rating': '7.5',
            },
          },
        ],
      },
    });
    expect(x.plot, 'Uma série fictícia.');
    expect(x.backdrop, 'http://s/fundo.jpg');
    final EpisodeExtra? e = x.of(1, 2);
    expect(e?.image, 'http://s/e2.jpg');
    expect(e?.plot, 'O segundo.');
    expect(e?.durationSecs, 42 * 60 + 10);
    expect(e?.rating, 7.5);
    expect(x.of(1, 1), isNull);
  });

  test('episódios em lista de listas e campos estranhos', () {
    final SeriesExtra x = parseSeriesInfo(<String, dynamic>{
      'info': <Object?>[],
      'episodes': <Object?>[
        <Object?>[
          <String, dynamic>{
            'season': '2',
            'episode_num': 1,
            'info': <Object?>[], // alguns servidores mandam lista vazia
          },
          'lixo',
          <String, dynamic>{'season': 2},
        ],
      ],
    });
    expect(x.plot, isNull);
    expect(x.episodes.keys, <int>[20001]);
    expect(x.of(2, 1)?.image, isNull);
    expect(parseSeriesInfo('nada').episodes, isEmpty);
  });

  test('nome do episódio sem a série e o SxxExx', () {
    Episode ep(String name) =>
        Episode(name: name, url: 'u', season: 1, episode: 3);
    expect(episodeLabel(ep('Série X S01E03 - O Começo')), 'O Começo');
    expect(episodeLabel(ep('Série X S01E03')), 'Episódio 3');
    expect(episodeLabel(ep('Outra coisa')), 'Episódio 3');
  });
}
