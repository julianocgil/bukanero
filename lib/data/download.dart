import 'dart:async';
import 'dart:io';

/// Falha de download com mensagem pronta para o usuário (nunca contém a URL).
class DownloadException implements Exception {
  const DownloadException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _Rejected implements Exception {
  const _Rejected(this.status);

  final int status;
}

// Alguns provedores recusam clientes desconhecidos; tentamos três identidades.
const List<String> _userAgents = <String>[
  'VLC/3.0.20 LibVLC/3.0.20',
  'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/124.0 Safari/537.36',
  'MeuIPTV/0.1',
];

/// Baixa [url] (http/https) para [dest], em streaming.
Future<void> downloadFile(String url, File dest) async {
  final Uri? uri = Uri.tryParse(url.trim());
  if (uri == null ||
      !(uri.scheme == 'http' || uri.scheme == 'https') ||
      uri.host.isEmpty) {
    throw const DownloadException('URL inválida (use http:// ou https://)');
  }
  int? lastStatus;
  for (final String ua in _userAgents) {
    try {
      await _fetchOnce(uri, dest, ua);
      return;
    } on _Rejected catch (e) {
      lastStatus = e.status;
    } on TimeoutException {
      throw const DownloadException('tempo esgotado: o servidor não respondeu');
    } on TlsException {
      throw const DownloadException('falha de TLS/certificado ao conectar');
    } on SocketException catch (e) {
      if (e.message.contains('Failed host lookup')) {
        throw const DownloadException(
          'não foi possível resolver o endereço do servidor (DNS). '
          'A operadora pode estar bloqueando, ou o endereço mudou.',
        );
      }
      throw DownloadException(
        'falha de conexão (${e.osError?.message ?? 'rede'})',
      );
    } on HttpException catch (e) {
      throw DownloadException('resposta HTTP inválida: ${e.message}');
    }
  }
  throw DownloadException(
    'o servidor recusou o acesso (HTTP ${lastStatus ?? '?'}). '
    'Confira usuário e senha ou se a lista expirou.',
  );
}

Future<void> _fetchOnce(Uri uri, File dest, String ua) async {
  final HttpClient client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 20);
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
      await res.timeout(const Duration(seconds: 60)).pipe(tmp.openWrite());
      if (tmp.lengthSync() == 0) {
        throw const DownloadException('o servidor devolveu uma resposta vazia');
      }
      if (dest.existsSync()) dest.deleteSync();
      tmp.renameSync(dest.path);
      return;
    }
    await res.drain<void>();
    if (<int>{401, 403, 406, 429, 444, 456}.contains(code)) {
      throw _Rejected(code);
    }
    throw DownloadException('o servidor respondeu HTTP $code');
  } finally {
    client.close(force: true);
    if (tmp.existsSync()) tmp.deleteSync();
  }
}
