/// Extrai o ID do stream do fim da URL: `http://h/u/p/123.mp4` -> 123.
int? streamIdFromUrl(String url) {
  final int slash = url.lastIndexOf('/');
  if (slash < 0) return null;
  String last = url.substring(slash + 1);
  final int q = last.indexOf('?');
  if (q >= 0) last = last.substring(0, q);
  final int dot = last.lastIndexOf('.');
  if (dot >= 0) last = last.substring(0, dot);
  return int.tryParse(last);
}
