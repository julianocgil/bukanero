import 'package:flutter/material.dart';

import '../domain/channel.dart';
import '../domain/series.dart';
import 'cover_image.dart';

String _two(int n) => n.toString().padLeft(2, '0');

/// Mostra capa, temporadas e episódios. Devolve o episódio escolhido.
Future<Channel?> showSeriesDialog(
  BuildContext context, {
  required String title,
  required String? cover,
  required List<Episode> episodes,
}) {
  return showDialog<Channel>(
    context: context,
    builder: (BuildContext ctx) =>
        _SeriesDialog(title: title, cover: cover, episodes: episodes),
  );
}

class _SeriesDialog extends StatefulWidget {
  const _SeriesDialog({
    required this.title,
    required this.cover,
    required this.episodes,
  });

  final String title;
  final String? cover;
  final List<Episode> episodes;

  @override
  State<_SeriesDialog> createState() => _SeriesDialogState();
}

class _SeriesDialogState extends State<_SeriesDialog> {
  late final Map<int, List<Episode>> _seasons = _group();
  late int _season = _seasons.isEmpty ? 0 : _seasons.keys.first;

  Map<int, List<Episode>> _group() {
    final Map<int, List<Episode>> m = <int, List<Episode>>{};
    for (final Episode e in widget.episodes) {
      (m[e.season] ??= <Episode>[]).add(e);
    }
    return m;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final List<Episode> list = _seasons[_season] ?? const <Episode>[];
    return Dialog(
      child: SizedBox(
        width: 820,
        height: 560,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 200,
                child: AspectRatio(
                  aspectRatio: 2 / 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CoverImage(
                      url: widget.cover,
                      icon: Icons.movie_outlined,
                      cacheWidth: 400,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            widget.title,
                            style: t.textTheme.headlineSmall,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Fechar',
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    Text(
                      '${_seasons.length} temporada(s) · '
                      '${widget.episodes.length} episódio(s)',
                      style: t.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: <Widget>[
                        for (final int s in _seasons.keys)
                          ChoiceChip(
                            label: Text(s == 0 ? 'Especiais' : 'Temporada $s'),
                            selected: s == _season,
                            onSelected: (bool _) => setState(() => _season = s),
                          ),
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (BuildContext context, int i) {
                          final Episode e = list[i];
                          return ListTile(
                            dense: true,
                            leading: SizedBox(
                              width: 44,
                              child: Text(
                                'E${_two(e.episode)}',
                                style: t.textTheme.titleSmall,
                              ),
                            ),
                            title: Text(
                              e.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(Icons.play_arrow),
                            onTap: () => Navigator.pop(
                              context,
                              Channel(
                                name:
                                    '${widget.title} '
                                    'S${_two(e.season)}E${_two(e.episode)}',
                                url: e.url,
                                logo: e.logo,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
