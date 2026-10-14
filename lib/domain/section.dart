import 'channel.dart';

enum Section { live, movies, series }

/// Minúsculas e sem acentos, para comparar nomes de categorias.
String normalize(String s) {
  const String from = 'áàãâéêíóôõúç';
  const String to = 'aaaaeeiooouc';
  final StringBuffer b = StringBuffer();
  for (final int r in s.toLowerCase().runes) {
    final String ch = String.fromCharCode(r);
    final int i = from.indexOf(ch);
    b.write(i >= 0 ? to[i] : ch);
  }
  return b.toString();
}

bool isAdultGroup(String group) {
  final String g = normalize(group);
  return g.contains('adulto') || g.contains('xxx');
}

/// Decide a seção de um item: URL primeiro, depois o nome da categoria.
Section classify(Channel c) {
  final String url = c.url.toLowerCase();
  if (url.contains('/series/')) return Section.series;
  if (url.contains('/movie/')) return Section.movies;

  final String g = normalize(c.group ?? '');
  if (g.startsWith('canais') || g.startsWith('canal')) return Section.live;
  if (g.contains('serie') || g.contains('novela') || g.contains('dorama')) {
    return Section.series;
  }
  if (g.contains('filme')) return Section.movies;
  if (url.endsWith('.mp4') || url.endsWith('.mkv') || url.endsWith('.avi')) {
    return Section.movies;
  }
  return Section.live;
}
