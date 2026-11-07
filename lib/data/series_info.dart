import 'dart:convert';
import 'dart:io';

import 'download.dart';
import 'metadata.dart';
import 'profile_store.dart';

/// Detalhes de um episódio vindos do servidor (`get_series_info`).
class EpisodeExtra {
  const EpisodeExtra({this.image, this.plot, this.durationSecs, this.rating});

  final String? image;
  final String? plot;
  final int? durationSecs;
  final double? rating;
}

/// Detalhes de uma série: sinopse, imagem de fundo e os episódios.
class SeriesExtra {
  const SeriesExtra({this.plot, this.backdrop, this.episodes = const {}});

  final String? plot;
  final String? backdrop;

  /// Chave: temporada * 10000 + episódio.
  final Map<int, EpisodeExtra> episodes;

  EpisodeExtra? of(int season, int episode) =>
      episodes[season * 10000 + episode];
}

String? _image(Object? v) {
  if (v is List<Object?>) return v.isEmpty ? null : _image(v.first);
  final String t = (v ?? '').toString().trim();
  return (t.startsWith('http://') || t.startsWith('https://')) ? t : null;
}

String? _text(Object? v) {
  final String t = (v ?? '').toString().trim();
  return t.isEmpty ? null : t;
}

int? _int(Object? v) {
  final int? i = int.tryParse((v ?? '').toString().trim());
  return (i == null || i <= 0) ? null : i;
}

double? _num(Object? v) {
  final double? d = double.tryParse((v ?? '').toString().trim());
  return (d == null || d <= 0) ? null : d;
}

/// Converte "00:42:10" em segundos.
int? _hms(Object? v) {
  final List<String> p = (v ?? '').toString().trim().split(':');
  if (p.length != 3) return null;
  final List<int?> n = p.map(int.tryParse).toList();
  if (n.contains(null)) return null;
  final int s = n[0]! * 3600 + n[1]! * 60 + n[2]!;
  return s > 0 ? s : null;
}

/// Lê a resposta de `get_series_info`. Os servidores variam: os episódios
/// podem vir num mapa por temporada ou numa lista de listas.
SeriesExtra parseSeriesInfo(Object? json) {
  if (json is! Map<String, dynamic>) return const SeriesExtra();
  final Object? info = json['info'];
  String? plot;
  String? backdrop;
  if (info is Map<String, dynamic>) {
    plot = _text(info['plot'] ?? info['description']);
    backdrop = _image(info['backdrop_path']);
  }
  final List<Object?> lists = <Object?>[];
  final Object? eps = json['episodes'];
  if (eps is Map<String, dynamic>) {
    lists.addAll(eps.values);
  } else if (eps is List<Object?>) {
    lists.addAll(eps);
  }
  final Map<int, EpisodeExtra> out = <int, EpisodeExtra>{};
  for (final Object? l in lists) {
    if (l is! List<Object?>) continue;
    for (final Object? e in l) {
      if (e is! Map<String, dynamic>) continue;
      final int? season = _int(e['season']);
      final int? number = _int(e['episode_num']);
      if (season == null || number == null) continue;
      final Object? ei = e['info'];
      final Map<String, dynamic> m = ei is Map<String, dynamic>
          ? ei
          : const <String, dynamic>{};
      out[season * 10000 + number] = EpisodeExtra(
        image: _image(m['movie_image'] ?? m['cover_big']),
        plot: _text(m['plot']),
        durationSecs: _int(m['duration_secs']) ?? _hms(m['duration']),
        rating: _num(m['rating']),
      );
    }
  }
  return SeriesExtra(plot: plot, backdrop: backdrop, episodes: out);
}

final Map<int, SeriesExtra> _cache = <int, SeriesExtra>{};

/// Busca os detalhes da série no próprio servidor da lista (uma vez por
/// série enquanto o app está aberto). Devolve null se não der.
Future<SeriesExtra?> fetchSeriesInfo(
  ApiAccess api,
  int seriesId, {
  bool allowInsecure = false,
}) async {
  final SeriesExtra? hit = _cache[seriesId];
  if (hit != null) return hit;
  final File f = File('${dataDir().path}/series_info_$seriesId.json');
  try {
    await downloadFile(
      apiUri(api, 'get_series_info', <String, String>{
        'series_id': '$seriesId',
      }).toString(),
      f,
      allowInsecure: allowInsecure,
    );
    final SeriesExtra x = parseSeriesInfo(
      jsonDecode(utf8.decode(await f.readAsBytes(), allowMalformed: true)),
    );
    _cache[seriesId] = x;
    return x;
  } on DownloadException {
    return null;
  } on FormatException {
    return null;
  } finally {
    if (f.existsSync()) f.deleteSync();
  }
}
