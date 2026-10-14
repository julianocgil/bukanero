import 'package:flutter_test/flutter_test.dart';
import 'package:meu_iptv/data/m3u/m3u_parser.dart';

void main() {
  test('lê atributos e nome', () async {
    const String text = '''
#EXTM3U
#EXTINF:-1 tvg-id="cnn" tvg-logo="http://x/l.png" group-title="Noticias",CNN Brasil
http://srv/live/1.ts
''';
    final list = await parseM3uText(text).toList();
    expect(list, hasLength(1));
    expect(list.first.name, 'CNN Brasil');
    expect(list.first.group, 'Noticias');
    expect(list.first.logo, 'http://x/l.png');
    expect(list.first.tvgId, 'cnn');
    expect(list.first.url, 'http://srv/live/1.ts');
  });

  test('vírgula no nome do canal', () async {
    const String text = '#EXTINF:-1 group-title="A",Canal, HD\nhttp://s/2\n';
    final list = await parseM3uText(text).toList();
    expect(list.first.name, 'HD');
  });

  test('ignora diretivas desconhecidas e linhas em branco', () async {
    const String text = '''
#EXTM3U

#EXTINF:-1,Um
#EXTVLCOPT:http-user-agent=x
http://s/1

#EXTINF:-1,Dois
http://s/2
''';
    final list = await parseM3uText(text).toList();
    expect(list.map((c) => c.name), <String>['Um', 'Dois']);
  });

  test('usa #EXTGRP quando não há group-title', () async {
    const String text = '#EXTINF:-1,Canal\n#EXTGRP:Filmes\nhttp://s/1\n';
    final list = await parseM3uText(text).toList();
    expect(list.first.group, 'Filmes');
  });

  test('URL solta sem EXTINF é descartada', () async {
    const String text = 'http://s/solta\n#EXTINF:-1,Ok\nhttp://s/ok\n';
    final list = await parseM3uText(text).toList();
    expect(list, hasLength(1));
    expect(list.first.name, 'Ok');
  });
}
