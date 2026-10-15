import 'package:flutter/material.dart';

import '../data/epg.dart';
import '../domain/channel.dart';
import 'cover_image.dart';

/// Menu ⋮ para ocultar ou reexibir um item ou uma categoria.
class HideMenu extends StatelessWidget {
  const HideMenu({required this.hidden, required this.onToggle, super.key});

  final bool hidden;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      tooltip: 'Opções',
      iconSize: 20,
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.more_vert),
      onSelected: (int _) => onToggle(),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
        PopupMenuItem<int>(
          value: 0,
          child: Row(
            children: <Widget>[
              Icon(hidden ? Icons.visibility : Icons.visibility_off, size: 18),
              const SizedBox(width: 8),
              Text(hidden ? 'Reexibir' : 'Ocultar'),
            ],
          ),
        ),
      ],
    );
  }
}

/// Cartão de canal ao vivo: logo pequeno, nome e programa atual do guia.
class LiveTile extends StatelessWidget {
  const LiveTile({
    required this.channel,
    required this.selected,
    required this.hidden,
    required this.nowSecs,
    required this.onTap,
    required this.onToggleHidden,
    this.current,
    super.key,
  });

  final Channel channel;
  final bool selected;
  final bool hidden;
  final int nowSecs;
  final Programme? current;
  final VoidCallback onTap;
  final VoidCallback onToggleHidden;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final Programme? cur = current;
    final double? progress = (cur != null && cur.stop > cur.start)
        ? ((nowSecs - cur.start) / (cur.stop - cur.start)).clamp(0.0, 1.0)
        : null;
    final TextStyle? nameStyle = hidden
        ? t.textTheme.titleSmall?.copyWith(
            decoration: TextDecoration.lineThrough,
            color: t.disabledColor,
          )
        : t.textTheme.titleSmall;

    return Opacity(
      opacity: hidden ? 0.5 : 1,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        color: selected ? t.colorScheme.primaryContainer : null,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 48,
                  height: 48,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CoverImage(
                      url: channel.logo,
                      icon: Icons.tv,
                      fit: BoxFit.contain,
                      cacheWidth: 96,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        channel.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: nameStyle,
                      ),
                      if (cur != null) ...<Widget>[
                        const SizedBox(height: 2),
                        Text(
                          cur.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.textTheme.bodySmall,
                        ),
                        if (progress != null) ...<Widget>[
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 3,
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                HideMenu(hidden: hidden, onToggle: onToggleHidden),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Cartão de filme ou série: capa em destaque e título.
class PosterCard extends StatelessWidget {
  const PosterCard({
    required this.channel,
    required this.selected,
    required this.hidden,
    required this.onTap,
    required this.onToggleHidden,
    super.key,
  });

  final Channel channel;
  final bool selected;
  final bool hidden;
  final VoidCallback onTap;
  final VoidCallback onToggleHidden;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return Opacity(
      opacity: hidden ? 0.4 : 1,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: selected
              ? BorderSide(color: t.colorScheme.primary, width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    CoverImage(url: channel.logo, icon: Icons.movie_outlined),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                          ),
                        ),
                        child: HideMenu(
                          hidden: hidden,
                          onToggle: onToggleHidden,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  channel.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: t.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
