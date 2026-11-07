import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../data/series_info.dart';
import '../domain/channel.dart';
import '../domain/series.dart';
import 'cover_image.dart';

String _two(int n) => n.toString().padLeft(2, '0');

// Cartões pequenos, em páginas: quantas linhas e colunas couberem,
// numerados da esquerda para a direita.
const double _cardW = 190;
const double _cardH = 168;
const double _gap = 10;

/// Mostra capa, sinopse, temporadas e um carrossel de episódios.
/// Devolve o episódio escolhido.
///
/// [extra] (opcional) traz do servidor as imagens e sinopses de cada
/// episódio; enquanto não chega, ficam as imagens da própria lista.
Future<Channel?> showSeriesDialog(
  BuildContext context, {
  required String title,
  required String? cover,
  required List<Episode> episodes,
  String? lastUrl,
  String? plot,
  Future<SeriesExtra?>? extra,
}) {
  return showDialog<Channel>(
    context: context,
    builder: (BuildContext ctx) => _SeriesDialog(
      title: title,
      cover: cover,
      episodes: episodes,
      lastUrl: lastUrl,
      plot: plot,
      extra: extra,
    ),
  );
}

/// Nome do episódio sem o título da série e o "S01E02" da frente.
String episodeLabel(Episode e) {
  final RegExpMatch? m = RegExp(
    r'[Ss]\d{1,3}\s*[._-]?\s*[Ee]\d{1,4}(?!\d)[\s._:–-]*(.*)$',
  ).firstMatch(e.name);
  final String rest = (m?.group(1) ?? '').trim();
  return rest.isEmpty ? 'Episódio ${e.episode}' : rest;
}

String _duration(int secs) {
  final int min = (secs / 60).round();
  return min >= 60 ? '${min ~/ 60} h ${_two(min % 60)}' : '$min min';
}

class _SeriesDialog extends StatefulWidget {
  const _SeriesDialog({
    required this.title,
    required this.cover,
    required this.episodes,
    this.lastUrl,
    this.plot,
    this.extra,
  });

  final String title;
  final String? cover;
  final List<Episode> episodes;

  /// Último episódio assistido: abre na temporada dele e fica destacado.
  final String? lastUrl;
  final String? plot;
  final Future<SeriesExtra?>? extra;

  @override
  State<_SeriesDialog> createState() => _SeriesDialogState();
}

class _SeriesDialogState extends State<_SeriesDialog> {
  late final Map<int, List<Episode>> _seasons = _group();
  late int _season = _initialSeason();
  final PageController _pages = PageController();
  SeriesExtra? _extra;
  int _perPage = 1;
  int _pageCount = 1;
  int _pageNow = 0;
  bool _placed = false;
  bool _turning = false;

