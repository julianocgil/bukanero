import 'dart:async';
import 'dart:io';

import '../l10n/tr.dart';

/// Falha de download com mensagem pronta para o usuário (nunca contém a URL).
class DownloadException implements Exception {
  const DownloadException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Download interrompido de propósito (perfil trocado ou apagado).
class DownloadCancelled extends DownloadException {
  const DownloadCancelled() : super('cancelado');
}

/// Chamada entre um pedaço e outro do download; pode esperar (dar a vez ao
/// vídeo) ou lançar [DownloadCancelled].
typedef DownloadGate = Future<void> Function();

/// Limites para não ficar esperando um servidor travado para sempre.
class DownloadLimits {
  const DownloadLimits({
    this.idle = const Duration(seconds: 30),
    this.slowWindow = const Duration(seconds: 60),
    this.slowMinBytes = 32 * 1024,
    this.total = const Duration(minutes: 15),
  });

  /// Tempo máximo sem chegar nenhum dado.
  final Duration idle;

  /// Em cada janela destas, precisa chegar pelo menos [slowMinBytes].
  final Duration slowWindow;
  final int slowMinBytes;

  /// Tempo máximo do download inteiro.
  final Duration total;
}

/// Bytes recebidos e, quando o servidor informa, o tamanho total.
typedef DownloadProgress = void Function(int received, int? total);

class _Rejected implements Exception {
  const _Rejected(this.status);

  final int status;
}

// Alguns provedores recusam clientes desconhecidos; tentamos três identidades.
const List<String> _userAgents = <String>[
  'VLC/3.0.20 LibVLC/3.0.20',
  'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/124.0 Safari/537.36',
  'Bukanero/0.1',
];

String _tlsMessage(TlsException e) {
  final String t = e.toString().toLowerCase();
  final String hint = ' ${tr.errCertHint}';
  if (t.contains('self signed') || t.contains('self-signed')) {
    return '${tr.errSelfSigned}$hint';
  }
  if (t.contains('expired')) {
    return '${tr.errCertExpired}$hint';
  }
  if (t.contains('hostname') || t.contains('host name')) {
    return '${tr.errCertHost}$hint';
  }
  if (t.contains('issuer') || t.contains('unknown ca')) {
    return '${tr.errCertUnknownCa}$hint';
  }
  if (t.contains('wrong_version_number') || t.contains('wrong version')) {
    return tr.errNoTls;
  }
  return tr.errTls;
}

/// Baixa [url] (http/https) para [dest], em streaming.
///
/// Com [allowInsecure], aceita certificado inválido, mas só do próprio
/// servidor da [url] (redirecionamentos para outros domínios são validados).
/// [dest] só é trocado quando o download termina inteiro. O tempo parado
/// em [gate] não conta para os limites.
Future<void> downloadFile(
  String url,
  File dest, {
  bool allowInsecure = false,
  DownloadProgress? onProgress,
  DownloadLimits limits = const DownloadLimits(),
  DownloadGate? gate,
}) async {
  await gate?.call();
  final Uri? uri = Uri.tryParse(url.trim());
  if (uri == null ||
      !(uri.scheme == 'http' || uri.scheme == 'https') ||
      uri.host.isEmpty) {
    throw DownloadException(tr.errInvalidUrl);
  }
  int? lastStatus;
  for (final String ua in _userAgents) {
    try {
      await _fetchOnce(uri, dest, ua, allowInsecure, onProgress, limits, gate);
      return;
    } on _Rejected catch (e) {
      lastStatus = e.status;
    } on TimeoutException {
      throw DownloadException(tr.errNoResponse);
    } on TlsException catch (e) {
      throw DownloadException(_tlsMessage(e));
    } on SocketException catch (e) {
      if (e.message.contains('Failed host lookup')) {
        throw DownloadException(tr.errDns);
      }
      throw DownloadException(
        tr.errConnection(e.osError?.message ?? tr.errNetwork),
      );
    } on HttpException catch (e) {
      if (e.message.toLowerCase().contains('connection closed')) {
        throw DownloadException(tr.errIncomplete);
      }
      throw DownloadException(tr.errBadHttp(e.message));
    }
  }
  throw DownloadException(tr.errForbidden('${lastStatus ?? '?'}'));
}

Future<void> _fetchOnce(
  Uri uri,
  File dest,
  String ua,
  bool allowInsecure,
  DownloadProgress? onProgress,
  DownloadLimits limits,
  DownloadGate? gate,
) async {
  final HttpClient client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 20)
    ..badCertificateCallback = (X509Certificate cert, String host, int port) =>
        allowInsecure && host == uri.host;
  final File tmp = File('${dest.path}.part');
  try {
    final HttpClientRequest req = await client.getUrl(uri);
    req.headers.set(HttpHeaders.userAgentHeader, ua);
    req.headers.set(HttpHeaders.acceptHeader, '*/*');
    final HttpClientResponse res = await req.close().timeout(
      const Duration(seconds: 60),
    );
    final int code = res.statusCode;
    if (code == 200) {
      await _receive(res, tmp, onProgress, limits, gate);
      if (tmp.lengthSync() == 0) {
        throw DownloadException(tr.errEmpty);
      }
      if (dest.existsSync()) dest.deleteSync();
      tmp.renameSync(dest.path);
      return;
    }
    await res.drain<void>();
    if (<int>{401, 403, 406, 429, 444, 456}.contains(code)) {
      throw _Rejected(code);
    }
    throw DownloadException(tr.errHttp(code));
  } finally {
    client.close(force: true);
    if (tmp.existsSync()) tmp.deleteSync();
  }
}

Future<void> _receive(
  HttpClientResponse res,
  File tmp,
  DownloadProgress? onProgress,
  DownloadLimits limits,
  DownloadGate? gate,
) async {
  final int? total = res.contentLength > 0 ? res.contentLength : null;
  final IOSink sink = tmp.openWrite();
  final Stopwatch clock = Stopwatch()..start();
  int received = 0;
  int windowStart = 0;
  int windowBytes = 0;
  try {
    await for (final List<int> chunk in res.timeout(limits.idle)) {
      sink.add(chunk);
      received += chunk.length;
      windowBytes += chunk.length;
      onProgress?.call(received, total);
      if (gate != null) {
        // Parado esperando (o vídeo tem prioridade): o relógio também para,
        // senão o download pareceria lento ou demorado demais.
        clock.stop();
        await gate();
        clock.start();
      }
      final int now = clock.elapsedMilliseconds;
      if (now - windowStart >= limits.slowWindow.inMilliseconds) {
        if (windowBytes < limits.slowMinBytes) {
          throw DownloadException(tr.errTooSlow);
        }
        windowStart = now;
        windowBytes = 0;
      }
      if (clock.elapsed > limits.total) {
        throw DownloadException(tr.errTooLong(limits.total.inMinutes));
      }
    }
  } finally {
    await sink.close();
  }
  if (total != null && received < total) {
    throw DownloadException(tr.errIncomplete);
  }
}
