import 'dart:async';

import 'download.dart';

/// Prioridade do vídeo na banda: enquanto ele toca com pouca reserva, os
/// downloads em segundo plano (lista, guia, notas, capas) esperam.
///
/// Vive no isolate principal: quem baixa em outro isolate não enxerga.
class VideoPriority {
  VideoPriority._();

  /// Abaixo disto (segundos de vídeo guardados), os downloads pausam...
  static const double pauseBelow = 4;

  /// ...e só voltam quando a reserva passa disto (evita liga-desliga).
  static const double resumeAbove = 8;

  static bool _active = false;
  static bool _buffering = false;
  static double? _reserve;
  static bool _yielding = false;
  static final StreamController<bool> _activeChanges =
      StreamController<bool>.broadcast();

  /// Há vídeo tocando (ou carregando para tocar).
  static bool get videoActive => _active;

  /// Os downloads em segundo plano estão dando a vez ao vídeo agora.
  static bool get yielding => _yielding;

  /// Avisa quando o vídeo começa ou para (para retomar tarefas adiadas).
  static Stream<bool> get activeChanges => _activeChanges.stream;

  /// Atualizado pelo player a cada segundo.
  static void update({
    required bool playing,
    required bool buffering,
    double? reserveSecs,
  }) {
    final bool active = playing || buffering;
    _buffering = buffering;
    _reserve = reserveSecs;
    if (!active) {
      _yielding = false;
    } else if (_buffering || (_reserve ?? 0) < pauseBelow) {
      _yielding = true;
    } else if ((_reserve ?? 0) >= resumeAbove) {
      _yielding = false;
    }
    if (active != _active) {
      _active = active;
      _activeChanges.add(active);
    }
  }

  /// Espera enquanto o vídeo precisa da banda. [cancelled] interrompe a
  /// espera (perfil trocado ou apagado).
  static Future<void> waitTurn({bool Function()? cancelled}) async {
    while (_yielding) {
      if (cancelled?.call() ?? false) throw const DownloadCancelled();
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    if (cancelled?.call() ?? false) throw const DownloadCancelled();
  }

  /// Só para testes.
  static void resetForTest() {
    _active = false;
    _buffering = false;
    _reserve = null;
    _yielding = false;
  }
}

/// Fila de tarefas grandes (lista, notas, guia): uma de cada vez.
class SerialJobs {
  Future<void> _tail = Future<void>.value();

  Future<T> run<T>(Future<T> Function() job) {
    final Completer<T> done = Completer<T>();
    _tail = _tail.then((_) async {
      try {
        done.complete(await job());
      } on Object catch (e, s) {
        done.completeError(e, s);
      }
    });
    return done.future;
  }
}
