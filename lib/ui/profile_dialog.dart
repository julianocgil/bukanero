import 'dart:io';

import 'package:flutter/material.dart';

import '../domain/profile.dart';
import '../l10n/tr.dart';

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
  late bool _insecure = widget.initial?.allowInsecure ?? false;
  late int _refreshHours =
      widget.initial?.refreshHours ?? Profile.defaultRefreshHours;

  static Map<int, String> get _refreshOptions => <int, String>{
    6: tr.refresh6h,
    12: tr.refresh12h,
    24: tr.refresh24hDefault,
    48: tr.refresh2d,
    168: tr.refreshWeekly,
    0: tr.refreshNever,
  };
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
      setState(() => _error = tr.fillNameAndPlaylist);
      return;
    }
    if (!_isRemote(url) && !File(url).existsSync()) {
      setState(() => _error = tr.playlistUrlHint);
      return;
    }
    if (epg.isNotEmpty && !_isRemote(epg) && !File(epg).existsSync()) {
      setState(() => _error = tr.guideUrlHint);
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
        allowInsecure: _insecure,
        refreshHours: _refreshHours,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? tr.newProfile : tr.editProfile),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: tr.userName),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _url,
              decoration: InputDecoration(labelText: tr.playlistField),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _epg,
              decoration: InputDecoration(labelText: tr.guideField),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _refreshOptions.containsKey(_refreshHours)
                  ? _refreshHours
                  : Profile.defaultRefreshHours,
              decoration: InputDecoration(labelText: tr.autoRefreshList),
              items: <DropdownMenuItem<int>>[
                for (final MapEntry<int, String> e in _refreshOptions.entries)
                  DropdownMenuItem<int>(value: e.key, child: Text(e.value)),
              ],
              onChanged: (int? v) => setState(
                () => _refreshHours = v ?? Profile.defaultRefreshHours,
              ),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _insecure,
              onChanged: (bool? v) => setState(() => _insecure = v ?? false),
              title: Text(tr.acceptInvalidCert),
              subtitle: Text(tr.acceptInvalidCertHint),
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
          child: Text(tr.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(tr.save)),
      ],
    );
  }
}
