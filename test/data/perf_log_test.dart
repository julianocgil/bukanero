import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:bukanero/data/perf_log.dart';

void main() {
  test('linha CSV só com números e hwdec limpo', () {
    final PerfSample s = PerfSample(
      time: DateTime.utc(2026, 1, 2, 3, 4, 5),
      uiFrames: 58,
      uiSlow: 3,
      uiWorstMs: 41.26,
      buffering: true,
      videoFps: 29.97,
      sourceFps: 30,
      voDrops: 2,
      decoderDrops: 0,
      cacheSecs: 1.5,
      avsyncMs: -12.4,
      hwdec: 'vaapi,"x"',
    );
    final String line = s.toCsv();
    expect(
      line,
      '2026-01-02T03:04:05.000Z,58,3,41.3,30.0,30.0,2,0,1.5,1,vaapix,-12.4',
    );
    expect(line.split(',').length, PerfSample.csvHeader.split(',').length);
  });

  test('campos ausentes ficam vazios', () {
    final PerfSample s = PerfSample(
      time: DateTime.utc(2026),
      uiFrames: 0,
      uiSlow: 0,
      uiWorstMs: 0,
      buffering: false,
    );
    expect(s.toCsv(), '2026-01-01T00:00:00.000Z,0,0,0.0,,,,,,0,,');
  });

  test('arquivo novo ganha cabeçalho e o grande é trocado', () async {
    final Directory dir = Directory.systemTemp.createTempSync('bukanero');
    addTearDown(() => dir.deleteSync(recursive: true));
    final File f = File('${dir.path}/desempenho.csv');
    final PerfLog a = PerfLog.open(f);
    a.add(
      PerfSample(
        time: DateTime.utc(2026),
        uiFrames: 1,
        uiSlow: 0,
        uiWorstMs: 1,
        buffering: false,
      ),
    );
    await a.close();
    expect(f.readAsLinesSync().first, PerfSample.csvHeader);
    expect(f.readAsLinesSync().length, 2);

    f.writeAsStringSync('x' * (6 * 1024 * 1024));
    final PerfLog b = PerfLog.open(f);
    await b.close();
    expect(File('${dir.path}/desempenho.1.csv').existsSync(), isTrue);
    expect(f.readAsLinesSync(), <String>[PerfSample.csvHeader]);
  });
}
