/// Preferência de versão aprendida das escolhas do usuário: as últimas
/// escolhas ficam guardadas, e as duas marcas mais escolhidas abrem primeiro.
library;

const int _keep = 10;
const String _sep = '\u0001';

/// Histórico guardado (texto) → lista, da mais antiga para a mais nova.
List<String> decodeChoices(String? raw) =>
    (raw == null || raw.isEmpty) ? <String>[] : raw.split(_sep);

String encodeChoices(List<String> h) => h.join(_sep);

/// Acrescenta [mark] e guarda só as últimas 10.
List<String> pushChoice(List<String> history, String mark) {
  final List<String> h = <String>[...history, mark];
  return h.length > _keep ? h.sublist(h.length - _keep) : h;
}

/// As [n] marcas mais escolhidas; empate: a escolhida mais recentemente.
List<String> topMarks(List<String> history, {int n = 2}) {
  final Map<String, int> count = <String, int>{};
  final Map<String, int> last = <String, int>{};
  for (int i = 0; i < history.length; i++) {
    count[history[i]] = (count[history[i]] ?? 0) + 1;
    last[history[i]] = i;
  }
  final List<String> marks = count.keys.toList()
    ..sort((String a, String b) {
      final int c = count[b]!.compareTo(count[a]!);
      return c != 0 ? c : last[b]!.compareTo(last[a]!);
    });
  return marks.take(n).toList();
}

/// Quanto [m] parece com [pref]: igual vale mais; senão, as palavras em
/// comum ("4K" combina com "4K DV HDR").
int markScore(String m, String pref) {
  if (m == pref) return 1000;
  return m.split(' ').toSet().intersection(pref.split(' ').toSet()).length;
}

/// Ordena [items] pela 1ª preferência, depois pela 2ª; o resto mantém a
/// ordem automática que já tinha.
List<T> orderByPreference<T>(
  List<T> items,
  String Function(T) mark,
  List<String> prefs,
) {
  if (prefs.isEmpty) return List<T>.of(items);
  final Map<T, int> pos = <T, int>{
    for (int i = 0; i < items.length; i++) items[i]: i,
  };
  int score(T x, int k) => k < prefs.length ? markScore(mark(x), prefs[k]) : 0;
  return List<T>.of(items)..sort((T a, T b) {
    for (int k = 0; k < prefs.length; k++) {
      final int c = score(b, k).compareTo(score(a, k));
      if (c != 0) return c;
    }
    return pos[a]!.compareTo(pos[b]!);
  });
}
