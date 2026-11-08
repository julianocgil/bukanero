import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/epg.dart';
import '../domain/channel.dart';
import '../domain/section.dart';
import 'cover_image.dart';

const double _rowH = 60;
const double _chanW = 220;
const double _headerH = 32;
// Quantas horas cabem na largura da tela; o resto fica na rolagem.
const int _visibleHours = 3;
const int _spanHours = 12;

String _hhmm(int secs) {
  final DateTime t = DateTime.fromMillisecondsSinceEpoch(secs * 1000);
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(t.hour)}:${two(t.minute)}';
}

int _nowSecs() => DateTime.now().millisecondsSinceEpoch ~/ 1000;

class _GuideRow {
  const _GuideRow(this.channel, this.programmes);

  final Channel channel;
  final List<Programme> programmes;
}

/// Grade com a programação de vários canais ao mesmo tempo.
/// Devolve o canal escolhido para assistir.
Future<Channel?> showGuide(
  BuildContext context, {
  required List<Channel> channels,
  required EpgDb epg,
  String? group,
}) {
  return showDialog<Channel>(
    context: context,
    builder: (BuildContext ctx) => Dialog.fullscreen(
      child: _GuidePage(channels: channels, epg: epg, initialGroup: group),
    ),
  );
}

class _GuidePage extends StatefulWidget {
  const _GuidePage({
    required this.channels,
    required this.epg,
    this.initialGroup,
  });

  final List<Channel> channels;
  final EpgDb epg;
  final String? initialGroup;

  @override
  State<_GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<_GuidePage> {
  // Começa na meia hora anterior ao "agora", arredondada.
  late final int _start = (_nowSecs() ~/ 1800) * 1800 - 1800;
  late final int _end = _start + _spanHours * 3600;
  // Pixels por minuto, calculado pela largura disponível.
  double _px = 4;
  double get _width => _spanHours * 60 * _px;
  bool _placed = false;
  late final List<_GuideRow> _all = _load();
  late final List<String> _groups = _groupsOf(_all);
  late String? _group = _groups.contains(widget.initialGroup)
      ? widget.initialGroup
      : null;
  String _query = '';
  int _now = _nowSecs();
  Timer? _tick;
  final ScrollController _names = ScrollController();
  final ScrollController _grid = ScrollController();
  final ScrollController _horiz = ScrollController();

  @override
  void initState() {
    super.initState();
    _grid.addListener(() => _follow(_grid, _names));
    _names.addListener(() => _follow(_names, _grid));
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = _nowSecs());
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _names.dispose();
    _grid.dispose();
    _horiz.dispose();
    super.dispose();
  }

  void _follow(ScrollController from, ScrollController to) {
    if (to.hasClients && to.offset != from.offset) to.jumpTo(from.offset);
  }

  List<_GuideRow> _load() {
    final List<_GuideRow> rows = <_GuideRow>[];
    for (final Channel c in widget.channels) {
      // Cartão agrupado: pelo nome dele e, se não achar, por cada versão.
      String? ch = widget.epg.channelFor(c.tvgId, c.name);
      for (final ChannelVersion v in c.versions) {
        ch ??= widget.epg.channelFor(v.channel.tvgId, v.channel.name);
      }
      if (ch == null) continue;
      final List<Programme> p = widget.epg.programmes(ch, _start, _end);
      if (p.isNotEmpty) rows.add(_GuideRow(c, p));
    }
    return rows;
  }

  static List<String> _groupsOf(List<_GuideRow> rows) {
    final Set<String> s = <String>{
      for (final _GuideRow r in rows)
        if (r.channel.group != null) r.channel.group!,
    };
    return s.toList()..sort();
  }

  List<_GuideRow> get _visible {
    final String q = normalize(_query.trim());
    return <_GuideRow>[
      for (final _GuideRow r in _all)
        if ((_group == null || r.channel.group == _group) &&
            (q.isEmpty ||
                normalize(r.channel.name).contains(q) ||
                r.programmes.any(
                  (Programme p) => normalize(p.title).contains(q),
                )))
          r,
    ];
  }

  double _x(int secs) => (secs - _start) / 60 * _px;

