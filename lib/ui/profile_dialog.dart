import 'dart:io';

import 'package:flutter/material.dart';

import '../domain/profile.dart';

/// Pede nome e playlist. Devolve o perfil, ou null se cancelado.
Future<Profile?> showProfileDialog(BuildContext context, {Profile? initial}) {
  return showDialog<Profile>(
    context: context,
    builder: (BuildContext ctx) => _ProfileDialog(initial: initial),
  );
}

class _ProfileDialog extends StatefulWidget {
  const _ProfileDialog({this.initial});

  final Profile? initial;

  @override
  State<_ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<_ProfileDialog> {
  late final TextEditingController _name = TextEditingController(
    text: widget.initial?.name ?? '',
  );
  late final TextEditingController _url = TextEditingController(
    text: widget.initial?.url ?? '',
  );
  late final TextEditingController _epg = TextEditingController(
    text: widget.initial?.epgUrl ?? '',
  );
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _url.dispose();
    _epg.dispose();
    super.dispose();
  }

  bool _isRemote(String s) =>
      s.startsWith('http://') || s.startsWith('https://');

  void _save() {
    final String name = _name.text.trim();
    final String url = _url.text.trim();
    final String epg = _epg.text.trim();
    if (name.isEmpty || url.isEmpty) {
      setState(() => _error = 'Preencha o nome e a playlist.');
      return;
    }
    if (!_isRemote(url) && !File(url).existsSync()) {
      setState(
        () => _error = 'Use uma URL http(s) ou o caminho de um arquivo.',
      );
      return;
    }
    if (epg.isNotEmpty && !_isRemote(epg) && !File(epg).existsSync()) {
      setState(() => _error = 'Guia: use uma URL http(s) ou um arquivo XMLTV.');
      return;
    }
    Navigator.pop(
      context,
      Profile(
        id:
            widget.initial?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        url: url,
        epgUrl: epg.isEmpty ? null : epg,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Novo perfil' : 'Editar perfil'),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nome do usuário'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _url,
              decoration: const InputDecoration(
                labelText: 'Playlist M3U (URL ou caminho do arquivo)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _epg,
              decoration: const InputDecoration(
                labelText: 'Guia XMLTV (opcional; vazio = detectar sozinho)',
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _save, child: const Text('Salvar')),
      ],
    );
  }
}
