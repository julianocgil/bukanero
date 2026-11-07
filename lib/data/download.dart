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
  'Bukanero/0.1',
];

String _tlsMessage(TlsException e) {
  final String t = e.toString().toLowerCase();
  const String hint =
      ' Se você confia neste servidor, marque "Aceitar o certificado '
      'inválido" em Editar perfil.';
  if (t.contains('self signed') || t.contains('self-signed')) {
    return 'o servidor usa um certificado autoassinado.$hint';
  }
  if (t.contains('expired')) {
    return 'o certificado do servidor está vencido (ou a data do PC está '
        'errada).$hint';
  }
  if (t.contains('hostname') || t.contains('host name')) {
    return 'o certificado do servidor é de outro domínio.$hint';
  }
  if (t.contains('issuer') || t.contains('unknown ca')) {
    return 'o certificado do servidor vem de uma autoridade desconhecida.$hint';
  }
  if (t.contains('wrong_version_number') || t.contains('wrong version')) {
    return 'o servidor não fala TLS nesta porta; tente http:// no lugar de '
        'https://.';
  }
  return 'falha de TLS/certificado ao conectar';
}

/// Baixa [url] (http/https) para [dest], em streaming.
///
/// Com [allowInsecure], aceita certificado inválido, mas só do próprio
/// servidor da [url] (redirecionamentos para outros domínios são validados).
Future<void> downloadFile(
  String url,
  File dest, {
  bool allowInsecure = false,
}) async {
  final Uri? uri = Uri.tryParse(url.trim());
  if (uri == null ||
      !(uri.scheme == 'http' || uri.scheme == 'https') ||
      uri.host.isEmpty) {
    throw const DownloadException('URL inválida (use http:// ou https://)');
  }
  int? lastStatus;
  for (final String ua in _userAgents) {
    try {
      await _fetchOnce(uri, dest, ua, allowInsecure);
      return;
    } on _Rejected catch (e) {
      lastStatus = e.status;
    } on TimeoutException {
      throw const DownloadException('tempo esgotado: o servidor não respondeu');
    } on TlsException catch (e) {
      throw DownloadException(_tlsMessage(e));
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

Future<void> _fetchOnce(
  Uri uri,
  File dest,
  String ua,
  bool allowInsecure,
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