  @override
  void initState() {
    super.initState();
    widget.extra?.then((SeriesExtra? x) {
      if (mounted && x != null) setState(() => _extra = x);
    });
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Map<int, List<Episode>> _group() {
    final Map<int, List<Episode>> m = <int, List<Episode>>{};
    for (final Episode e in widget.episodes) {
      (m[e.season] ??= <Episode>[]).add(e);
    }
    return m;
  }

  int _initialSeason() {
    for (final Episode e in widget.episodes) {
      if (e.url == widget.lastUrl) return e.season;
    }
    return _seasons.isEmpty ? 0 : _seasons.keys.first;
  }

  /// Abre na página do último episódio assistido.
  void _goToLast() {
    if (!_pages.hasClients) return;
    final List<Episode> list = _seasons[_season] ?? const <Episode>[];
    final int i = list.indexWhere((Episode e) => e.url == widget.lastUrl);
    if (i > 0) _pages.jumpToPage(i ~/ _perPage);
  }

  Future<void> _turn(int dir) async {
    if (!_pages.hasClients || _turning) return;
    final int target = (_pageNow + dir).clamp(0, _pageCount - 1);
    if (target == _pageNow) return;
    _turning = true;
    await _pages.animateToPage(
      target,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
    _turning = false;
  }

  void _pick(Episode e) => Navigator.pop(
    context,
    Channel(
      name: '${widget.title} S${_two(e.season)}E${_two(e.episode)}',
      url: e.url,
      logo: e.logo,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final Size screen = MediaQuery.sizeOf(context);
    final List<Episode> list = _seasons[_season] ?? const <Episode>[];
    final String? plot = _extra?.plot ?? widget.plot;
    final String? backdrop = _extra?.backdrop;
    return Dialog(
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        width: (screen.width - 48).clamp(600, 1200),
        height: (screen.height - 48).clamp(480, 760),
        child: Stack(
          children: <Widget>[
            if (backdrop != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 280,
                // Imagem de fundo que some em direção aos episódios.
                child: ShaderMask(
                  shaderCallback: (Rect r) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Colors.black54, Colors.transparent],
                  ).createShader(r),
                  blendMode: BlendMode.dstIn,
                  child: CoverImage(
                    url: backdrop,
                    icon: Icons.image_outlined,
                    cacheWidth: 1200,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _header(t, plot),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[
                        for (final int s in _seasons.keys)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(
                                s == 0 ? 'Especiais' : 'Temporada $s',
                              ),
                              selected: s == _season,
                              onSelected: (bool _) {
                                setState(() {
                                  _season = s;
                                  _pageNow = 0;
                                });
                                if (_pages.hasClients) _pages.jumpToPage(0);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: _episodes(t, list)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(ThemeData t, String? plot) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 130,
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CoverImage(
                url: widget.cover,
                icon: Icons.movie_outlined,
                cacheWidth: 300,
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
                    child: Text(widget.title, style: t.textTheme.headlineSmall),
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
              if (plot != null) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  plot,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: t.textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _episodes(ThemeData t, List<Episode> list) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        const double arrows = 2 * 48;
        final double w = box.maxWidth - arrows;
        final double h = box.maxHeight - 28; // linha de "página x de y"
        final int cols = ((w + _gap) ~/ (_cardW + _gap)).clamp(1, 12);
        final int rows = ((h + _gap) ~/ (_cardH + _gap)).clamp(1, 6);
        _perPage = rows * cols;
        _pageCount = list.isEmpty ? 1 : (list.length / _perPage).ceil();
        if (!_placed) {
          _placed = true;
          WidgetsBinding.instance.addPostFrameCallback((_) => _goToLast());
        }
        final double cellH = (h - (rows - 1) * _gap) / rows;
        return Column(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  IconButton(
                    tooltip: 'Episódios anteriores',
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _pageNow > 0 ? () => _turn(-1) : null,
                  ),
                  Expanded(
                    // A roda do mouse vira a página.
                    child: Listener(
                      onPointerSignal: (PointerSignalEvent ev) {
                        if (ev is! PointerScrollEvent) return;
                        final double d = ev.scrollDelta.dy != 0
                            ? ev.scrollDelta.dy
                            : ev.scrollDelta.dx;
                        if (d != 0) _turn(d > 0 ? 1 : -1);
                      },
                      child: PageView.builder(
                        controller: _pages,
                        itemCount: _pageCount,
                        onPageChanged: (int p) => setState(() => _pageNow = p),
                        itemBuilder: (BuildContext context, int page) {
                          final int from = page * _perPage;
                          final int to = (from + _perPage).clamp(
                            0,
                            list.length,
                          );
                          return GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: cols,
                                  mainAxisExtent: cellH,
                                  mainAxisSpacing: _gap,
                                  crossAxisSpacing: _gap,
                                ),
                            itemCount: to - from,
                            itemBuilder: (BuildContext context, int i) =>
                                _episodeCard(t, list[from + i]),
                          );
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Próximos episódios',
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _pageNow < _pageCount - 1
                        ? () => _turn(1)
                        : null,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 28,
              child: Center(
                child: Text(
                  _pageCount > 1 ? 'Página ${_pageNow + 1} de $_pageCount' : '',
                  style: t.textTheme.bodySmall,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _episodeCard(ThemeData t, Episode e) {
    final EpisodeExtra? x = _extra?.of(e.season, e.episode);
    final bool last = e.url == widget.lastUrl;
    final int? secs = x?.durationSecs;
    Widget badge(String text, {Color? color}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color ?? Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    return SizedBox(
      width: _cardW,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: last
              ? BorderSide(color: t.colorScheme.primary, width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: () => _pick(e),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    // Sem imagem própria do episódio: a da série.
                    CoverImage(
                      url:
                          x?.image ??
                          e.logo ??
                          _extra?.backdrop ??
                          widget.cover,
                      icon: Icons.play_circle_outline,
                      cacheWidth: 380,
                    ),
                    Positioned(
                      top: 6,
                      left: 6,
                      child: badge('E${_two(e.episode)}'),
                    ),
                    if (secs != null)
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: badge(_duration(secs)),
                      ),
                    if (last)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: badge('Último', color: t.colorScheme.primary),
                      ),
                  ],
                ),
              ),
              // O texto ocupa o que sobrar da altura, sem estourar.
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        episodeLabel(e),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.textTheme.labelLarge,
                      ),
                      if (x?.plot != null)
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              x!.plot!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: t.textTheme.bodySmall,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
