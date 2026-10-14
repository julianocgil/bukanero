import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

String _fmt(Duration d) {
  String two(int n) => n.toString().padLeft(2, '0');
  final String mm = two(d.inMinutes.remainder(60));
  final String ss = two(d.inSeconds.remainder(60));
  return d.inHours > 0 ? '${d.inHours}:$mm:$ss' : '$mm:$ss';
}

/// Controles extras: voltar/avançar 10 s, play/pause, tempo e volume.
class PlayerBar extends StatelessWidget {
  const PlayerBar({required this.player, super.key});

  final Player player;

  void _skip(int seconds) {
    final Duration total = player.state.duration;
    Duration target = player.state.position + Duration(seconds: seconds);
    if (target < Duration.zero) target = Duration.zero;
    if (total > Duration.zero && target > total) target = total;
    player.seek(target);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: 'Voltar 10 s',
            icon: const Icon(Icons.replay_10),
            onPressed: () => _skip(-10),
          ),
          StreamBuilder<bool>(
            stream: player.stream.playing,
            initialData: player.state.playing,
            builder: (BuildContext context, AsyncSnapshot<bool> s) {
              final bool playing = s.data ?? false;
              return IconButton(
                tooltip: playing ? 'Pausar' : 'Reproduzir',
                icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                onPressed: player.playOrPause,
              );
            },
          ),
          IconButton(
            tooltip: 'Avançar 10 s',
            icon: const Icon(Icons.forward_10),
            onPressed: () => _skip(10),
          ),
          const SizedBox(width: 12),
          StreamBuilder<Duration>(
            stream: player.stream.position,
            initialData: player.state.position,
            builder: (BuildContext context, AsyncSnapshot<Duration> s) => Text(
              '${_fmt(s.data ?? Duration.zero)} / ${_fmt(player.state.duration)}',
            ),
          ),
          const Spacer(),
          const Icon(Icons.volume_up),
          SizedBox(
            width: 180,
            child: StreamBuilder<double>(
              stream: player.stream.volume,
              initialData: player.state.volume,
              builder: (BuildContext context, AsyncSnapshot<double> s) =>
                  Slider(
                    value: (s.data ?? 100).clamp(0, 100).toDouble(),
                    max: 100,
                    onChanged: player.setVolume,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
