import 'package:flutter/material.dart';

import '../data/epg.dart';
import '../domain/channel.dart';
import 'cover_image.dart';

/// Menu ⋮ para ocultar ou reexibir um item ou uma categoria.
class HideMenu extends StatelessWidget {
  const HideMenu({
    required this.hidden,
    required this.onToggle,
    this.onRegroup,
    super.key,
  });

  final bool hidden;
  final VoidCallback onToggle;

  /// Item que veio de um grupo separado: oferece juntar as versões de novo.
  final VoidCallback? onRegroup;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      tooltip: 'Opções',
      iconSize: 20,
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.more_vert),
      onSelected: (int v) => v == 1 ? onRegroup?.call() : onToggle(),
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
        if (onRegroup != null)
          const PopupMenuItem<int>(
            value: 1,
            child: Row(
              children: <Widget>[
                Icon(Icons.merge_type, size: 18),
                SizedBox(width: 8),
                Text('Juntar as versões de novo'),
              ],
            ),
          ),
      ],
    );
  }
}

/// Coração para favoritar um cartão.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    required this.favorite,
    required this.onToggle,
    this.overlay = false,
    super.key,
  });

  final bool favorite;
  final VoidCallback onToggle;

  /// Sobre a capa (fundo escuro).
  final bool overlay;

  @override
  Widget build(BuildContext context) {
    final Widget button = IconButton(
      tooltip: favorite ? 'Tirar dos favoritos' : 'Favoritar',
      iconSize: 18,
      visualDensity: VisualDensity.compact,
      color: favorite
          ? Colors.redAccent
          : (overlay ? Colors.white : Theme.of(context).disabledColor),
      icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
      onPressed: onToggle,
    );
    if (!overlay) return button;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
      ),
      child: button,
    );
  }
}

/// Etiqueta "3 versões" de um cartão agrupado: abre a lista para escolher
/// qual tocar, e a opção de separar o grupo.
class VersionsMenu extends StatelessWidget {
  const VersionsMenu({
    required this.channel,
    required this.onPick,
    required this.onSeparate,
    this.overlay = false,
    this.chosen,
    super.key,
  });

  final Channel channel;
  final void Function(Channel version) onPick;
  final VoidCallback onSeparate;

  /// Nome da versão que o usuário escolheu por último (abre nela).
  final String? chosen;

  /// Sobre a capa (fundo escuro) em vez de no meio do texto.
  final bool overlay;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final Color fg = overlay
        ? Colors.white
        : t.colorScheme.onSecondaryContainer;
    return PopupMenuButton<int>(
      tooltip: 'Escolher a versão',
      onSelected: (int i) =>
          i < 0 ? onSeparate() : onPick(channel.versions[i].channel),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
        for (int i = 0; i < channel.versions.length; i++)
          PopupMenuItem<int>(
            value: i,
            child: Row(
              children: <Widget>[
                const Icon(Icons.play_arrow, size: 18),
                const SizedBox(width: 8),
                Text(channel.versions[i].label),
                if (channel.versions[i].channel.name == chosen) ...<Widget>[
                  const SizedBox(width: 8),
                  Text('(sua preferência)', style: t.textTheme.bodySmall),
                ] else if (i == 0 && chosen == null) ...<Widget>[
                  const SizedBox(width: 8),
                  Text('(automática)', style: t.textTheme.bodySmall),
                ],
              ],
            ),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem<int>(
          value: -1,
          child: Row(
            children: <Widget>[
              Icon(Icons.call_split, size: 18),
              SizedBox(width: 8),
              Text('Separar este grupo'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: overlay
              ? Colors.black.withValues(alpha: 0.7)
              : t.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.layers_outlined, size: 14, color: fg),
            const SizedBox(width: 3),
            Text(
              '${channel.versions.length}',
              style: TextStyle(
                color: fg,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(Icons.arrow_drop_down, size: 16, color: fg),
          ],
        ),
      ),
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
    this.onPickVersion,
    this.onSeparate,
    this.chosenVersion,
    this.favorite = false,
    this.onToggleFavorite,
    this.onRegroup,
    super.key,
  });

  final Channel channel;
  final bool selected;
  final bool hidden;
  final int nowSecs;
  final VoidCallback? onRegroup;
  final String? chosenVersion;
  final bool favorite;
  final VoidCallback? onToggleFavorite;
  final Programme? current;
  final VoidCallback onTap;
  final VoidCallback onToggleHidden;
  final void Function(Channel version)? onPickVersion;
  final VoidCallback? onSeparate;

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
                if (onToggleFavorite != null)
                  FavoriteButton(
                    favorite: favorite,
                    onToggle: onToggleFavorite!,
                  ),
                if (channel.isGroup &&
                    onPickVersion != null &&
                    onSeparate != null)
                  VersionsMenu(
                    channel: channel,
                    onPick: onPickVersion!,
                    onSeparate: onSeparate!,
                    chosen: chosenVersion,
                  ),
                HideMenu(
                  hidden: hidden,
                  onToggle: onToggleHidden,
                  onRegroup: onRegroup,
                ),
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
    this.onRemove,
    this.onPickVersion,
    this.onSeparate,
    this.chosenVersion,
    this.favorite = false,
    this.onToggleFavorite,
    this.onRegroup,
    super.key,
  });

  final Channel channel;
  final bool selected;
  final bool hidden;
  final bool favorite;
  final VoidCallback? onRegroup;
  final VoidCallback? onToggleFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleHidden;

  /// Com ele, o canto mostra um X (tirar dos recentes) no lugar do menu.
  final VoidCallback? onRemove;
  final void Function(Channel version)? onPickVersion;
  final VoidCallback? onSeparate;
  final String? chosenVersion;

  static String _fmtRating(double r) =>
      (r == r.roundToDouble() ? r.toStringAsFixed(0) : r.toStringAsFixed(1))
          .replaceAll('.', ',');

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
                    if (channel.rating != null)
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: Color(0xFFFFC107),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                _fmtRating(channel.rating!),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (onToggleFavorite != null)
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: FavoriteButton(
                          favorite: favorite,
                          onToggle: onToggleFavorite!,
                          overlay: true,
                        ),
                      ),
                    if (channel.isGroup &&
                        onPickVersion != null &&
                        onSeparate != null)
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: VersionsMenu(
                          channel: channel,
                          onPick: onPickVersion!,
                          onSeparate: onSeparate!,
                          overlay: true,
                          chosen: chosenVersion,
                        ),
                      ),
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
                        child: onRemove != null
                            ? IconButton(
                                tooltip: 'Tirar dos recentes',
                                iconSize: 18,
                                visualDensity: VisualDensity.compact,
                                color: Colors.white,
                                icon: const Icon(Icons.close),
                                onPressed: onRemove,
                              )
                            : HideMenu(
                                hidden: hidden,
                                onToggle: onToggleHidden,
                                onRegroup: onRegroup,
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
