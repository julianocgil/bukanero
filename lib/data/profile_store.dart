import 'dart:convert';
import 'dart:io';

import '../domain/profile.dart';

Directory? _cached;

/// Pasta de dados do app, respeitando XDG_DATA_HOME (o Flatpak usa isso).
Directory dataDir() {
  final Directory? c = _cached;
  if (c != null) return c;
  final String? xdg = Platform.environment['XDG_DATA_HOME'];
  final String home = Platform.environment['HOME'] ?? '.';
  final String base = (xdg != null && xdg.isNotEmpty)
      ? xdg
      : '$home/.local/share';
  final Directory d = Directory('$base/bukanero');
  // O app se chamava "Meu IPTV": leva os dados da pasta antiga uma vez.
  final Directory old = Directory('$base/meu_iptv');
  if (!d.existsSync() && old.existsSync()) {
    try {
      old.renameSync(d.path);
    } on FileSystemException {
      // Sem conseguir mover, começa uma pasta nova; a antiga fica intacta.
    }
  }
  d.createSync(recursive: true);
  try {
    Process.runSync('chmod', <String>['700', d.path]);
  } on Object {
    // Sem chmod disponível: segue com as permissões padrão.
  }
  return _cached = d;
}

File _profilesFile() => File('${dataDir().path}/profiles.json');

File playlistCacheFile(Profile p) =>
    File('${dataDir().path}/playlist_${p.id}.m3u');

List<Profile> loadProfiles() {
  final File f = _profilesFile();
  if (!f.existsSync()) return <Profile>[];
  try {
    final Object? raw = jsonDecode(f.readAsStringSync());
    if (raw is! List<Object?>) return <Profile>[];
    return <Profile>[
      for (final Object? e in raw)
        if (e is Map<String, dynamic>) Profile.fromJson(e),
    ];
  } on Object {
    return <Profile>[];
  }
}

void saveProfiles(List<Profile> list) {
  _profilesFile().writeAsStringSync(
    jsonEncode(<Map<String, dynamic>>[
      for (final Profile p in list) p.toJson(),
    ]),
  );
}

void deleteProfileData(Profile p) {
  final File f = playlistCacheFile(p);
  if (f.existsSync()) f.deleteSync();
}

String? loadLastProfileId() {
  final File f = File('${dataDir().path}/last_profile');
  return f.existsSync() ? f.readAsStringSync().trim() : null;
}

void saveLastProfileId(String id) {
  File('${dataDir().path}/last_profile').writeAsStringSync(id);
}

String catalogDbPath(Profile p) => '${dataDir().path}/catalog_${p.id}.db';

void deleteCatalog(Profile p) {
  final File f = File(catalogDbPath(p));
  if (f.existsSync()) f.deleteSync();
}

String userDataPath(Profile p) => '${dataDir().path}/userdata_${p.id}.db';

String epgDbPath(Profile p) => '${dataDir().path}/epg_${p.id}.db';

Directory? _imgDir;

/// Só para testes: usa [d] como pasta de dados (nunca a do usuário).
void useDataDirForTest(Directory d) {
  _cached = d;
  _imgDir = null;
}

Directory imageCacheDir() =>
    _imgDir ??= Directory('${dataDir().path}/img')..createSync(recursive: true);

void deleteEpg(Profile p) {
  final File f = File(epgDbPath(p));
  if (f.existsSync()) f.deleteSync();
}

void deleteUserData(Profile p) {
  final File f = File(userDataPath(p));
  if (f.existsSync()) f.deleteSync();
}

String seriesDbPath(Profile p) => '${dataDir().path}/series_${p.id}.db';

void deleteSeries(Profile p) {
  final File f = File(seriesDbPath(p));
  if (f.existsSync()) f.deleteSync();
}

String metaDbPath(Profile p) => '${dataDir().path}/meta_${p.id}.db';

void deleteMeta(Profile p) {
  final File f = File(metaDbPath(p));
  if (f.existsSync()) f.deleteSync();
}
