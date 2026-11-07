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
import 'category_picker.dart';
import 'guide_page.dart';
import 'item_views.dart';
import 'perf_monitor.dart';
import 'player_view.dart';
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
  late final PerfMonitor _perf = PerfMonitor(_player);

  List<Profile> _profiles = <Profile>[];
  Profile? _profile;
  Future<CatalogDb>? _future;
  CatalogDb? _db;
  UserData? _user;
  SeriesDb? _series;
  EpgDb? _epg;
  bool _epgBusy = false;
  bool _metaBusy = false;
  bool _listBusy = false;
  // Confere de tempos em tempos se a lista passou do intervalo do perfil.
  Timer? _autoRefresh;
  DateTime? _autoFailedAt;
  // Progresso do download da lista (tela de carregamento e barra de cima).
  final ValueNotifier<String?> _listProgress = ValueNotifier<String?>(null);
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
  // Lista ampliada sobre o espaço do vídeo.
  bool _wide = false;
  // Ordem padrão até o usuário escolher a dele (guardada por perfil).
  // Sem notas e datas carregadas, "recentes" cai para a ordem da lista.
  static const Map<Section, SortMode> _defaultSorts = <Section, SortMode>{
    Section.live: SortMode.listOrder,
    Section.movies: SortMode.recent,
    Section.series: SortMode.recent,
  };
  final Map<Section, SortMode> _sorts = Map<Section, SortMode>.of(
    _defaultSorts,
  );

  static String _sortPrefKey(Section s) => 'sort.${s.name}';

  void _loadSorts(UserData user) {
    _sorts
      ..clear()
      ..addAll(_defaultSorts);
    for (final Section s in Section.values) {
      final SortMode? m = SortMode.values
          .asNameMap()[user.pref(_sortPrefKey(s))];
      if (m != null) _sorts[s] = m;
    }
  }

  void _setSort(SortMode m) {
    setState(() => _sorts[_section] = m);
    _user?.setPref(_sortPrefKey(_section), m.name);
  }

  @override
  void initState() {
    super.initState();
    _autoRefresh = Timer.periodic(
      const Duration(minutes: 10),
      (_) => _maybeAutoRefresh(),
    );
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
    _autoRefresh?.cancel();
    _searchCtl.dispose();
    _closeData();
    _listProgress.dispose();
    _perf.dispose();
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
        try {
          await _downloadList(p, cache);
        } on DownloadException catch (e) {
          // Sem lista nova, mas com a anterior guardada: segue com ela.
          if (!cache.existsSync()) rethrow;
          _toast('Não consegui baixar a lista ($e). Usando a lista anterior.');
        } finally {
          _listProgress.value = null;
        }
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
    _loadSorts(_user!);
    _series = SeriesDb.open(seriesDbPath(p));
    final String metaPath = metaDbPath(p);
    db.attachMeta(metaPath);
    _series?.attachMeta(metaPath);
    unawaited(Future<void>.microtask(() => _refreshMeta(force: refresh)));
    _epg = EpgDb.tryOpen(epgDbPath(p));
    unawaited(Future<void>.microtask(() => _refreshEpg()));
    unawaited(Future<void>.microtask(_maybeAutoRefresh));
    return db;
  }

  static String _mb(int bytes) =>
      (bytes / (1024 * 1024)).toStringAsFixed(1).replaceAll('.', ',');

  Future<void> _downloadList(Profile p, File cache) {
    int shown = -1;
    return downloadFile(
      p.url.trim(),
      cache,
      allowInsecure: p.allowInsecure,
      onProgress: (int received, int? total) {
        // Atualiza o texto a cada 0,1 MB, não a cada pedaço recebido.
        final int step = received ~/ (100 * 1024);
        if (step == shown) return;
        shown = step;
        _listProgress.value = total == null
            ? '${_mb(received)} MB baixados'
            : '${_mb(received)} de ${_mb(total)} MB';
      },
    );
  }

  /// Atualiza sozinho quando a lista baixada passou do intervalo do perfil.
  /// Depois de uma falha, espera uma hora antes de tentar de novo.
  void _maybeAutoRefresh() {
    final Profile? p = _profile;
    if (!mounted || p == null || _db == null || _listBusy) return;
    final String src = p.url.trim();
    if (!(src.startsWith('http://') || src.startsWith('https://'))) return;
    final DateTime now = DateTime.now();
    final DateTime? failed = _autoFailedAt;
    if (failed != null && now.difference(failed) < const Duration(hours: 1)) {
      return;
    }
    final File cache = playlistCacheFile(p);
    if (!cache.existsSync()) return;
    if (!p.listRefreshDue(cache.lastModifiedSync(), now)) return;
    unawaited(_refreshList(auto: true));
  }

  /// Baixa e prepara a lista nova por trás; a atual continua na tela (e o
  /// vídeo, tocando) até a nova ficar pronta. Se falhar, nada muda.
  Future<void> _refreshList({bool auto = false}) async {
    final Profile? p = _profile;
    if (p == null || _listBusy) return;
    if (_db == null) {
      _select(p, refresh: true);
      return;
    }
    final String src = p.url.trim();
    final bool remote = src.startsWith('http://') || src.startsWith('https://');
    setState(() => _listBusy = true);
    _listProgress.value = 'Conectando ao servidor...';
    try {
      String m3u = src;
      if (remote) {
        final File cache = playlistCacheFile(p);
        await _downloadList(p, cache);
        m3u = cache.path;
      }
      _listProgress.value = 'Preparando a lista nova...';
      final String dbPath = catalogDbPath(p);
      if (!catalogIsFresh(dbPath, m3u)) await importCatalog(m3u, dbPath);
      await ensureSeriesIndex(dbPath, seriesDbPath(p));
      if (!mounted || _profile?.id != p.id) return;
      _swapCatalog(p, dbPath);
      _autoFailedAt = null;
      _toast(auto ? 'Lista atualizada automaticamente.' : 'Lista atualizada.');
      unawaited(_refreshMeta(force: true));
    } on Object catch (e) {
      if (auto) _autoFailedAt = DateTime.now();
      _toast(
        'Não consegui atualizar a lista ($e). Continuo com a anterior'
        '${auto ? '; tento de novo daqui a uma hora' : ''}.',
      );
    } finally {
      _listProgress.value = null;
      if (mounted) setState(() => _listBusy = false);
    }
  }

  /// Troca o catálogo aberto pelo recém-importado, sem parar o vídeo.
  void _swapCatalog(Profile p, String dbPath) {
    final CatalogDb db = CatalogDb.open(dbPath);
    final SeriesDb series = SeriesDb.open(seriesDbPath(p));
    final String metaPath = metaDbPath(p);
    db.attachMeta(metaPath);
    series.attachMeta(metaPath);
    setState(() {
      _db?.close();
      _series?.close();
      _db = db;
      _series = series;
      _counts.clear();
    });
  }

  Future<void> _refreshEpg({bool force = false}) async {
    final Profile? p = _profile;
    final CatalogDb? db = _db;
    if (!mounted || p == null || db == null || _epgBusy) return;
    final String path = epgDbPath(p);
    if (!force && epgIsFresh(path) && (_epg?.hasNames ?? false)) return;

    List<String> urls;
    final String? manual = p.epgUrl;
    if (manual != null && manual.isNotEmpty) {
      urls = <String>[manual];
    } else {
      urls = db.epgUrls();
    }
    if (urls.isEmpty) {
      // A lista não informa o guia: usa o do próprio servidor da lista.
      final ApiAccess? api = deriveApiAccess(p.url, db.sampleItemUrl());
      if (api != null) urls = <String>[xmltvUrl(api)];
    }
    if (urls.isEmpty) {
      setState(
        () => _epgStatus =
            'Não achei o guia (EPG) nem na lista nem no servidor dela.',
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
      final int matched = e?.matchCount(cur.liveChannels()) ?? 0;
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
    if (p.url == cur.url &&
        p.epgUrl == cur.epgUrl &&
        p.allowInsecure == cur.allowInsecure) {
      // Só nome ou intervalo de atualização: não precisa recarregar nem
      // parar o vídeo.
      setState(() => _profile = p);
      _maybeAutoRefresh();
      return;
    }
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
    final String lastKey = 'last.${c.name}';
    final Channel? ep = await showSeriesDialog(
      context,
      title: c.name,
      cover: c.logo,
      episodes: sdb.episodes(c.name),
      lastUrl: _user?.pref(lastKey),
    );
    if (ep == null || !mounted) return;
    // A série vai para os recentes e guarda o episódio, para continuar.
    _user?.addRecent(Section.series, c);
    _user?.setPref(lastKey, ep.url);
    _play(ep);
  }

  Future<void> _openGuide() async {
    final CatalogDb? db = _db;
    final UserData? user = _user;
    final EpgDb? epg = _epg;
    if (db == null || user == null || epg == null) return;
    final Set<String> groups = user.hiddenGroups(Section.live);
    final Set<String> keys = user.hiddenItemKeys(Section.live);
    final List<Channel> channels = db.search(
      Section.live,
      '',
      limit: 1 << 30,
      isHidden: _showHidden
          ? null
          : (String g, String n) =>
                groups.contains(g) || keys.contains(hiddenKey(g, n)),
    );
    final Channel? c = await showGuide(
      context,
      channels: channels,
      epg: epg,
      group: _section == Section.live ? _group : null,
    );
    if (c != null && mounted) _play(c);
  }

  void _onItemTap(Channel c) {
    if (_section == Section.series && c.url.startsWith(seriesUrlPrefix)) {
      unawaited(_openSeries(c));
    } else {
      if (_section != Section.live) _user?.addRecent(_section, c);
      _play(c);
    }
  }

  void _removeRecent(Channel c) {
    _user?.removeRecent(_section, c.url);
    setState(() {});
  }

  /// Faixa "Continuar assistindo" no topo de filmes e séries.
  Widget _recentRow(List<Channel> recent) {
    final ThemeData t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 6),
          child: Row(
            children: <Widget>[
              Icon(Icons.history, size: 18, color: t.colorScheme.primary),
              const SizedBox(width: 6),
              Text('Continuar assistindo', style: t.textTheme.titleSmall),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recent.length,
            separatorBuilder: (BuildContext context, int i) =>
                const SizedBox(width: 8),
            itemBuilder: (BuildContext context, int i) {
              final Channel c = recent[i];
              return SizedBox(
                width: 116,
                child: PosterCard(
                  key: ValueKey<String>('recent:${c.url}'),
                  channel: c,
                  selected: c.url == _playingUrl,
                  hidden: false,
                  onTap: () => _onItemTap(c),
                  onToggleHidden: () {},
                  onRemove: () => _removeRecent(c),
                ),
              );
            },
          ),
        ),
        const Divider(height: 20),
      ],
    );
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
        bottom: _listBusy
            ? PreferredSize(
                preferredSize: const Size.fromHeight(24),
                child: ValueListenableBuilder<String?>(
                  valueListenable: _listProgress,
                  builder: (BuildContext context, String? v, Widget? _) =>
                      Column(
                        children: <Widget>[
                          const LinearProgressIndicator(minHeight: 2),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Text(
                              'Atualizando a lista: ${v ?? ''} '
                              '(pode continuar usando)',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                ),
              )
            : null,
        title: Text(
          _playing ?? 'Bukanero${cur == null ? '' : ' · ${cur.name}'}',
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
            tooltip: _perf.running
                ? 'Desligar o monitor de desempenho'
                : 'Monitor de desempenho (FPS)',
            icon: Icon(_perf.running ? Icons.speed : Icons.speed_outlined),
            isSelected: _perf.running,
            onPressed: () {
              setState(_perf.toggle);
              final String? path = _perf.logPath;
              if (path != null) _toast('Gravando o histórico em $path');
            },
          ),
          IconButton(
            tooltip: 'Guia de programação: todos os canais',
            icon: const Icon(Icons.view_timeline_outlined),
            onPressed: _epg == null ? null : _openGuide,
          ),
          IconButton(
            tooltip: 'Atualizar o guia de programação (EPG)',
            icon: const Icon(Icons.event_note),
            onPressed: (cur == null || _epgBusy)
                ? null
                : () => _refreshEpg(force: true),
          ),
          IconButton(
            tooltip: _listBusy
                ? 'Atualizando a lista...'
                : 'Atualizar a lista (em segundo plano)',
            icon: const Icon(Icons.refresh),
            onPressed: (cur == null || _listBusy) ? null : _refreshList,
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
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            const Text(
              'Baixando e preparando a lista (só demora na primeira vez)...',
            ),
            ValueListenableBuilder<String?>(
              valueListenable: _listProgress,
              builder: (BuildContext context, String? v, Widget? _) =>
                  Text(v ?? '', style: Theme.of(context).textTheme.bodySmall),
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

    // Depois de uma atualização em segundo plano, _db é o catálogo novo.
    final CatalogDb db = _db ?? snap.data!;
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

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        // Normal: grade e vídeo lado a lado. Ampliada: a grade toma o lugar
        // do vídeo, que continua tocando numa coluna estreita.
        final double normal = _section == Section.live ? 440 : 640;
        final double width = _wide
            ? (box.maxWidth - _miniVideoWidth).clamp(normal, box.maxWidth)
            : normal;
        return Row(
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: width,
              child: _itemColumn(
                items,
                hiddenItems,
                groups: groups,
                counts: counts,
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Stack(
                children: <Widget>[
                  Positioned.fill(child: PlayerView(controller: _video)),
                  if (_perf.running)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: PerfOverlay(monitor: _perf),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static const double _miniVideoWidth = 360;

  static const Map<Section, String> _sectionNames = <Section, String>{
    Section.live: 'Canais ao vivo',
    Section.movies: 'Filmes',
    Section.series: 'Séries',
  };

  Future<void> _pickCategory(
    List<String> groups,
    Map<String, int> counts,
  ) async {
    final UserData? user = _user;
    if (user == null) return;
    bool isHidden(String g) => user.hiddenGroups(_section).contains(g);
    final CategoryChoice? c = await showCategoryPicker(
      context,
      title: 'Categorias · ${_sectionNames[_section]}',
      groups: groups,
      counts: counts,
      selected: _group,
      isHidden: isHidden,
      onToggleHidden: (String g) => _toggleGroup(g, isHidden(g)),
    );
    if (c == null || !mounted) return;
    setState(() {
      _group = c.group;
      _setQuery('');
    });
  }

  /// Nome da ordem na seção atual ("recentes" quer dizer coisas diferentes
  /// em filmes e séries).
  String _sortLabel(SortMode m) => switch ((m, _section)) {
    (SortMode.recent, Section.series) =>
      'Adicionadas ou atualizadas recentemente',
    (SortMode.recent, _) => 'Adicionados recentemente',
    _ => m.label,
  };

  Widget _sortMenu() {
    final ThemeData t = Theme.of(context);
    final SortMode cur = _sorts[_section] ?? SortMode.listOrder;
    return PopupMenuButton<SortMode>(
      tooltip: 'Ordenar: ${_sortLabel(cur)}',
      icon: const Icon(Icons.sort),
      style: IconButton.styleFrom(
        backgroundColor: t.colorScheme.secondaryContainer,
        foregroundColor: t.colorScheme.onSecondaryContainer,
      ),
      onSelected: _setSort,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<SortMode>>[
        for (final SortMode m in SortMode.values)
          if (!m.needsMeta || _section != Section.live)
            CheckedPopupMenuItem<SortMode>(
              value: m,
              enabled: !m.needsMeta || _hasMeta,
              checked: cur == m,
              child: Text(
                (m.needsMeta && !_hasMeta)
                    ? '${_sortLabel(m)} (${_metaBusy ? 'carregando...' : 'indisponível'})'
                    : _sortLabel(m),
              ),
            ),
      ],
    );
  }

  Widget _sectionPicker() {
    return SegmentedButton<Section>(
      showSelectedIcon: false,
      segments: const <ButtonSegment<Section>>[
        ButtonSegment<Section>(
          value: Section.live,
          icon: Icon(Icons.live_tv),
          tooltip: 'Ao vivo',
        ),
        ButtonSegment<Section>(
          value: Section.movies,
          icon: Icon(Icons.movie_outlined),
          tooltip: 'Filmes',
        ),
        ButtonSegment<Section>(
          value: Section.series,
          icon: Icon(Icons.video_library_outlined),
          tooltip: 'Séries',
        ),
      ],
      selected: <Section>{_section},
      onSelectionChanged: (Set<Section> s) => setState(() {
        _section = s.first;
        _group = null;
        _setQuery('');
      }),
    );
  }

  Widget _itemColumn(
    List<Channel> items,
    Set<String> hiddenItems, {
    required List<String> groups,
    required Map<String, int> counts,
  }) {
    final ThemeData t = Theme.of(context);
    final bool live = _section == Section.live;
    final int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    Widget liveTile(BuildContext context, int i) {
      final Channel c = items[i];
      final bool hidden = _isHidden(c, hiddenItems);
      return LiveTile(
        key: ValueKey<String>(c.url),
        channel: c,
        selected: c.url == _playingUrl,
        hidden: hidden,
        nowSecs: now,
        current: _epg?.nowNext(c.tvgId, now, name: c.name).$1,
        onTap: () => _play(c),
        onToggleHidden: () => _toggleItem(c, hidden),
      );
    }

    Widget body;
    if (items.isEmpty) {
      body = const Center(child: Text('Nada por aqui'));
    } else if (live && !_wide) {
      body = ListView.builder(itemCount: items.length, itemBuilder: liveTile);
    } else if (live) {
      // Ampliada: canais em colunas.
      body = GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 420,
          mainAxisExtent: 84,
        ),
        itemCount: items.length,
        itemBuilder: liveTile,
      );
    } else {
      final List<Channel> recent = _query.isEmpty
          ? (_user?.recent(_section) ?? const <Channel>[])
          : const <Channel>[];
      body = CustomScrollView(
        slivers: <Widget>[
          if (recent.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              sliver: SliverToBoxAdapter(child: _recentRow(recent)),
            ),
          SliverPadding(
            padding: const EdgeInsets.all(8),
            sliver: SliverGrid.builder(
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
            ),
          ),
        ],
      );
    }

    final String? group = _group;
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Row(
            children: <Widget>[
              _sectionPicker(),
              const SizedBox(width: 8),
              Expanded(
                child: CategoryButton(
                  label: group ?? 'Todas as categorias',
                  count: group == null
                      ? counts.values.fold<int>(0, (int a, int b) => a + b)
                      : counts[group],
                  onPressed: () => _pickCategory(groups, counts),
                ),
              ),
              const SizedBox(width: 4),
              _sortMenu(),
              const SizedBox(width: 4),
              IconButton.filledTonal(
                tooltip: _wide
                    ? 'Reduzir a lista (vídeo grande)'
                    : 'Ampliar a lista (vídeo pequeno)',
                icon: Icon(_wide ? Icons.close_fullscreen : Icons.open_in_full),
                onPressed: () => setState(() => _wide = !_wide),
              ),
            ],
          ),
        ),
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
        if (_epgStatus != null && live)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
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
}
