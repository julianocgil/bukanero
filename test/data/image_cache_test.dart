import 'dart:io';

import 'package:bukanero/data/image_cache.dart';
import 'package:bukanero/data/profile_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dir;
  late HttpServer server;
  int hits = 0;

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('bukanero');
    useDataDirForTest(dir);
    resetImageCacheForTest();
    hits = 0;
    // Servidor local fictício que devolve uma "imagem" qualquer.
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((HttpRequest req) async {
      hits++;
      req.response.add(List<int>.filled(64, 7));
      await req.response.close();
    });
  });
  tearDown(() async {
    await server.close(force: true);
    dir.deleteSync(recursive: true);
  });

  String url(String name) => 'http://127.0.0.1:${server.port}/$name.jpg';

  test('baixa uma vez e depois usa o disco na hora', () async {
    final File? f = await cachedImage(url('a'));
    expect(f, isNotNull);
    expect(f!.lengthSync(), 64);
    expect(knownCachedImage(url('a'))?.path, f.path);
    expect(await cachedImage(url('a')), isNotNull);
    expect(hits, 1);
  });

  test('capa que saiu da tela não é baixada', () async {
    bool onScreen = true;
    final Future<File?> pending = cachedImage(
      url('b'),
      stillWanted: () => onScreen,
    );
    onScreen = false; // rolou para longe antes do download começar
    expect(await pending, isNull);
    expect(hits, 0);
    expect(knownCachedImage(url('b')), isNull);
  });

  test('outro cartão com a mesma imagem mantém o download', () async {
    final Future<File?> a = cachedImage(url('c'), stillWanted: () => false);
    final Future<File?> b = cachedImage(url('c'), stillWanted: () => true);
    expect(await a, isNotNull);
    expect(await b, isNotNull);
    expect(hits, 1);
  });
}
