import 'dart:io';
import 'dart:isolate';

import 'package:bukanero/data/bandwidth.dart';
import 'package:bukanero/data/download.dart';
import 'package:bukanero/data/epg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(VideoPriority.resetForTest);

  test('dá a vez ao vídeo com pouca reserva, com folga para voltar', () {
    VideoPriority.update(playing: true, buffering: false, reserveSecs: 20);
    expect(VideoPriority.videoActive, isTrue);
    expect(VideoPriority.yielding, isFalse);
    VideoPriority.update(playing: true, buffering: false, reserveSecs: 2);
    expect(VideoPriority.yielding, isTrue);
    // Entre os dois limites, mantém o estado.
    VideoPriority.update(playing: true, buffering: false, reserveSecs: 6);
    expect(VideoPriority.yielding, isTrue);
    VideoPriority.update(playing: true, buffering: false, reserveSecs: 9);
    expect(VideoPriority.yielding, isFalse);
    VideoPriority.update(playing: true, buffering: true, reserveSecs: 30);
    expect(VideoPriority.yielding, isTrue);
    VideoPriority.update(playing: false, buffering: false);
    expect(VideoPriority.yielding, isFalse);
    expect(VideoPriority.videoActive, isFalse);
  });

  test('espera cancelada lança DownloadCancelled', () async {
    VideoPriority.update(playing: true, buffering: true);
    bool cancel = false;
    final Future<void> wait = VideoPriority.waitTurn(cancelled: () => cancel);
    cancel = true;
    await expectLater(wait, throwsA(isA<DownloadCancelled>()));
  });

  test('fila roda uma tarefa de cada vez, na ordem', () async {
    final SerialJobs jobs = SerialJobs();
    final List<String> log = <String>[];
    Future<void> job(String n, int ms) async {
      log.add('início $n');
      await Future<void>.delayed(Duration(milliseconds: ms));
      log.add('fim $n');
    }

    await Future.wait(<Future<void>>[
      jobs.run(() => job('a', 50)),
      jobs.run(() => job('b', 10)),
    ]);
    expect(log, <String>['início a', 'fim a', 'início b', 'fim b']);
    // Uma tarefa que falha não trava a fila.
    await expectLater(
      jobs.run<void>(() async => throw StateError('x')),
      throwsStateError,
    );
    expect(await jobs.run(() async => 7), 7);
  });

  group('downloads com pausa', () {
    late Directory dir;
    late HttpServer server;

    setUp(() async {
      dir = Directory.systemTemp.createTempSync('bukanero');
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((HttpRequest req) async {
        req.response.bufferOutput = false;
        if (req.uri.path.endsWith('.xml')) {
          req.response.write(
            '<?xml version="1.0"?><tv>'
            '<channel id="a"><display-name>Canal A</display-name></channel>'
            '</tv>',
          );
        } else {
          for (int i = 0; i < 5; i++) {
            req.response.write('linha $i\n');
            await req.response.flush();
          }
        }
        await req.response.close();
      });
    });
    tearDown(() async {
      await server.close(force: true);
      dir.deleteSync(recursive: true);
    });

    String url(String p) => 'http://127.0.0.1:${server.port}/$p';

    test('pausa longa no gate não conta como servidor parado', () async {
      final File dest = File('${dir.path}/l.m3u');
      int calls = 0;
      await downloadFile(
        url('l.m3u'),
        dest,
        limits: const DownloadLimits(
          idle: Duration(milliseconds: 300),
          slowWindow: Duration(milliseconds: 200),
          slowMinBytes: 1,
        ),
        gate: () async {
          calls++;
          await Future<void>.delayed(const Duration(milliseconds: 500));
        },
      );
      expect(dest.readAsStringSync(), contains('linha 4'));
      expect(calls, greaterThan(1));
    });

    test('gate cancelado para o download e não troca o arquivo', () async {
      final File dest = File('${dir.path}/l.m3u')..writeAsStringSync('ANTES');
      await expectLater(
        downloadFile(
          url('l.m3u'),
          dest,
          gate: () async => throw const DownloadCancelled(),
        ),
        throwsA(isA<DownloadCancelled>()),
      );
      expect(dest.readAsStringSync(), 'ANTES');
    });

    test('guia baixa com gate que não pode ir para outro isolate', () async {
      // Um ReceivePort não pode ser enviado entre isolates: se o gate fosse
      // junto para o isolate da leitura, isto falharia.
      final ReceivePort port = ReceivePort();
      addTearDown(port.close);
      final String db = '${dir.path}/e.db';
      final int n = await importEpg(
        <String>[url('g.xml')],
        db,
        gate: () async => port.sendPort,
      );
      expect(n, 0); // guia de teste sem programas
      expect(EpgDb.tryOpen(db)?.hasNames, isTrue);
    });
  });
}
