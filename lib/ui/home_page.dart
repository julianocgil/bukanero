import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../data/catalog_db.dart';
import '../data/download.dart';
import '../data/epg.dart';
import '../data/metadata.dart';
import '../data/profile_store.dart';
import '../data/series_db.dart';
import '../data/user_data.dart';
import '../domain/channel.dart';
import '../domain/profile.dart';
import '../domain/section.dart';
import '../domain/series.dart';
import '../domain/sort_mode.dart';
import 'item_views.dart';
import 'player_bar.dart';
import 'profile_dialog.dart';
import 'series_dialog.dart';

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
  Future<CatalogDb>? _future;
  CatalogDb? _db;
  UserData? _user;
  SeriesDb? _series;
  EpgDb? _epg;
  bool _epgBusy = false;
  bool _metaBusy = false;
  String? _epgStatus;
  final Map<Section, Map<String, int>> _counts = <Section, Map<String, int>>{};
  Section _section = Section.live;
  String? _group;
  String _query = '';
  Timer? _debounce;
  final TextEditingController _searchCtl = TextEditingController();
  String? _playing;
  String? _playingUrl;
  bool _showHidden = false;
  final Map<Section, SortMode> _sorts = <Section, SortMode>{
    Section.live: SortMode.listOrder,
    Section.movies: SortMode.listOrder,
    Section.series: SortMode.nameAsc,
  };

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
    _debounce?.cancel();
    _searchCtl.dispose();
    _closeData();
    _player.dispose();
    super.dispose();
  }

  void _closeData() {
    _db?.close();
    _db = null;
    _user?.close();
    _user = null;
    _series?.close();
    _series = null;
    _epg?.close();
    _epg = null;
  }

  // ---- perfis e dados -----------------------------------------------------

  void _apply(Profile p, {required bool refresh}) {
    saveLastProfileId(p.id);
    _player.stop();
    _closeData();
    _counts.clear();
    _profile = p;
    _group = null;
    _setQuery('');
    _playing = null;
    _playingUrl = null;
    _epgStatus = null;
    _epgBusy = false;
    _future = _prepare(p, refresh: refresh);
  }

  void _select(Profile p, {bool refresh = false}) {
    setState(() => _apply(p, refresh: refresh));
  }

  Future<CatalogDb> _prepare(Profile p, {required bool refresh}) async {
    final String src = p.url.trim();
    final bool remote = src.startsWith('http://') || src.startsWith('https://');
    String m3u = src;
    if (remote) {
      final File cache = playlistCacheFile(p);
      if (refresh || !cache.existsSync()) {
        await downloadFile(src, cache, allowInsecure: p.allowInsecure);
      }
      m3u = cache.path;
    }
    final String dbPath = catalogDbPath(p);
    if (!catalogIsFresh(dbPath, m3u)) await importCatalog(m3u, dbPath);
    await ensureSeriesIndex(dbPath, seriesDbPath(p));
    final CatalogDb db = CatalogDb.open(dbPath);
    _closeData();
    _db = db;
    _user = UserData.open(userDataPath(p));
    _series = SeriesDb.open(seriesDbPath(p));
    final String metaPath = metaDbPath(p);
    db.attachMeta(metaPath);
    _series?.attachMeta(metaPath);
    unawaited(Future<void>.microtask(() => _refreshMeta(force: refresh)));
    _epg = EpgDb.tryOpen(epgDbPath(p));
    unawaited(Future<void>.microtask(() => _refreshEpg()));
    return db;
  }

  Future<void> _refreshEpg({bool force = false}) async {
    final Profile? p = _profile;
    final CatalogDb? db = _db;
    if (!mounted || p == null || db == null || _epgBusy) return;
    final String path = epgDbPath(p);
    if (!force && epgIsFresh(path)) return;

    List<String> urls;
    final String? manual = p.epgUrl;
    if (manual != null && manual.isNotEmpty) {
      urls = <String>[manual];
    } else {
      urls = db.epgUrls();
    }
    if (urls.isEmpty) {
      setState(
        () => _epgStatus = 'Esta lista não informa o endereço do guia (EPG).',
      );
      return;
    }

    setState(() {
      _epgBusy = true;
      _epgStatus = 'Baixando o guia de programação...';
    });
    try {
      final int n = await importEpg(urls, path, allowInsecure: p.allowInsecure);
      final CatalogDb? cur = _db;
      if (!mounted || cur == null || _profile?.id != p.id) {
        _epgBusy = false;
        return;
      }
      _epg?.close();
      final EpgDb? e = EpgDb.tryOpen(path);
      final int matched = e == null
          ? 0
          : e.channelIds().intersection(cur.liveTvgIds()).length;
      setState(() {
        _epg = e;
        _epgBusy = false;
        _epgStatus = 'Guia: $n programas, $matched canais com programação';
      });
    } on Object catch (err) {
      if (!mounted) return;
      setState(() {
        _epgBusy = false;
        _epgStatus = 'Guia: $err';
      });
    }
  }

  bool get _hasMeta => _db?.hasMeta ?? false;

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 6)),
    );
  }

  Future<void> _refreshMeta({bool force = false}) async {
    final Profile? p = _profile;
    final CatalogDb? db = _db;
    if (!mounted || p == null || db == null || _metaBusy) return;
    final String path = metaDbPath(p);
    if (!force && metaIsFresh(path)) return;
    final ApiAccess? api = deriveApiAccess(p.url, db.sampleItemUrl());
    if (api == null) {
      _toast(
        'Não consegui identificar o servidor da lista para buscar '
        'notas e datas.',
      );
      return;
    }
    setState(() => _metaBusy = true);
    try {
      await importMetadata(api, path, allowInsecure: p.allowInsecure);
      if (!mounted || _profile?.id != p.id) {
        _metaBusy = false;
        return;
      }
      db.attachMeta(path);
      _series?.attachMeta(path);
      final (int, int) m = db.metaCoverage();
      final (int, int) sr = _series?.metaCoverage() ?? (0, 0);
      setState(() => _metaBusy = false);
      _toast(
        'Notas carregadas: ${m.$2} de ${m.$1} filmes, '
        '${sr.$2} de ${sr.$1} séries.',
      );
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _metaBusy = false);
      _toast('Notas e datas: $e');
    }
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
    if (p.epgUrl != cur.epgUrl || p.url != cur.url) deleteEpg(cur);
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
          'A lista baixada, o guia e os itens ocultos deste perfil '
          'também serão apagados.',
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
    await _player.stop();
    _closeData();
    deleteProfileData(cur);
    deleteCatalog(cur);
    deleteSeries(cur);
    deleteMeta(cur);
    deleteEpg(cur);
    deleteUserData(cur);
    final List<Profile> rest = _profiles
        .where((Profile p) => p.id != cur.id)
        .toList();
    saveProfiles(rest);
    if (!mounted) return;
    setState(() {
      _profiles = rest;
      _profile = null;
      _future = null;
      _playing = null;
      _playingUrl = null;
      _group = null;
      _epgStatus = null;
      _counts.clear();
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

  // ---- ações --------------------------------------------------------------

  Future<void> _openSeries(Channel c) async {
    final SeriesDb? sdb = _series;
    if (sdb == null) return;
    final Channel? ep = await showSeriesDialog(
      context,
      title: c.name,
      cover: c.logo,
      episodes: sdb.episodes(c.name),
    );
    if (ep != null && mounted) _play(ep);
  }

  void _onItemTap(Channel c) {
    if (_section == Section.series && c.url.startsWith(seriesUrlPrefix)) {
      unawaited(_openSeries(c));
    } else {
      _play(c);
    }
  }

  void _play(Channel c) {
    setState(() {
      _playing = c.name;
      _playingUrl = c.url;
    });
    _player.open(Media(c.url));
  }

  void _toggleGroup(String g, bool hidden) {
    _user?.setGroupHidden(_section, g, hidden: !hidden);
    setState(() {
      if (_group == g && !hidden && !_showHidden) _group = null;
    });
  }

  void _toggleItem(Channel c, bool hidden) {
    final String? g = _group ?? c.group;
    if (g == null) return;
    _user?.setItemHidden(_section, g, c.name, hidden: !hidden);
    setState(() {});
  }

  // ---- interface ----------------------------------------------------------

  void _setQuery(String v) {
    _debounce?.cancel();
    _query = v;
    if (_searchCtl.text != v) _searchCtl.text = v;
  }

  void _onQuery(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _query = v);
    });
  }

  bool _isHidden(Channel c, Set<String> hidden) => _group != null
      ? hidden.contains(c.name)
      : hidden.contains(hiddenKey(c.group ?? '', c.name));

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
            tooltip: _showHidden
                ? 'Esconder os itens ocultos'
                : 'Mostrar os itens ocultos',
            icon: Icon(_showHidden ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() {
              _showHidden = !_showHidden;
              _group = null;
            }),
          ),
          IconButton(
            tooltip: 'Atualizar o guia de programação (EPG)',
            icon: const Icon(Icons.event_note),
            onPressed: (cur == null || _epgBusy)
                ? null
                : () => _refreshEpg(force: true),
          ),
          IconButton(
            tooltip: 'Baixar a lista novamente',
            icon: const Icon(Icons.refresh),
            onPressed: cur == null ? null : () => _select(cur, refresh: true),
          ),
          PopupMenuButton<SortMode>(
            tooltip: 'Ordenar',
            icon: const Icon(Icons.sort),
            onSelected: (SortMode m) => setState(() => _sorts[_section] = m),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortMode>>[
              for (final SortMode m in SortMode.values)
                if (!m.needsMeta || _section != Section.live)
                  CheckedPopupMenuItem<SortMode>(
                    value: m,
                    enabled: !m.needsMeta || _hasMeta,
                    checked: _sorts[_section] == m,
                    child: Text(
                      (m.needsMeta && !_hasMeta)
                          ? '${m.label} (${_metaBusy ? 'carregando...' : 'indisponível'})'
                          : m.label,
                    ),
                  ),
            ],
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
          : FutureBuilder<CatalogDb>(future: _future, builder: _content),
    );
  }

  Widget _content(BuildContext context, AsyncSnapshot<CatalogDb> snap) {
    if (snap.connectionState != ConnectionState.done) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text(
              'Baixando e preparando a lista (só demora na primeira vez)...',
            ),
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

    final CatalogDb db = snap.data!;
    final SortMode curSort = _sorts[_section] ?? SortMode.listOrder;
    db.sort = curSort;
    _series?.sort = curSort;
    final UserData? user = _user;
    if (user == null) return const SizedBox.shrink();

    final Map<String, int> counts = _counts[_section] ??=
        _section == Section.series
        ? (_series?.groupCounts() ?? db.groupCounts(_section))
        : db.groupCounts(_section);
    final Set<String> hiddenGroups = user.hiddenGroups(_section);
    final List<String> groups =
        counts.keys
            .where((String g) => _showHidden || !hiddenGroups.contains(g))
            .toList()
          ..sort();

    Set<String> hiddenItems;
    List<Channel> items;
    final String? group = _group;
    if (group != null) {
      hiddenItems = user.hiddenItems(_section, group);
      items = db.items(
        _section,
        group,
        _query,
        exclude: _showHidden ? const <String>{} : hiddenItems,
      );
    } else {
      hiddenItems = user.hiddenItemKeys(_section);
      final Set<String> keys = hiddenItems;
      items = db.search(
        _section,
        _query,
        isHidden: _showHidden
            ? null
            : (String g, String n) =>
                  hiddenGroups.contains(g) || keys.contains(hiddenKey(g, n)),
      );
    }

    final SeriesDb? sdb = _series;
    if (_section == Section.series && sdb != null) {
      if (group != null) {
        hiddenItems = user.hiddenItems(_section, group);
        final Set<String> skip = hiddenItems;
        items = sdb.list(
          group,
          _query,
          exclude: _showHidden ? const <String>{} : skip,
        );
      } else {
        hiddenItems = user.hiddenItemKeys(_section);
        final Set<String> keys = hiddenItems;
        items = sdb.search(
          _query,
          isHidden: _showHidden
              ? null
              : (String g, String n) =>
                    hiddenGroups.contains(g) || keys.contains(hiddenKey(g, n)),
        );
      }
    }

    return Row(
      children: <Widget>[
        SizedBox(width: 260, child: _groupColumn(groups, counts, hiddenGroups)),
        const VerticalDivider(width: 1),
        SizedBox(
          width: _section == Section.live ? 380 : 520,
          child: _itemColumn(items, hiddenItems),
        ),
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
    Map<String, int> counts,
    Set<String> hiddenGroups,
  ) {
    final ThemeData t = Theme.of(context);
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
              _setQuery('');
            }),
          ),
        ),
        ListTile(
          dense: true,
          leading: const Icon(Icons.apps, size: 18),
          title: const Text('Todas as categorias'),
          selected: _group == null,
          onTap: () => setState(() {
            _group = null;
            _setQuery('');
          }),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: groups.length,
            itemBuilder: (BuildContext context, int i) {
              final String g = groups[i];
              final bool hidden = hiddenGroups.contains(g);
              return ListTile(
                dense: true,
                selected: g == _group,
                title: Text(
                  g,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: hidden
                      ? TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: t.disabledColor,
                        )
                      : null,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('${counts[g]}'),
                    HideMenu(
                      hidden: hidden,
                      onToggle: () => _toggleGroup(g, hidden),
                    ),
                  ],
                ),
                onTap: () => setState(() {
                  _group = g;
                  _setQuery('');
                }),
              );
            },
          ),
        ),
        if (_epgStatus != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: <Widget>[
                if (_epgBusy) ...<Widget>[
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(_epgStatus!, style: t.textTheme.bodySmall),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _itemColumn(List<Channel> items, Set<String> hiddenItems) {
    final bool live = _section == Section.live;
    final int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    Widget body;
    if (items.isEmpty) {
      body = const Center(child: Text('Nada por aqui'));
    } else if (live) {
      body = ListView.builder(
        itemCount: items.length,
        itemBuilder: (BuildContext context, int i) {
          final Channel c = items[i];
          final bool hidden = _isHidden(c, hiddenItems);
          return LiveTile(
            key: ValueKey<String>(c.url),
            channel: c,
            selected: c.url == _playingUrl,
            hidden: hidden,
            nowSecs: now,
            current: _epg?.nowNext(c.tvgId, now).$1,
            onTap: () => _play(c),
            onToggleHidden: () => _toggleItem(c, hidden),
          );
        },
      );
    } else {
      body = GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 150,
          childAspectRatio: 0.58,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: items.length,
        itemBuilder: (BuildContext context, int i) {
          final Channel c = items[i];
          final bool hidden = _isHidden(c, hiddenItems);
          return PosterCard(
            key: ValueKey<String>(c.url),
            channel: c,
            selected: c.url == _playingUrl,
            hidden: hidden,
            onTap: () => _onItemTap(c),
            onToggleHidden: () => _toggleItem(c, hidden),
          );
        },
      );
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: _searchCtl,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Buscar pelo nome',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onChanged: _onQuery,
          ),
        ),
        Expanded(child: body),
      ],
    );
  }
}
