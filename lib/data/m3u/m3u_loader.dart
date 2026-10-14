import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import '../../domain/channel.dart';
import '../../domain/section.dart';
import 'm3u_parser.dart';

/// Seção -> categoria -> itens.
typedef Catalog = Map<Section, Map<String, List<Channel>>>;

/// Lê o arquivo M3U num Isolate e organiza por seção e categoria.
Future<Catalog> loadM3u(String path) {
  return Isolate.run<Catalog>(() async {
    final Stream<String> lines = File(path)
        .openRead()
        .transform(const Utf8Decoder(allowMalformed: true))
        .transform(const LineSplitter());
    final Catalog data = <Section, Map<String, List<Channel>>>{
      for (final Section s in Section.values) s: <String, List<Channel>>{},
    };
    await for (final Channel c in parseM3u(lines)) {
      final Map<String, List<Channel>> groups = data[classify(c)]!;
      (groups[c.group ?? '(sem grupo)'] ??= <Channel>[]).add(c);
    }
    return data;
  });
}
