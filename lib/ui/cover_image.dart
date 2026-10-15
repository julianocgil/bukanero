import 'dart:io';

import 'package:flutter/material.dart';

import '../data/image_cache.dart';

/// Imagem da lista com cache em disco e um ícone enquanto carrega ou se falhar.
class CoverImage extends StatefulWidget {
  const CoverImage({
    required this.url,
    required this.icon,
    this.fit = BoxFit.cover,
    this.cacheWidth = 300,
    super.key,
  });

  final String? url;
  final IconData icon;
  final BoxFit fit;
  final int cacheWidth;

  @override
  State<CoverImage> createState() => _CoverImageState();
}

class _CoverImageState extends State<CoverImage> {
  Future<File?>? _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(CoverImage old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) _future = _load();
  }

  Future<File?>? _load() {
    final String? u = widget.url;
    return (u == null || u.isEmpty) ? null : cachedImage(u);
  }

  Widget _placeholder(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return ColoredBox(
      color: t.colorScheme.surfaceContainerHighest,
      child: Center(child: Icon(widget.icon, color: t.disabledColor)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Future<File?>? f = _future;
    if (f == null) return _placeholder(context);
    return FutureBuilder<File?>(
      future: f,
      builder: (BuildContext context, AsyncSnapshot<File?> snap) {
        final File? file = snap.data;
        if (file == null) return _placeholder(context);
        return Image.file(
          file,
          fit: widget.fit,
          cacheWidth: widget.cacheWidth,
          gaplessPlayback: true,
          errorBuilder: (BuildContext c, Object e, StackTrace? s) =>
              _placeholder(c),
        );
      },
    );
  }
}
