import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

import 'profile_store.dart';

const int _maxActive = 6;
const int _maxBytes = 10 * 1024 * 1024;
const Duration _retryAfter = Duration(seconds: 60);

int _active = 0;
// Pilha: o pedido mais recente (o que está na tela agora) passa na frente.
final List<Completer<void>> _waiting = <Completer<void>>[];
final Map<String, DateTime> _failed = <String, DateTime>{};
final Map<String, Future<File?>> _inflight = <String, Future<File?>>{};
final HttpClient _client = HttpClient()
  ..connectionTimeout = const Duration(seconds: 10)
  ..maxConnectionsPerHost = _maxActive;

Future<void> _acquire() async {
  if (_active < _maxActive) {
    _active++;
    return;
  }
  final Completer<void> c = Completer<void>();
  _waiting.add(c);
  await c.future;
}

void _release() {
  if (_waiting.isNotEmpty) {
    _waiting.removeLast().complete();
  } else {
    _active--;
  }
}

bool _failedRecently(String url) {
  final DateTime? t = _failed[url];
  if (t == null) return false;
  if (DateTime.now().difference(t) > _retryAfter) {
    _failed.remove(url);
    return false;
  }
  return true;
}

File _fileFor(String url) =>
    File('${imageCacheDir().path}/${md5.convert(utf8.encode(url))}');

/// Apaga a imagem em cache (por exemplo, se estava corrompida).
void forgetImage(String url) {
  _failed.remove(url);
  final File f = _fileFor(url);
  if (f.existsSync()) f.deleteSync();
}

/// Devolve o arquivo da imagem em cache (baixando se preciso), ou null.
/// Com [force], ignora uma falha recente e tenta de novo.
Future<File?> cachedImage(String url, {bool force = false}) {
  if (force) _failed.remove(url);
  final Future<File?>? running = _inflight[url];
  if (running != null) return running;
  final Future<File?> f = _fetch(url);
  _inflight[url] = f;
  return f.whenComplete(() => _inflight.remove(url));
}

Future<File?> _fetch(String url) async {
  if (_failedRecently(url)) return null;
  final Uri? uri = Uri.tryParse(url);
  if (uri == null ||
      !(uri.scheme == 'http' || uri.scheme == 'https') ||
      uri.host.isEmpty) {
    return null;
  }
  final File file = _fileFor(url);
  if (file.existsSync() && file.lengthSync() > 0) return file;

  await _acquire();
  final File tmp = File('${file.path}.part');
  try {
    final HttpClientRequest req = await _client
        .getUrl(uri)
        .timeout(const Duration(seconds: 15));
    req.headers.set(
      HttpHeaders.userAgentHeader,
      'Mozilla/5.0 (X11; Linux x86_64)',
    );
    final HttpClientResponse res = await req.close().timeout(
      const Duration(seconds: 20),
    );
    if (res.statusCode != 200) {
      await res.drain<void>();
      _failed[url] = DateTime.now();
      return null;
    }
    final IOSink sink = tmp.openWrite();
    int bytes = 0;
    try {
      await for (final List<int> chunk in res.timeout(
        const Duration(seconds: 20),
      )) {
        bytes += chunk.length;
        if (bytes > _maxBytes) {
          throw const FormatException('imagem grande demais');
        }
        sink.add(chunk);
      }
    } finally {
      await sink.close();
    }
    if (bytes == 0) {
      _failed[url] = DateTime.now();
      return null;
    }
    tmp.renameSync(file.path);
    return file;
  } on Object {
    _failed[url] = DateTime.now();
    return null;
  } finally {
    if (tmp.existsSync()) tmp.deleteSync();
    _release();
  }
}
