import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

import 'profile_store.dart';

const int _maxActive = 6;
const int _maxBytes = 10 * 1024 * 1024;
const Duration _retryAfter = Duration(seconds: 60);
// Ao passar rápido pela lista, espera um instante antes de baixar: se o
// cartão já saiu da tela, a imagem nem entra na fila.
const Duration _settle = Duration(milliseconds: 150);

int _active = 0;
// Pilha: o pedido mais recente (o que está na tela agora) passa na frente.
final List<Completer<void>> _waiting = <Completer<void>>[];
final Map<String, DateTime> _failed = <String, DateTime>{};
final Map<String, Future<File?>> _inflight = <String, Future<File?>>{};
// Quem ainda quer cada imagem (um cartão pode sair da tela enquanto espera).
final Map<String, List<bool Function()>> _interest =
    <String, List<bool Function()>>{};
// Imagens que já sabemos estar no disco: nem consulta o arquivo de novo.
final Set<String> _onDisk = <String>{};

bool _wanted(String url) =>
    _interest[url]?.any((bool Function() f) => f()) ?? false;
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
  _onDisk.remove(url);
  final File f = _fileFor(url);
  if (f.existsSync()) f.deleteSync();
}

/// Devolve o arquivo da imagem em cache (baixando se preciso), ou null.
/// Com [force], ignora uma falha recente e tenta de novo.
/// [stillWanted] diz se quem pediu ainda precisa dela; quando ninguém mais
/// precisa, o download é pulado (e devolve null).
Future<File?> cachedImage(
  String url, {
  bool force = false,
  bool Function()? stillWanted,
}) {
  if (force) _failed.remove(url);
  (_interest[url] ??= <bool Function()>[]).add(stillWanted ?? () => true);
  final Future<File?>? running = _inflight[url];
  if (running != null) return running;
  final Future<File?> f = _fetch(url);
  _inflight[url] = f;
  return f.whenComplete(() {
    _inflight.remove(url);
    _interest.remove(url);
  });
}

/// O arquivo da imagem, se já se sabe que está no disco (sem esperar nada).
/// Evita piscar o ícone padrão ao rolar de volta por capas já vistas.
File? knownCachedImage(String url) =>
    _onDisk.contains(url) ? _fileFor(url) : null;

/// Só para testes: esquece o que está em memória.
void resetImageCacheForTest() {
  _failed.clear();
  _onDisk.clear();
  _interest.clear();
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
  if (_onDisk.contains(url)) return file;
  final FileStat st = await file.stat();
  if (st.type == FileSystemEntityType.file && st.size > 0) {
    _onDisk.add(url);
    return file;
  }

  await Future<void>.delayed(_settle);
  if (!_wanted(url)) return null;
  await _acquire();
  if (!_wanted(url)) {
    // Saiu da tela enquanto esperava a vez: libera para a próxima.
    _release();
    return null;
  }
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
    _onDisk.add(url);
    return file;
  } on Object {
    _failed[url] = DateTime.now();
    return null;
  } finally {
    if (tmp.existsSync()) tmp.deleteSync();
    _release();
  }
}
