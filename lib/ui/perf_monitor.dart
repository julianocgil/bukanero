import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:media_kit/media_kit.dart';

import '../data/perf_log.dart';

const int _historySecs = 60;
const double _slowFrameMs = 17;

/// Mede, a cada segundo, os quadros da interface e o estado do mpv
/// (FPS, descartes, reserva) e grava o histórico em CSV.
class PerfMonitor extends ChangeNotifier {
  PerfMonitor(this.player);

  final Player player;
  final List<PerfSample> history = <PerfSample>[];
  Timer? _timer;
  PerfLog? _log;
  int _frames = 0;
  int _slow = 0;
  double _worst = 0;
  int? _lastVo;
  int? _lastDec;
  bool _sampling = false;

  bool get running => _timer != null;
  String? get logPath => _log?.file.path;

  void toggle() => running ? stop() : start();

  void start() {
    if (running) return;
    history.clear();
    _lastVo = null;
    _lastDec = null;
    _resetFrames();
    _log = PerfLog.open();
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  void stop() {
    if (!running) return;
    _timer?.cancel();
    _timer = null;
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
    unawaited(_log?.close());
    _log = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }

  void _resetFrames() {
    _frames = 0;
    _slow = 0;
    _worst = 0;
  }

  void _onTimings(List<FrameTiming> timings) {
    for (final FrameTiming t in timings) {
      final double ms = t.totalSpan.inMicroseconds / 1000;
      _frames++;
      if (ms > _slowFrameMs) _slow++;
      if (ms > _worst) _worst = ms;
    }
  }

  Future<String?> _prop(String name) async {
    final PlatformPlayer? p = player.platform;
    if (p is! NativePlayer) return null;
    try {
      final String v = await p.getProperty(name);
      return v.isEmpty ? null : v;
    } on Object {
      return null;
    }
  }

  /// Descartes desde a última medição; o contador zera ao trocar de vídeo.
  int? _delta(int? total, int? last) {
    if (total == null) return null;
    if (last == null || total < last) return 0;
    return total - last;
  }

  Future<void> _tick() async {
    if (_sampling) return;
    _sampling = true;
    try {
      final int frames = _frames;
      final int slow = _slow;
      final double worst = _worst;
      _resetFrames();
      final bool active = player.state.playing || player.state.buffering;
      final List<String?> v = active
          ? await Future.wait(<Future<String?>>[
              _prop('estimated-vf-fps'),
              _prop('container-fps'),
              _prop('frame-drop-count'),
              _prop('decoder-frame-drop-count'),
              _prop('demuxer-cache-duration'),
              _prop('paused-for-cache'),
              _prop('avsync'),
              _prop('hwdec-current'),
            ])
          : List<String?>.filled(8, null);
      if (!running) return;
      final int? vo = int.tryParse(v[2] ?? '');
      final int? dec = int.tryParse(v[3] ?? '');
      final double? avsync = double.tryParse(v[6] ?? '');
      final PerfSample s = PerfSample(
        time: DateTime.now(),
        uiFrames: frames,
        uiSlow: slow,
        uiWorstMs: worst,
        videoFps: double.tryParse(v[0] ?? ''),
        sourceFps: double.tryParse(v[1] ?? ''),
        voDrops: _delta(vo, _lastVo),
        decoderDrops: _delta(dec, _lastDec),
        cacheSecs: double.tryParse(v[4] ?? ''),
        buffering: v[5] == 'yes' || player.state.buffering,
        avsyncMs: avsync == null ? null : avsync * 1000,
        hwdec: v[7],
      );
      _lastVo = vo ?? _lastVo;
      _lastDec = dec ?? _lastDec;
      history.add(s);
      if (history.length > _historySecs) history.removeAt(0);
      _log?.add(s);
      notifyListeners();
    } finally {
      _sampling = false;
    }
  }
}

/// Painel sobre o vídeo com os números atuais e o gráfico dos últimos 60 s.
class PerfOverlay extends StatelessWidget {
  const PerfOverlay({required this.monitor, super.key});

  final PerfMonitor monitor;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: monitor,
      builder: (BuildContext context, Widget? _) {
        final PerfSample? s = monitor.history.isEmpty
            ? null
            : monitor.history.last;
        String f(num? v, [int d = 0]) => v == null ? '–' : v.toStringAsFixed(d);
        final int drops = monitor.history.fold<int>(
          0,
          (int a, PerfSample x) => a + (x.voDrops ?? 0) + (x.decoderDrops ?? 0),
        );
        const TextStyle mono = TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: 'monospace',
          height: 1.3,
        );
        return IgnorePointer(
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Interface  ${f(s?.uiFrames)} FPS · ${f(s?.uiSlow)} lentos'
                  ' · pior ${f(s?.uiWorstMs)} ms\n'
                  'Vídeo      ${f(s?.videoFps, 1)} de ${f(s?.sourceFps, 1)} FPS'
                  ' · hw ${s?.hwdec ?? '–'}\n'
                  'Descartes  ${f((s?.voDrops ?? 0) + (s?.decoderDrops ?? 0))}/s'
                  ' · $drops em 60 s\n'
                  'Reserva    ${f(s?.cacheSecs, 1)} s'
                  '${(s?.buffering ?? false) ? ' · CARREGANDO' : ''}'
                  ' · sync ${f(s?.avsyncMs)} ms',
                  style: mono,
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _FpsChart(List<PerfSample>.of(monitor.history)),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'branco: interface · azul: vídeo · vermelho: carregando',
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FpsChart extends CustomPainter {
  _FpsChart(this.samples);

  final List<PerfSample> samples;

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty) return;
    double top = 60;
    for (final PerfSample s in samples) {
      top = math.max(top, s.uiFrames.toDouble());
      top = math.max(top, s.videoFps ?? 0);
    }
    final double dx = size.width / (_historySecs - 1);
    double y(double v) => size.height - (v / top) * size.height;

    final Paint stall = Paint()..color = Colors.red.withValues(alpha: 0.5);
    for (int i = 0; i < samples.length; i++) {
      if (samples[i].buffering) {
        canvas.drawRect(
          Rect.fromLTWH(i * dx - dx / 2, 0, dx, size.height),
          stall,
        );
      }
    }

    void line(double? Function(PerfSample) pick, Color color) {
      final Path p = Path();
      bool started = false;
      for (int i = 0; i < samples.length; i++) {
        final double? v = pick(samples[i]);
        if (v == null) {
          started = false;
          continue;
        }
        if (started) {
          p.lineTo(i * dx, y(v));
        } else {
          p.moveTo(i * dx, y(v));
          started = true;
        }
      }
      canvas.drawPath(
        p,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    line((PerfSample s) => s.uiFrames.toDouble(), Colors.white);
    line((PerfSample s) => s.videoFps, Colors.lightBlueAccent);
  }

  @override
  bool shouldRepaint(_FpsChart old) => true;
}
