import 'dart:convert';
import 'dart:io';

import 'package:bukanero/data/m3u/m3u_parser.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('uso: dart run bin/inspect.dart <arquivo.m3u>');
    exit(64);
  }
  final Stopwatch sw = Stopwatch()..start();
  final Stream<String> lines = File(args.first)
      .openRead()
      .transform(const Utf8Decoder(allowMalformed: true))
      .transform(const LineSplitter());

  int total = 0;
  int semGrupo = 0;
  int semLogo = 0;
  final Map<String, int> grupos = <String, int>{};

  await for (final c in parseM3u(lines)) {
    total++;
    if (c.group == null) semGrupo++;
    if (c.logo == null || c.logo!.isEmpty) semLogo++;
    final String g = c.group ?? '(sem grupo)';
    grupos[g] = (grupos[g] ?? 0) + 1;
  }
  sw.stop();

  stdout.writeln('Itens lidos: $total em ${sw.elapsedMilliseconds} ms');
  stdout.writeln(
    'Grupos: ${grupos.length} | sem grupo: $semGrupo | sem logo: $semLogo',
  );
  final List<MapEntry<String, int>> top = grupos.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  stdout.writeln('Maiores grupos:');
  for (final MapEntry<String, int> e in top.take(15)) {
    stdout.writeln('  ${e.value.toString().padLeft(7)}  ${e.key}');
  }
}
