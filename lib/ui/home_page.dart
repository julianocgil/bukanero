import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../data/m3u/m3u_loader.dart';
import '../domain/channel.dart';

const String _path = String.fromEnvironment(
  'M3U',
  defaultValue: '/home/juliano/meu_iptv/minhalista.m3u',
);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<Map<String, List<Channel>>> _future = loadM3u(_path);
  late final Player _player = Player();
  late final VideoController _video = VideoController(_player);

  String? _group;
  String _query = '';
  String? _playing;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _play(Channel c) {
    setState(() => _playing = c.name);
    _player.open(Media(c.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_playing ?? 'Meu IPTV')),
      body: FutureBuilder<Map<String, List<Channel>>>(
        future: _future,
        builder:
            (
              BuildContext context,
              AsyncSnapshot<Map<String, List<Channel>>> snap,
            ) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(
                  child: Text('Erro ao ler a lista: ${snap.error}'),
                );
              }
              final Map<String, List<Channel>> data = snap.data!;
              final List<String> groups = data.keys.toList()..sort();
              final String q = _query.toLowerCase();
              final List<Channel> items = _group == null
                  ? <Channel>[]
                  : data[_group]!
                        .where((Channel c) => c.name.toLowerCase().contains(q))
                        .toList();

              return Row(
                children: <Widget>[
                  SizedBox(width: 260, child: _groupList(groups, data)),
                  const VerticalDivider(width: 1),
                  SizedBox(width: 340, child: _itemList(items)),
                  const VerticalDivider(width: 1),
                  Expanded(child: Video(controller: _video)),
                ],
              );
            },
      ),
    );
  }

  Widget _groupList(List<String> groups, Map<String, List<Channel>> data) {
    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (BuildContext context, int i) {
        final String g = groups[i];
        return ListTile(
          dense: true,
          selected: g == _group,
          title: Text(g, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Text('${data[g]!.length}'),
          onTap: () => setState(() {
            _group = g;
            _query = '';
          }),
        );
      },
    );
  }

  Widget _itemList(List<Channel> items) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            enabled: _group != null,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Buscar na categoria',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onChanged: (String v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: _group == null
              ? const Center(child: Text('Escolha uma categoria'))
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int i) => ListTile(
                    dense: true,
                    title: Text(
                      items[i].name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _play(items[i]),
                  ),
                ),
        ),
      ],
    );
  }
}
