import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// Vídeo com um conjunto só de controles (os do próprio player):
/// voltar/avançar 15 s, play/pause, volume, tempo e tela cheia.
///
/// Atalhos do player: espaço (play/pause), ←/→ (voltar/avançar),
/// ↑/↓ (volume), F (tela cheia) e Esc (sair da tela cheia).
class PlayerView extends StatelessWidget {
  const PlayerView({required this.controller, super.key});

  final VideoController controller;

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
            const MaterialDesktopVolumeButton(),
            const MaterialDesktopPositionIndicator(),
            const Spacer(),
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
