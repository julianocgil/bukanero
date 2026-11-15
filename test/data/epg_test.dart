import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:bukanero/data/catalog_db.dart';
import 'package:bukanero/data/epg.dart';
import 'package:bukanero/data/metadata.dart';
import 'package:bukanero/data/user_data.dart';
import 'package:bukanero/domain/section.dart';

String _xmltv(DateTime t) {
  String two(int n) => n.toString().padLeft(2, '0');
  final DateTime u = t.toUtc();
  return '${u.year}${two(u.month)}${two(u.day)}'
      '${two(u.hour)}${two(u.minute)}${two(u.second)} +0000';
}

void main() {
  test('URL do guia no cabeçalho do M3U', () {
    expect(
      epgUrlsFromHeader('#EXTM3U url-tvg="http://a/x.xml, https://b/y.xml.gz"'),
      <String>['http://a/x.xml', 'https://b/y.xml.gz'],
    );
    expect(epgUrlsFromHeader('#EXTM3U x-tvg-url="http://a/x.xml"'), <String>[
      'http://a/x.xml',
    ]);
    expect(epgUrlsFromHeader('#EXTM3U'), isEmpty);
  });

  test('xmltv do servidor da lista (Xtream)', () {
    final ApiAccess? fromGet = deriveApiAccess(
      'http://h:8080/get.php?username=u&password=p&type=m3u_plus',
      null,
    );
    expect(xmltvUrl(fromGet!), 'http://h:8080/xmltv.php?username=u&password=p');
    final ApiAccess? fromItem = deriveApiAccess(
      'http://h/lista.m3u',
      'http://h:8080/live/u/p/1.ts',
    );
    expect(
      xmltvUrl(fromItem!),
      'http://h:8080/xmltv.php?username=u&password=p',
    );
    expect(deriveApiAccess('http://h/lista.m3u', null), isNull);
  });

  test('hora XMLTV respeita o fuso', () {
    final int utc = parseXmltvTime('20261015120000 +0000')!;
    expect(parseXmltvTime('20261015120000 -0300')! - utc, 3 * 3600);
  });

  test('importa o guia e acha o programa atual', () async {
    final Directory dir = Directory.systemTemp.createTempSync('bukanero');
    addTearDown(() => dir.deleteSync(recursive: true));
    final DateTime now = DateTime.now();
    final String past = _xmltv(now.subtract(const Duration(hours: 1)));
    final String h1 = _xmltv(now.add(const Duration(hours: 1)));
    final String h2 = _xmltv(now.add(const Duration(hours: 2)));
    final File xml = File('${dir.path}/g.xml')
      ..writeAsStringSync('''<?xml version="1.0" encoding="UTF-8"?>
<tv>
  <channel id="Canal.A"><display-name>A</display-name></channel>
  <programme start="$past" stop="$h1" channel="Canal.A">
    <title>Agora</title><desc>Descricao</desc>
  </programme>
  <programme start="$h1" stop="$h2" channel="Canal.A">
    <title>Depois</title>
  </programme>
</tv>
''');
    final String dbPath = '${dir.path}/e.db';
    expect(await importEpg(<String>[xml.path], dbPath), 2);

    final EpgDb epg = EpgDb.tryOpen(dbPath)!;
    addTearDown(epg.close);
    final (Programme? cur, Programme? next) = epg.nowNext(
      'canal.a',
      now.millisecondsSinceEpoch ~/ 1000,
    );
    expect(cur?.title, 'Agora');
    expect(next?.title, 'Depois');
    expect(epg.channelIds(), <String>{'canal.a'});
  });

  test('duas grades para o mesmo canal: fica a primeira', () async {
    final Directory dir = Directory.systemTemp.createTempSync('bukanero');
    addTearDown(() => dir.deleteSync(recursive: true));
    final DateTime now = DateTime.now();
    String at(int min) => _xmltv(now.add(Duration(minutes: min)));
    final File xml = File('${dir.path}/g.xml')
      ..writeAsStringSync('''<?xml version="1.0" encoding="UTF-8"?>
<tv>
  <channel id="Canal.A"><display-name>A</display-name></channel>
  <programme start="${at(-60)}" stop="${at(30)}" channel="Canal.A">
    <title>Certo</title>
  </programme>
  <programme start="${at(29)}" stop="${at(90)}" channel="Canal.A">
    <title>Depois</title>
  </programme>
  <programme start="${at(-80)}" stop="${at(-5)}" channel="Canal.A">
    <title>Outra grade</title>
  </programme>
  <programme start="${at(-5)}" stop="${at(60)}" channel="Canal.A">
    <title>Adiantado</title>
  </programme>
</tv>
''');
    final String dbPath = '${dir.path}/e.db';
    await importEpg(<String>[xml.path], dbPath);

    final EpgDb epg = EpgDb.tryOpen(dbPath)!;
    addTearDown(epg.close);
    final (Programme? cur, Programme? next) = epg.nowNext(
      'canal.a',
      now.millisecondsSinceEpoch ~/ 1000,
    );
    // O minuto em que "Certo" e "Depois" se encostam não conta.
    expect(cur?.title, 'Certo');
    expect(next?.title, 'Depois');
  });

  test('chave de nome ignora qualidade, acentos e prefixo de país', () {
    expect(epgNameKey('BR: Canal Exemplo FHD'), 'canalexemplo');
    expect(epgNameKey('Canal Exemplo HD [Alt]'), 'canalexemplo');
    expect(epgNameKey('Canal Exemplo (H.265)'), 'canalexemplo');
    expect(epgNameKey('Notícias 24h 4K'), 'noticias24h');
    expect(epgNameKey('HD'), 'hd');
  });

  test('sem tvg-id, liga o canal ao guia pelo nome', () async {
    final Directory dir = Directory.systemTemp.createTempSync('bukanero');
    addTearDown(() => dir.deleteSync(recursive: true));
    final DateTime now = DateTime.now();
    final String past = _xmltv(now.subtract(const Duration(hours: 1)));
    final String h1 = _xmltv(now.add(const Duration(hours: 1)));
    final File xml = File('${dir.path}/g.xml')
      ..writeAsStringSync('''<?xml version="1.0" encoding="UTF-8"?>
<tv>
  <channel id="exemplo.br"><display-name>Canal Exemplo</display-name></channel>
  <channel id="outro.br"><display-name>Outro HD</display-name></channel>
  <programme start="$past" stop="$h1" channel="exemplo.br">
    <title>Jornal</title>
  </programme>
  <programme start="$past" stop="$h1" channel="outro.br">
    <title>Filme</title>
  </programme>
</tv>
''');
    final String dbPath = '${dir.path}/e.db';
    await importEpg(<String>[xml.path], dbPath);

    final EpgDb epg = EpgDb.tryOpen(dbPath)!;
    addTearDown(epg.close);
    expect(epg.hasNames, isTrue);
    final int t = now.millisecondsSinceEpoch ~/ 1000;
    expect(
      epg.nowNext(null, t, name: 'BR: Canal Exemplo FHD').$1?.title,
      'Jornal',
    );
    expect(epg.nowNext('', t, name: 'Outro').$1?.title, 'Filme');
    // tvg-id que não existe no guia cai para o nome.
    expect(epg.nowNext('x', t, name: 'Outro').$1?.title, 'Filme');
    expect(epg.nowNext(null, t, name: 'Sem Guia').$1, isNull);
    expect(
      epg.programmes('exemplo.br', t, t + 60).map((Programme p) => p.title),
      <String>['Jornal'],
    );
    expect(epg.programmes('exemplo.br', t + 7200, t + 9000), isEmpty);
    expect(
      epg.matchCount(<(String?, String)>[
        (null, 'Canal Exemplo HD'),
        ('exemplo.br', 'Qualquer'),
        (null, 'Sem Guia'),
      ]),
      2,
    );
  });

  test('catálogo guarda o guia do cabeçalho e exclui ocultos', () async {
    final Directory dir = Directory.systemTemp.createTempSync('bukanero');
    addTearDown(() => dir.deleteSync(recursive: true));
    final File m3u = File('${dir.path}/a.m3u')
      ..writeAsStringSync('''
#EXTM3U url-tvg="http://a/x.xml"
#EXTINF:-1 tvg-id="CNN" group-title="Canais | A",Um
http://s/1
#EXTINF:-1 group-title="Canais | A",Dois
http://s/2
''');
    final String dbPath = '${dir.path}/c.db';
    await importCatalog(m3u.path, dbPath);
    final CatalogDb db = CatalogDb.open(dbPath);
    addTearDown(db.close);
    expect(db.epgUrls(), <String>['http://a/x.xml']);
    expect(db.liveChannels(), <(String?, String)>[
      ('CNN', 'Um'),
      (null, 'Dois'),
    ]);
    final names = db
        .items(Section.live, 'Canais | A', '', exclude: <String>{'Um'})
        .map((c) => c.name)
        .toList();
    expect(names, <String>['Dois']);
  });

  test('ocultar e reexibir', () {
    final Directory dir = Directory.systemTemp.createTempSync('bukanero');
    addTearDown(() => dir.deleteSync(recursive: true));
    final UserData u = UserData.open('${dir.path}/u.db');
    addTearDown(u.close);
    u.setGroupHidden(Section.live, 'G', hidden: true);
    u.setItemHidden(Section.movies, 'F', 'Filme', hidden: true);
    expect(u.hiddenGroups(Section.live), <String>{'G'});
    expect(u.hiddenItems(Section.movies, 'F'), <String>{'Filme'});
    u.setItemHidden(Section.movies, 'F', 'Filme', hidden: false);
    expect(u.hiddenItems(Section.movies, 'F'), isEmpty);
  });
}
