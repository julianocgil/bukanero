// Relatório do agrupamento sobre a lista real do perfil, para revisão.
// Mostra só nomes e contagens (nunca endereços).
//
//   dart run tool/group_report.dart <pasta de dados> > relatorio.txt
import 'dart:io';
import 'dart:math';

import 'package:bukanero/data/epg.dart';
import 'package:bukanero/domain/grouping.dart';
import 'package:bukanero/domain/stream_id.dart';
import 'package:sqlite3/sqlite3.dart';

void main(List<String> args) {
  final Directory dir = Directory(args.first);
  final String catPath = dir
      .listSync()
      .whereType<File>()
      .firstWhere((File f) => f.path.contains('/catalog_'))
      .path;
  final String id = catPath.split('catalog_').last.replaceAll('.db', '');
  final Database cat = sqlite3.open(catPath, mode: OpenMode.readOnly);
  final EpgDb? epg = EpgDb.tryOpen('${dir.path}/epg_$id.db');
  final Map<int, int> tmdb = <int, int>{};
  // Sem TMDB, a nota + o ano do servidor servem para conferir filmes:
  // versões do mesmo filme coincidem nos dois; filmes diferentes, quase nunca.
  final Map<int, String> rated = <int, String>{};
  final File meta = File('${dir.path}/meta_$id.db');
  if (meta.existsSync()) {
    final Database m = sqlite3.open(meta.path, mode: OpenMode.readOnly);
    final bool has = m
        .select('PRAGMA table_info(vod)')
        .any((Row r) => r['name'] == 'tmdb');
    if (has) {
      for (final Row r in m.select(
        'SELECT vod_id, tmdb FROM vod WHERE tmdb IS NOT NULL',
      )) {
        tmdb[r['vod_id'] as int] = r['tmdb'] as int;
      }
    }
    for (final Row r in m.select(
      'SELECT vod_id, year FROM vod WHERE year IS NOT NULL',
    )) {
      if (r['year'] != null) rated[r['vod_id'] as int] = '${r['year']}';
    }
    m.close();
  }
  final Random rnd = Random(7);

  for (final (int section, String label) in <(int, String)>[
    (0, 'CANAIS AO VIVO'),
    (1, 'FILMES'),
  ]) {
    final bool movies = section == 1;
    final ResultSet rs = cat.select(
      'SELECT id, name, url, logo, tvg_id FROM items WHERE section = ?',
      <Object?>[section],
    );
    final Map<int, String> names = <int, String>{};
    final Map<int, String?> checkEpg = <int, String?>{};
    final Map<int, Object?> checkTmdb = <int, Object?>{};
    final List<GroupItem> blind = <GroupItem>[];
    final List<GroupItem> full = <GroupItem>[];
    for (final Row r in rs) {
      final int i = r['id'] as int;
      final String name = r['name'] as String;
      names[i] = name;
      final String? e = movies
          ? null
          : epg?.channelFor(r['tvg_id'] as String?, name);
      final int? sid = streamIdFromUrl(r['url'] as String);
      final int? t = movies && sid != null ? tmdb[sid] : null;
      checkEpg[i] = e;
      checkTmdb[i] = t ?? (movies && sid != null ? rated[sid] : null);
      blind.add(
        GroupItem(
          id: i,
          name: name,
          logo: r['logo'] as String?,
          tvgId: r['tvg_id'] as String?,
        ),
      );
      full.add(
        GroupItem(
          id: i,
          name: name,
          logo: r['logo'] as String?,
          tvgId: r['tvg_id'] as String?,
          epg: e,
          tmdb: t,
        ),
      );
    }

    stdout.writeln('\n================ $label: ${rs.length} itens');

    // Conferência: agrupa sem guia/TMDB e mede com eles.
    final GroupingResult b = groupItems(blind, movies: movies);
    int agree = 0;
    int disagree = 0;
    int groupsWithError = 0;
    final List<List<String>> wrong = <List<String>>[];
    for (final ItemGroup g in b.groups) {
      final List<Object> marks = <Object>[
        for (final int i in g.ids)
          if ((movies ? checkTmdb[i] : checkEpg[i]) != null)
            (movies ? checkTmdb[i] : checkEpg[i])!,
      ];
      bool bad = false;
      for (int x = 0; x < marks.length; x++) {
        for (int y = x + 1; y < marks.length; y++) {
          if (marks[x] == marks[y]) {
            agree++;
          } else {
            disagree++;
            bad = true;
          }
        }
      }
      if (bad) {
        groupsWithError++;
        if (wrong.length < 12) {
          wrong.add(<String>[for (final int i in g.ids.take(6)) names[i]!]);
        }
      }
    }
    final String src = movies
        ? (tmdb.isEmpty ? 'ano do servidor' : 'TMDB')
        : 'guia (EPG)';
    stdout.writeln(
      'Conferência às cegas (sem $src para agrupar, $src só para medir):',
    );
    stdout.writeln(
      '  pares conferíveis: ${agree + disagree} · certos: $agree · '
      'errados: $disagree'
      '${agree + disagree > 0 ? ' · acerto ${(100 * agree / (agree + disagree)).toStringAsFixed(1)}%' : ''}',
    );
    stdout.writeln(
      '  grupos com algum erro: $groupsWithError de ${b.groups.length}',
    );
    for (final List<String> w in wrong) {
      stdout.writeln('    ✗ $w');
    }

    // Resultado final, com todos os sinais.
    final GroupingResult r = groupItems(full, movies: movies);
    final int grouped = r.groups.fold<int>(
      0,
      (int a, ItemGroup g) => a + g.ids.length,
    );
    final int familyMerges = r.families.fold<int>(
      0,
      (int a, ItemFamily f) => a + f.groups.length - 1,
    );
    final int cards = rs.length - grouped + r.groups.length - familyMerges;
    stdout.writeln('\nResultado final (todos os sinais):');
    stdout.writeln(
      '  ${r.groups.length} grupos juntando $grouped itens · '
      '${r.families.length} famílias · cartões: ${rs.length} → $cards',
    );
    stdout.writeln(
      '  grupos com sinal forte: ${r.groups.where((ItemGroup g) => g.strong).length}'
      ' · só sinais médios: ${r.groups.where((ItemGroup g) => !g.strong).length}',
    );
    stdout.writeln(
      '  imagens genéricas: ${r.genericLogos.length} · '
      'palavras de versão aprendidas: ${(r.variantWords.toList()..sort()).join(', ')}',
    );

    void sample(String title, Iterable<ItemGroup> from, int n) {
      final List<ItemGroup> l = from.toList()..shuffle(rnd);
      stdout.writeln(
        '\n  $title (${l.length}; amostra de ${min(n, l.length)}):',
      );
      for (final ItemGroup g in l.take(n)) {
        stdout.writeln(
          '    • ${[for (final int i in g.ids.take(7)) names[i]]}'
          '${g.ids.length > 7 ? ' +${g.ids.length - 7}' : ''}  ← ${g.reasons.join(', ')}',
        );
      }
    }

    sample(
      'No limite: só sinais médios',
      r.groups.where((ItemGroup g) => !g.strong),
      15,
    );
    sample('Com sinal forte', r.groups.where((ItemGroup g) => g.strong), 10);
    final List<ItemGroup> biggest = List<ItemGroup>.of(
      r.groups,
    )..sort((ItemGroup a, ItemGroup b) => b.ids.length.compareTo(a.ids.length));
    sample('Maiores grupos', biggest.take(8), 8);
    if (r.families.isNotEmpty) {
      stdout.writeln('\n  Famílias (amostra):');
      for (final ItemFamily f in r.families.take(10)) {
        stdout.writeln(
          '    • ${[for (final int gi in f.groups) names[r.groups[gi].ids.first]]}',
        );
      }
    }
  }
  cat.close();
  epg?.close();
}
