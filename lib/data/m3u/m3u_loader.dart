import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import '../../domain/channel.dart';
import 'm3u_parser.dart';

/// Lê o arquivo M3U num Isolate e agrupa os itens por categoria.
Future<Map<String, List<Channel>>> loadM3u(String path) {
  return Isolate.run<Map<String, List<Channel>>>(() async {
    final Stream<String> lines = File(path)
        .openRead()
        .transform(const Utf8Decoder(allowMalformed: true))
        .transform(const LineSplitter());
    final Map<String, List<Channel>> map = <String, List<Channel>>{};
    await for (final Channel c in parseM3u(lines)) {
      (map[c.group ?? '(sem grupo)'] ??= <Channel>[]).add(c);
    }
    return map;
  });
}
