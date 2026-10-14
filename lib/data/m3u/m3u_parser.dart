import 'dart:convert';

import '../../domain/channel.dart';

final RegExp _attrRegExp = RegExp(r'([\w-]+)="([^"]*)"');

/// Faz o parse de uma playlist M3U/M3U8 em streaming.
///
/// Aceita qualquer fonte de linhas, então funciona tanto com um arquivo
/// grande quanto com texto em memória nos testes.
Stream<Channel> parseM3u(Stream<String> lines) async* {
  Map<String, String> attrs = <String, String>{};
  String? name;
  String? groupFromTag;

  await for (final String raw in lines) {
    final String line = raw.trim();
    if (line.isEmpty || line == '#EXTM3U' || line.startsWith('#EXTM3U ')) {
      continue;
    }

    if (line.startsWith('#EXTINF')) {
      attrs = <String, String>{
        for (final RegExpMatch m in _attrRegExp.allMatches(line))
          m.group(1)!.toLowerCase(): m.group(2)!,
      };
      final int comma = line.lastIndexOf(',');
      name = comma >= 0 ? line.substring(comma + 1).trim() : null;
      groupFromTag = null;
    } else if (line.startsWith('#EXTGRP:')) {
      groupFromTag = line.substring(8).trim();
    } else if (line.startsWith('#')) {
      continue; // outras diretivas (#EXTVLCOPT etc.) são ignoradas
    } else {
      // Linha de URL: fecha o item atual.
      if (name != null || attrs.isNotEmpty) {
        final String displayName = (name != null && name.isNotEmpty)
            ? name
            : (attrs['tvg-name'] ?? line);
        yield Channel(
          name: displayName,
          url: line,
          group: attrs['group-title'] ?? groupFromTag,
          logo: attrs['tvg-logo'],
          tvgId: attrs['tvg-id'],
          tvgName: attrs['tvg-name'],
        );
      }
      attrs = <String, String>{};
      name = null;
      groupFromTag = null;
    }
  }
}

/// Atalho para parsear a partir de texto completo (útil em testes).
Stream<Channel> parseM3uText(String text) =>
    parseM3u(const LineSplitter().bind(Stream<String>.value(text)));