  void _scrollBy(double minutes) {
    final double target = (_horiz.offset + minutes * _px).clamp(
      0,
      _horiz.position.maxScrollExtent,
    );
    _horiz.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _scrollToNow() {
    final double target = (_x(_now) - 15 * _px).clamp(
      0,
      _horiz.position.maxScrollExtent,
    );
    _horiz.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _details(Channel c, Programme p) async {
    final bool live = p.start <= _now && p.stop > _now;
    final bool? watch = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(p.title),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${c.name} · ${_hhmm(p.start)}–${_hhmm(p.stop)}',
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
              if (p.descr != null) ...<Widget>[
                const SizedBox(height: 12),
                Text(p.descr!),
              ],
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Fechar'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.play_arrow),
            label: Text(live ? 'Assistir agora' : 'Abrir o canal'),
          ),
        ],
      ),
    );
    if (watch == true && mounted) Navigator.pop(context, c);
  }

  @override
  Widget build(BuildContext context) {
    final List<_GuideRow> rows = _visible;
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: const Text('Guia de programação'),
        actions: <Widget>[
          SizedBox(
            width: 260,
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Canal ou programa',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (String v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(width: 12),
          DropdownButton<String?>(
            value: _group,
            hint: const Text('Todas as categorias'),
            onChanged: (String? g) => setState(() => _group = g),
            items: <DropdownMenuItem<String?>>[
              const DropdownMenuItem<String?>(
                child: Text('Todas as categorias'),
              ),
              for (final String g in _groups)
                DropdownMenuItem<String?>(value: g, child: Text(g)),
            ],
          ),
          const SizedBox(width: 12),
          IconButton(
            tooltip: 'Uma hora antes',
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _scrollBy(-60),
          ),
          TextButton(onPressed: _scrollToNow, child: const Text('Agora')),
          IconButton(
            tooltip: 'Uma hora depois',
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _scrollBy(60),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _all.isEmpty
          ? const Center(
              child: Text('Nenhum canal desta lista tem programação no guia.'),
            )
          : Row(
              children: <Widget>[
                SizedBox(width: _chanW, child: _channelColumn(rows)),
                const VerticalDivider(width: 1),
                Expanded(child: _timeline(rows)),
              ],
            ),
    );
  }

  Widget _channelColumn(List<_GuideRow> rows) {
    final ThemeData t = Theme.of(context);
    return Column(
      children: <Widget>[
        SizedBox(
          height: _headerH,
          child: Center(
            child: Text('${rows.length} canais', style: t.textTheme.bodySmall),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            controller: _names,
            itemExtent: _rowH,
            itemCount: rows.length,
            itemBuilder: (BuildContext context, int i) {
              final Channel c = rows[i].channel;
              return InkWell(
                onTap: () => Navigator.pop(context, c),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: CoverImage(
                            url: c.logo,
                            icon: Icons.tv,
                            fit: BoxFit.contain,
                            cacheWidth: 80,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          c.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: t.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _timeline(List<_GuideRow> rows) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        _px = math.max(2, box.maxWidth / (_visibleHours * 60));
        if (!_placed) {
          // Abre com o "agora" perto da esquerda.
          _placed = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_horiz.hasClients) return;
            _horiz.jumpTo(
              (_x(_now) - 15 * _px).clamp(0, _horiz.position.maxScrollExtent),
            );
          });
        }
        return _timelineBody(rows);
      },
    );
  }

  Widget _timelineBody(List<_GuideRow> rows) {
    final ThemeData t = Theme.of(context);
    final double nowX = _x(_now);
    return Scrollbar(
      controller: _horiz,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _horiz,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: _width,
          child: Column(
            children: <Widget>[
              SizedBox(height: _headerH, child: _header(t)),
              const Divider(height: 1),
              Expanded(
                child: Stack(
                  children: <Widget>[
                    ListView.builder(
                      controller: _grid,
                      itemExtent: _rowH,
                      itemCount: rows.length,
                      itemBuilder: (BuildContext context, int i) =>
                          _programRow(t, rows[i]),
                    ),
                    if (nowX >= 0 && nowX <= _width)
                      Positioned(
                        left: nowX - 1,
                        top: 0,
                        bottom: 0,
                        child: IgnorePointer(
                          child: Container(
                            width: 2,
                            color: t.colorScheme.error,
                          ),
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

  Widget _header(ThemeData t) {
    return Stack(
      children: <Widget>[
        for (int s = _start; s < _end; s += 1800)
          Positioned(
            left: _x(s) + 4,
            top: 8,
            child: Text(_hhmm(s), style: t.textTheme.labelMedium),
          ),
      ],
    );
  }

  Widget _programRow(ThemeData t, _GuideRow row) {
    return Stack(
      children: <Widget>[
        for (final Programme p in row.programmes)
          _programCell(t, row.channel, p),
      ],
    );
  }

  Widget _programCell(ThemeData t, Channel c, Programme p) {
    final int from = math.max(p.start, _start);
    final int to = math.min(p.stop, _end);
    final double left = _x(from);
    final double width = math.max(0, _x(to) - left - 2);
    final bool live = p.start <= _now && p.stop > _now;
    final bool past = p.stop <= _now;
    final Color bg = live
        ? t.colorScheme.primaryContainer
        : t.colorScheme.surfaceContainerHighest;
    final Color fg = live
        ? t.colorScheme.onPrimaryContainer
        : past
        ? t.disabledColor
        : t.colorScheme.onSurface;
    return Positioned(
      left: left,
      top: 3,
      bottom: 3,
      width: width,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _details(c, p),
          child: Tooltip(
            message: '${p.title}\n${_hhmm(p.start)}–${_hhmm(p.stop)}',
            waitDuration: const Duration(milliseconds: 600),
            // O texto acompanha a rolagem: se o começo do programa saiu da
            // tela, título e horário ficam grudados na borda esquerda.
            child: ListenableBuilder(
              listenable: _horiz,
              builder: (BuildContext context, Widget? text) {
                final double off = _horiz.hasClients ? _horiz.offset : 0;
                final double shift = (off - left).clamp(
                  0,
                  math.max(0, width - 90),
                );
                return Padding(
                  padding: EdgeInsets.fromLTRB(6 + shift, 4, 6, 4),
                  child: text,
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    p.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.textTheme.bodyMedium?.copyWith(
                      color: fg,
                      fontWeight: live ? FontWeight.w600 : null,
                    ),
                  ),
                  Text(
                    '${_hhmm(p.start)}–${_hhmm(p.stop)}',
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: t.textTheme.bodySmall?.copyWith(color: fg),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
