import 'dart:async';

import 'package:media_kit/media_kit.dart';

import '../data/bandwidth.dart';

/// Lê do mpv, a cada segundo, se o vídeo está tocando e quantos segundos
/// estão guardados, e repassa para [VideoPriority].
class VideoHealth {
  VideoHealth(this.player) {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  final Player player;
  Timer? _timer;
  bool _busy = false;

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

  Future<void> _tick() async {
    if (_busy) return;
    _busy = true;
    try {
      final bool playing = player.state.playing;
      bool buffering = player.state.buffering;
      double? reserve;
      if (playing || buffering) {
        reserve = double.tryParse(await _prop('demuxer-cache-duration') ?? '');
        buffering = buffering || await _prop('paused-for-cache') == 'yes';
      }
      VideoPriority.update(
        playing: playing,
        buffering: buffering,
        reserveSecs: reserve,
      );
    } finally {
      _busy = false;
    }
  }

  void dispose() {
    _timer?.cancel();
    VideoPriority.update(playing: false, buffering: false);
  }
}
