/// Prefixo do endereço de um cartão que representa uma série inteira.
const String seriesUrlPrefix = 'series://';

class EpisodeInfo {
  const EpisodeInfo(this.title, this.season, this.episode);

  final String title;
  final int season;
  final int episode;
}

class Episode {
  const Episode({
    required this.name,
    required this.url,
    required this.season,
    required this.episode,
    this.logo,
  });

  final String name;
  final String url;
  final int season;
  final int episode;
  final String? logo;
}

final RegExp _sxe = RegExp(
  r'^(.*?)[\s._-]*[Ss](\d{1,3})\s*[._-]?\s*[Ee](\d{1,4})(?!\d)',
);

/// Lê "Nome da Série S01E02" e devolve título, temporada e episódio.
EpisodeInfo? parseEpisode(String name) {
  final RegExpMatch? m = _sxe.firstMatch(name.trim());
  if (m == null) return null;
  final String title = m.group(1)!.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (title.isEmpty) return null;
  return EpisodeInfo(title, int.parse(m.group(2)!), int.parse(m.group(3)!));
}
