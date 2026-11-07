import 'dart:io';

import 'profile_store.dart';

const int _maxLogBytes = 5 * 1024 * 1024;

/// Uma medição de desempenho (um segundo de reprodução).
///
/// Não guarda nome de canal nem endereço: só números.
class PerfSample {
  const PerfSample({
    required this.time,
    required this.uiFrames,
    required this.uiSlow,
    required this.uiWorstMs,
    required this.buffering,
    this.videoFps,
    this.sourceFps,
    this.voDrops,
    this.decoderDrops,
    this.cacheSecs,
    this.avsyncMs,
    this.hwdec,
  });

  final DateTime time;

  /// Quadros que a interface desenhou neste segundo.
  final int uiFrames;

  /// Quadros da interface que passaram de 17 ms (abaixo de 60 FPS).
  final int uiSlow;
  final double uiWorstMs;

  /// FPS real do vídeo na saída do mpv e o FPS informado pela fonte.
  final double? videoFps;
  final double? sourceFps;

  /// Quadros descartados neste segundo (saída de vídeo e decodificador).
  final int? voDrops;
  final int? decoderDrops;

  /// Segundos de vídeo já baixados à frente da posição atual.
  final double? cacheSecs;
  final bool buffering;
  final double? avsyncMs;

  /// Decodificação por hardware em uso (`no` quando é por software).
  final String? hwdec;

  static const String csvHeader =
      'hora,ui_fps,ui_lentos,ui_pior_ms,video_fps,fonte_fps,'
      'descartes_vo,descartes_decoder,reserva_s,carregando,hwdec,avsync_ms';

  String toCsv() {
    String n(num? v, [int digits = 1]) =>
        v == null ? '' : v.toStringAsFixed(digits);
    final String hw = (hwdec ?? '').replaceAll(RegExp(r'[^a-z0-9-]'), '');
    return <String>[
      time.toIso8601String(),
      '$uiFrames',
      '$uiSlow',
      n(uiWorstMs),
      n(videoFps),
      n(sourceFps),
      voDrops?.toString() ?? '',
      decoderDrops?.toString() ?? '',
      n(cacheSecs),
      buffering ? '1' : '0',
      hw,
      n(avsyncMs),
    ].join(',');
  }
}

File perfLogFile() => File('${dataDir().path}/desempenho.csv');

/// Grava as medições em CSV, trocando de arquivo quando passa de 5 MB.
class PerfLog {
  PerfLog._(this.file, this._sink);

  factory PerfLog.open([File? target]) {
    final File f = target ?? perfLogFile();
    if (f.existsSync() && f.lengthSync() > _maxLogBytes) {
      f.renameSync(f.path.replaceFirst(RegExp(r'\.csv$'), '.1.csv'));
    }
    final bool fresh = !f.existsSync() || f.lengthSync() == 0;
    final IOSink sink = f.openWrite(mode: FileMode.append);
    if (fresh) sink.writeln(PerfSample.csvHeader);
    return PerfLog._(f, sink);
  }

  final File file;
  final IOSink _sink;

  void add(PerfSample s) => _sink.writeln(s.toCsv());

  Future<void> close() => _sink.close();
}
