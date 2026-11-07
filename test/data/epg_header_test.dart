import 'package:flutter_test/flutter_test.dart';
import 'package:bukanero/data/epg.dart';

void main() {
  test('aceita nomes variados de atributo de guia', () {
    expect(epgUrlsFromHeader('#EXTM3U epg-url="http://a/g.xml"'), <String>[
      'http://a/g.xml',
    ]);
    expect(epgUrlsFromHeader('#EXTM3U x-tvg-url="http://a/g.xml.gz"'), <String>[
      'http://a/g.xml.gz',
    ]);
  });

  test('ignora atributos sem relação com guia', () {
    expect(epgUrlsFromHeader('#EXTM3U logo="http://a/l.png"'), isEmpty);
  });
}
