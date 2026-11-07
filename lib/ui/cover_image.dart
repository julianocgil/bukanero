import 'dart:io';

import 'package:flutter/material.dart';

import '../data/image_cache.dart';

/// Imagem da lista com cache em disco.
///
/// Ao trocar o endereço, volta na hora para o ícone padrão (nunca mostra a
/// imagem de outro item) e tenta de novo se o download falhar.
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
  File? _file;
  bool _loading = false;
  bool _purged = false;
  int _gen = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(CoverImage old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) {
      _purged = false;
      _start();
    }
  }

  @override
  void dispose() {
    _gen++; // invalida downloads em andamento deste cartão
    super.dispose();
  }

  void _start({bool force = false, int attempt = 0}) {
    final int gen = ++_gen;
    _file = null;
    final String? u = widget.url;
    if (u == null || u.isEmpty) {
      _loading = false;
      return;
    }
    _loading = true;
    cachedImage(u, force: force).then((File? f) async {
      if (!mounted || gen != _gen) return;
      if (f == null && attempt < 1) {
        // Uma segunda chance, para falhas passageiras de rede.
        await Future<void>.delayed(const Duration(seconds: 5));
        if (!mounted || gen != _gen) return;
        _start(force: true, attempt: attempt + 1);
        setState(() {});
        return;
      }
      setState(() {
        _file = f;
        _loading = false;
      });
    });
  }

  void _purgeAndRetry() {
    final String? u = widget.url;
    if (u == null) return;
    forgetImage(u);
    setState(_start);
  }

  Widget _placeholder(BuildContext context, {required bool loading}) {
    final ThemeData t = Theme.of(context);
    return ColoredBox(
      color: t.colorScheme.surfaceContainerHighest,
      child: Center(
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(widget.icon, color: t.disabledColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final File? file = _file;
    if (file == null) return _placeholder(context, loading: _loading);
    return Image.file(
      file,
      key: ValueKey<String>(file.path),
      fit: widget.fit,
      cacheWidth: widget.cacheWidth,
      gaplessPlayback: false,
      errorBuilder: (BuildContext c, Object e, StackTrace? s) {
        if (!_purged) {
          // Arquivo em cache corrompido: apaga e baixa de novo uma vez.
          _purged = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _purgeAndRetry();
          });
          return _placeholder(c, loading: true);
        }
        return _placeholder(c, loading: false);
      },
    );
  }
}
