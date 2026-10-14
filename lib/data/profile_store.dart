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
  final Directory d = Directory('$base/meu_iptv')..createSync(recursive: true);
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
