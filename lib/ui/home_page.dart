import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../data/m3u/m3u_downloader.dart';
import '../data/m3u/m3u_loader.dart';
import '../data/profile_store.dart';
import '../domain/channel.dart';
import '../domain/profile.dart';
import '../domain/section.dart';
import 'player_bar.dart';
import 'profile_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Player _player = Player();
  late final VideoController _video = VideoController(_player);

  List<Profile> _profiles = <Profile>[];
  Profile? _profile;
  Future<Catalog>? _future;
  Section _section = Section.live;
  String? _group;
  String _query = '';
  String? _playing;
  bool _hideAdult = true;

  @override
  void initState() {
    super.initState();
    _profiles = loadProfiles();
    if (_profiles.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _addProfile());
    } else {
      final String? last = loadLastProfileId();
      _apply(
        _profiles.firstWhere(
          (Profile p) => p.id == last,
          orElse: () => _profiles.first,
        ),
        refresh: false,
      );
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  // ---- perfis -------------------------------------------------------------

  void _apply(Profile p, {required bool refresh}) {
    saveLastProfileId(p.id);
    _player.stop();
    _profile = p;
    _group = null;
    _query = '';
    _playing = null;
    _future = _prepare(p, refresh: refresh);
  }

  void _select(Profile p, {bool refresh = false}) {
    setState(() => _apply(p, refresh: refresh));
  }

  Future<Catalog> _prepare(Profile p, {required bool refresh}) async {
    final String src = p.url.trim();
    final bool remote = src.startsWith('http://') || src.startsWith('https://');
    String path = src;
    if (remote) {
      final File cache = playlistCacheFile(p);
      if (refresh || !cache.existsSync()) await downloadPlaylist(src, cache);
      path = cache.path;
    }
    return loadM3u(path);
  }

  Future<void> _addProfile() async {
    final Profile? p = await showProfileDialog(context);
    if (p == null || !mounted) return;
    setState(() => _profiles = <Profile>[..._profiles, p]);
    saveProfiles(_profiles);
    _select(p);
  }

  Future<void> _editProfile() async {
    final Profile? cur = _profile;
    if (cur == null) return;
    final Profile? p = await showProfileDialog(context, initial: cur);
    if (p == null || !mounted) return;
    setState(() {
      _profiles = <Profile>[
        for (final Profile x in _profiles) x.id == p.id ? p : x,
      ];
    });
    saveProfiles(_profiles);
    _select(p, refresh: p.url != cur.url);
  }

  Future<void> _deleteProfile() async {
    final Profile? cur = _profile;
    if (cur == null) return;
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text('Excluir "${cur.name}"?'),
        content: const Text(
          'A lista baixada deste perfil também será apagada.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    deleteProfileData(cur);
    final List<Profile> rest = _profiles
        .where((Profile p) => p.id != cur.id)
        .toList();
    saveProfiles(rest);
    await _player.stop();
    if (!mounted) return;
    setState(() {
      _profiles = rest;
      _profile = null;
      _future = null;
      _playing = null;
      _group = null;
    });
    if (rest.isNotEmpty) {
      _select(rest.first);
    } else {
      await _addProfile();
    }
  }

  Future<void> _onMenu(String v) async {
    if (v.startsWith('p:')) {
      _select(_profiles.firstWhere((Profile p) => p.id == v.substring(2)));
    } else if (v == 'new') {
      await _addProfile();
    } else if (v == 'edit') {
      await _editProfile();
    } else if (v == 'delete') {
      await _deleteProfile();
    }
  }

  void _play(Channel c) {
    setState(() => _playing = c.name);
    _player.open(Media(c.url));
  }

  // ---- interface ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final Profile? cur = _profile;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _playing ?? 'Meu IPTV${cur == null ? '' : ' · ${cur.name}'}',
        ),
        actions: <Widget>[
          IconButton(
            tooltip: _hideAdult
                ? 'Mostrar categorias adultas'
                : 'Ocultar categorias adultas',
            icon: Icon(_hideAdult ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() {
              _hideAdult = !_hideAdult;
              _group = null;
            }),
          ),
          IconButton(
            tooltip: 'Baixar a lista novamente',
            icon: const Icon(Icons.refresh),
            onPressed: cur == null ? null : () => _select(cur, refresh: true),
          ),
          PopupMenuButton<String>(
            tooltip: 'Perfis',
            icon: const Icon(Icons.account_circle),
            onSelected: _onMenu,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              for (final Profile p in _profiles)
                CheckedPopupMenuItem<String>(
                  value: 'p:${p.id}',
                  checked: p.id == cur?.id,
                  child: Text(p.name),
                ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'new',
                child: Text('Novo perfil...'),
              ),
              if (cur != null)
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Text('Editar perfil atual...'),
                ),
              if (cur != null)
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Excluir perfil atual'),
                ),
            ],
          ),
        ],
      ),
      body: _future == null
          ? Center(
              child: FilledButton(
                onPressed: _addProfile,
                child: const Text('Criar perfil'),
              ),
            )
          : FutureBuilder<Catalog>(future: _future, builder: _content),
    );
  }

  Widget _content(BuildContext context, AsyncSnapshot<Catalog> snap) {
    if (snap.connectionState != ConnectionState.done) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Baixando e lendo a lista...'),
          ],
        ),
      );
    }
    if (snap.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Erro: ${snap.error}', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _select(_profile!, refresh: true),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final Map<String, List<Channel>> groupsMap = snap.data![_section]!;
    final List<String> groups =
        groupsMap.keys
            .where((String g) => !_hideAdult || !isAdultGroup(g))
            .toList()
          ..sort();
    final List<Channel> all = groupsMap[_group] ?? const <Channel>[];
    final String q = _query.toLowerCase();
    final List<Channel> items = q.isEmpty
        ? all
        : all.where((Channel c) => c.name.toLowerCase().contains(q)).toList();

    return Row(
      children: <Widget>[
        SizedBox(width: 300, child: _groupColumn(groups, groupsMap)),
        const VerticalDivider(width: 1),
        SizedBox(width: 340, child: _itemColumn(items)),
        const VerticalDivider(width: 1),
        Expanded(
          child: Column(
            children: <Widget>[
              Expanded(child: Video(controller: _video)),
              PlayerBar(player: _player),
            ],
          ),
        ),
      ],
    );
  }

  Widget _groupColumn(
    List<String> groups,
    Map<String, List<Channel>> groupsMap,
  ) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8),
          child: SegmentedButton<Section>(
            showSelectedIcon: false,
            segments: const <ButtonSegment<Section>>[
              ButtonSegment<Section>(
                value: Section.live,
                label: Text('Ao vivo'),
              ),
              ButtonSegment<Section>(
                value: Section.movies,
                label: Text('Filmes'),
              ),
              ButtonSegment<Section>(
                value: Section.series,
                label: Text('Séries'),
              ),
            ],
            selected: <Section>{_section},
            onSelectionChanged: (Set<Section> s) => setState(() {
              _section = s.first;
              _group = null;
              _query = '';
            }),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: groups.length,
            itemBuilder: (BuildContext context, int i) {
              final String g = groups[i];
              return ListTile(
                dense: true,
                selected: g == _group,
                title: Text(g, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Text('${groupsMap[g]!.length}'),
                onTap: () => setState(() {
                  _group = g;
                  _query = '';
                }),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _itemColumn(List<Channel> items) {
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
