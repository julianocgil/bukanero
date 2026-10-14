import 'dart:io';

/// Baixa a playlist (http/https) para [dest], em streaming.
///
/// As mensagens de erro nunca incluem a URL, que costuma ter usuário e senha.
Future<void> downloadPlaylist(String url, File dest) async {
  final Uri? uri = Uri.tryParse(url);
  if (uri == null ||
      !(uri.scheme == 'http' || uri.scheme == 'https') ||
      uri.host.isEmpty) {
    throw const FormatException('URL inválida (use http:// ou https://)');
  }

  final HttpClient client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 20);
  final File tmp = File('${dest.path}.part');
  try {
    final HttpClientRequest req = await client.getUrl(uri);
    req.headers.set(HttpHeaders.userAgentHeader, 'MeuIPTV/0.1');
    final HttpClientResponse res = await req.close();
    if (res.statusCode != 200) {
      await res.drain<void>();
      throw HttpException('o servidor respondeu ${res.statusCode}');
    }
    await res.pipe(tmp.openWrite());
    await tmp.rename(dest.path);
  } finally {
    client.close(force: true);
    if (tmp.existsSync()) tmp.deleteSync();
  }
}
