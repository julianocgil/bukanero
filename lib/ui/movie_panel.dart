import 'package:flutter/material.dart';

import '../data/series_info.dart';
import '../domain/channel.dart';
import 'cover_image.dart';

/// Detalhes do filme no espaço da lista (o vídeo continua ao lado): fundo,
/// pôster, nota, sinopse, elenco, versões e os botões Assistir e Favoritar.
class MoviePanel extends StatefulWidget {
  const MoviePanel({
    required this.movie,
    required this.extra,
    required this.preferred,
    required this.favorite,
    required this.onBack,
    required this.onPlay,
    required this.onToggleFavorite,
    super.key,
  });

  final Channel movie;
  final Future<MovieExtra?>? extra;

  /// Versão que abre se você não escolher outra (a sua preferida).
  final Channel preferred;
  final bool favorite;
  final VoidCallback onBack;

  /// Toca; [version] é nulo quando você não trocou a versão.
  final void Function(Channel? version) onPlay;
  final VoidCallback onToggleFavorite;

  @override
  State<MoviePanel> createState() => _MoviePanelState();
}

class _MoviePanelState extends State<MoviePanel> {
  MovieExtra? _extra;
  late bool _loading = widget.extra != null;
  late Channel _pick = widget.preferred;

  @override
  void initState() {
    super.initState();
    widget.extra?.then((MovieExtra? x) {
      if (mounted) {
        setState(() {
          _extra = x;
          _loading = false;
        });
      }
    });
  }

  static String _duration(int secs) {
    final int min = (secs / 60).round();
    return min >= 60
        ? '${min ~/ 60} h ${(min % 60).toString().padLeft(2, '0')}'
        : '$min min';
  }

  static String _rating(double r) =>
      (r == r.roundToDouble() ? r.toStringAsFixed(0) : r.toStringAsFixed(1))
          .replaceAll('.', ',');

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final Channel m = widget.movie;
    final MovieExtra? x = _extra;
    final List<String> facts = <String>[
      if (x?.year != null) x!.year!,
      if (x?.durationSecs != null) _duration(x!.durationSecs!),
      if (x?.genre != null) x!.genre!,
    ];
    return Stack(
      children: <Widget>[
        if (x?.backdrop != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 240,
            // Fundo que some em direção ao texto.
            child: ShaderMask(
              shaderCallback: (Rect r) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Colors.black54, Colors.transparent],
              ).createShader(r),
              blendMode: BlendMode.dstIn,
              child: CoverImage(
                url: x!.backdrop,
                icon: Icons.image_outlined,
                cacheWidth: 900,
              ),
            ),
          ),
        ListView(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonalIcon(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Voltar'),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 120,
                  child: AspectRatio(
                    aspectRatio: 2 / 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CoverImage(
                        url: m.logo,
                        icon: Icons.movie_outlined,
                        cacheWidth: 300,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(m.name, style: t.textTheme.headlineSmall),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 10,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          if (m.rating != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Icon(
                                  Icons.star_rounded,
                                  size: 18,
                                  color: Color(0xFFFFC107),
                                ),
                                const SizedBox(width: 2),
                                Text(_rating(m.rating!)),
                              ],
                            ),
                          for (final String f in facts)
                            Text(
                              f,
                              style: t.textTheme.bodySmall?.copyWith(
                                color: t.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[
                          FilledButton.icon(
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Assistir'),
                            onPressed: () => widget.onPlay(
                              identical(_pick, widget.preferred) ? null : _pick,
                            ),
                          ),
                          OutlinedButton.icon(
                            icon: Icon(
                              widget.favorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: widget.favorite ? Colors.redAccent : null,
                            ),
                            label: Text(
                              widget.favorite ? 'Favorito' : 'Favoritar',
                            ),
                            onPressed: widget.onToggleFavorite,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (m.isGroup) ...<Widget>[
              const SizedBox(height: 16),
              Text('Versões', style: t.textTheme.titleSmall),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: <Widget>[
                  for (final ChannelVersion v in m.versions)
                    ChoiceChip(
                      label: Text(v.label),
                      selected: v.channel.url == _pick.url,
                      onSelected: (_) => setState(() => _pick = v.channel),
                    ),
                ],
              ),
            ],
            if (x?.plot != null) ...<Widget>[
              const SizedBox(height: 16),
              Text(x!.plot!, style: t.textTheme.bodyMedium),
            ],
            if (x?.director != null || x?.cast != null) ...<Widget>[
              const SizedBox(height: 12),
              if (x?.director != null)
                Text('Direção: ${x!.director}', style: t.textTheme.bodySmall),
              if (x?.cast != null)
                Text('Elenco: ${x!.cast}', style: t.textTheme.bodySmall),
            ],
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: LinearProgressIndicator(minHeight: 2),
              ),
          ],
        ),
      ],
    );
  }
}
