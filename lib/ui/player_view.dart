import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// Vídeo com um conjunto só de controles (os do próprio player):
/// voltar/avançar 15 s, play/pause, volume, tempo e tela cheia.
///
/// Atalhos do player: espaço (play/pause), ←/→ (voltar/avançar),
/// ↑/↓ (volume), F (tela cheia) e Esc (sair da tela cheia).
class PlayerView extends StatelessWidget {
  const PlayerView({
    required this.controller,
    this.episodeMode = false,
    this.onPrevious,
    this.onNext,
    super.key,
  });

  final VideoController controller;

  /// Tocando um episódio de série: mostra "Episódio anterior" e "Próximo
  /// episódio" à direita (apagados quando não há anterior ou próximo).
  final bool episodeMode;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  Player get _player => controller.player;

  void _skip(int seconds) {
    final Duration total = _player.state.duration;
    Duration target = _player.state.position + Duration(seconds: seconds);
    if (target < Duration.zero) target = Duration.zero;
    if (total > Duration.zero && target > total) target = total;
    _player.seek(target);
  }

  // O Material não tem ícone de 15 s: seta circular com o número dentro
  // (espelhada para avançar).
  Widget _skipIcon({required bool forward}) {
    final Widget arrow = forward
        ? Transform.flip(flipX: true, child: const Icon(Icons.replay))
        : const Icon(Icons.replay);
    return SizedBox(
      width: 28,
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          arrow,
          // Mesma cor do ícone, que muda entre os temas do player.
          Builder(
            builder: (BuildContext context) => Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                '15',
                style: TextStyle(
                  color: IconTheme.of(context).color,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skipButton(String tip, int seconds) => Tooltip(
    message: tip,
    child: MaterialDesktopCustomButton(
      icon: _skipIcon(forward: seconds > 0),
      onPressed: () => _skip(seconds),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final MaterialDesktopVideoControlsThemeData theme =
        MaterialDesktopVideoControlsThemeData(
          bottomButtonBar: <Widget>[
            _skipButton('Voltar 15 s', -15),
            const MaterialDesktopPlayOrPauseButton(),
            _skipButton('Avançar 15 s', 15),
            _VolumeBar(player: _player),
            const MaterialDesktopPositionIndicator(),
            const Spacer(),
            // Trocar de episódio fica separado dos pulos de 15 s.
            if (episodeMode) ...<Widget>[
              IconButton(
                tooltip: 'Episódio anterior',
                color: Colors.white,
                disabledColor: Colors.white38,
                onPressed: onPrevious,
                icon: const Icon(Icons.skip_previous),
              ),
              IconButton(
                tooltip: 'Próximo episódio',
                color: Colors.white,
                disabledColor: Colors.white38,
                onPressed: onNext,
                icon: const Icon(Icons.skip_next),
              ),
            ],
            const MaterialDesktopFullscreenButton(),
          ],
        );
    return MaterialDesktopVideoControlsTheme(
      normal: theme,
      fullscreen: theme,
      child: Video(controller: controller),
    );
  }
}

/// Volume sempre à mostra: alto-falante (liga/desliga o som) e a barrinha.
class _VolumeBar extends StatefulWidget {
  const _VolumeBar({required this.player});

  final Player player;

  @override
  State<_VolumeBar> createState() => _VolumeBarState();
}

class _VolumeBarState extends State<_VolumeBar> {
  double _beforeMute = 100;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: widget.player.stream.volume,
      initialData: widget.player.state.volume,
      builder: (BuildContext context, AsyncSnapshot<double> s) {
        final double v = (s.data ?? 100).clamp(0, 100).toDouble();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              tooltip: v == 0 ? 'Ligar o som' : 'Tirar o som',
              color: Colors.white,
              icon: Icon(
                v == 0
                    ? Icons.volume_off
                    : (v < 50 ? Icons.volume_down : Icons.volume_up),
              ),
              onPressed: () {
                if (v == 0) {
                  widget.player.setVolume(_beforeMute);
                } else {
                  _beforeMute = v;
                  widget.player.setVolume(0);
                }
              },
            ),
            SizedBox(
              width: 100,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.white24,
                  thumbColor: Colors.white,
                  overlayShape: SliderComponentShape.noOverlay,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                ),
                child: Slider(
                  value: v,
                  max: 100,
                  onChanged: widget.player.setVolume,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        );
      },
    );
  }
}
