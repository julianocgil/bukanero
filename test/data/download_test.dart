import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:bukanero/data/download.dart';

/// Servidor local fictício; [handle] decide como responder.
Future<HttpServer> _serve(Future<void> Function(HttpResponse) handle) async {
  final HttpServer server = await HttpServer.bind(
    InternetAddress.loopbackIPv4,
    0,
  );
  // Sem buffer: cada flush sai na hora, como num servidor lento de verdade.
  server.listen(
    (HttpRequest req) => handle(req.response..bufferOutput = false),
  );
  return server;
}

String _url(HttpServer s) => 'http://127.0.0.1:${s.port}/lista.m3u';

const DownloadLimits _fast = DownloadLimits(
  idle: Duration(milliseconds: 400),
  slowWindow: Duration(milliseconds: 300),
  slowMinBytes: 1000,
  total: Duration(seconds: 5),
);

void main() {
  late Directory dir;
  late File dest;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('bukanero');
    dest = File('${dir.path}/lista.m3u')..writeAsStringSync('ANTERIOR');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  test('baixa inteiro e informa o progresso', () async {
    final HttpServer ok = await _serve((HttpResponse r) async {
      r.contentLength = 7;
      r.write('#EXTM3U');
      await r.close();
    });
    addTearDown(ok.close);
    final List<(int, int?)> seen = <(int, int?)>[];
    await downloadFile(
      _url(ok),
      dest,
      onProgress: (int got, int? total) => seen.add((got, total)),
      limits: _fast,
    );
    expect(dest.readAsStringSync(), '#EXTM3U');
    expect(seen.last, (7, 7));
  });

  test(
    'servidor que para no meio: desiste e mantém a lista anterior',
    () async {
      final HttpServer s = await _serve((HttpResponse r) async {
        r.write('#EXTM3U\n');
        await r.flush();
        await Future<void>.delayed(const Duration(seconds: 3));
        await r.close();
      });
      addTearDown(() => s.close(force: true));
      await expectLater(
        downloadFile(_url(s), dest, limits: _fast),
        throwsA(
          isA<DownloadException>().having(
            (DownloadException e) => e.message,
            'message',
            contains('parou de responder'),
          ),
        ),
      );
      expect(dest.readAsStringSync(), 'ANTERIOR');
    },
  );

  test('servidor lento demais: desiste', () async {
    final HttpServer s = await _serve((HttpResponse r) async {
      // Um byte a cada 100 ms: nunca fica parado, mas é lento demais.
      for (int i = 0; i < 40; i++) {
        r.write('x');
        await r.flush();
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      await r.close();
    });
    addTearDown(() => s.close(force: true));
    await expectLater(
      downloadFile(_url(s), dest, limits: _fast),
      throwsA(
        isA<DownloadException>().having(
          (DownloadException e) => e.message,
          'message',
          contains('devagar'),
        ),
      ),
    );
    expect(dest.readAsStringSync(), 'ANTERIOR');
  });

  test('conexão fecha antes do fim: incompleto', () async {
    // Servidor TCP cru: promete 1000 bytes, manda 8 e fecha.
    final ServerSocket raw = await ServerSocket.bind(
      InternetAddress.loopbackIPv4,
      0,
    );
    addTearDown(raw.close);
    raw.listen((Socket sock) {
      sock.listen((List<int> _) async {
        sock.write(
          'HTTP/1.1 200 OK\r\nContent-Length: 1000\r\n'
          'Connection: close\r\n\r\n#EXTM3U\n',
        );
        await sock.flush();
        await sock.close();
      });
    });
    await expectLater(
      downloadFile(
        'http://127.0.0.1:${raw.port}/lista.m3u',
        dest,
        limits: _fast,
      ),
      throwsA(
        isA<DownloadException>().having(
          (DownloadException e) => e.message,
          'message',
          contains('incompleto'),
        ),
      ),
    );
    expect(dest.readAsStringSync(), 'ANTERIOR');
  });
}
