/// Agrupa versões do mesmo canal ou filme sem depender do jeito que cada
/// provedor escreve os nomes: as palavras de versão (HD, Backup, Leg...) são
/// aprendidas da própria lista, e vários sinais independentes do nome
/// (tvg-id, canal do guia, código TMDB, imagem) confirmam ou impedem.
library;

/// Um item para agrupar. [epg] é o canal do guia ligado a ele (se houver);
/// [tmdb] é o código do filme no TMDB (se o servidor informa).
class GroupItem {
  const GroupItem({
    required this.id,
    required this.name,
    this.logo,
    this.tvgId,
    this.epg,
    this.tmdb,
  });

  final int id;
  final String name;
  final String? logo;
  final String? tvgId;
  final String? epg;
  final int? tmdb;
}

/// Um grupo: os ids dos itens e os motivos que juntaram ele.
class ItemGroup {
  ItemGroup(this.ids, this.reasons, {required this.strong});

  final List<int> ids;
  final Set<String> reasons;

  /// True se ao menos um sinal forte (independente do nome) juntou o grupo,
  /// ou nome + ano. False: só sinais médios (nome e imagem).
  final bool strong;
}

/// Grupos que só diferem pelo número do fim (DAZN 1, DAZN 2) e têm a mesma
/// imagem: a família vira um cartão só, com a escolha do número.
class ItemFamily {
  const ItemFamily(this.groups);

  final List<int> groups; // índices em [GroupingResult.groups]
}

class GroupingResult {
  const GroupingResult({
    required this.groups,
    required this.families,
    required this.variantWords,
    required this.genericLogos,
  });

  /// Só grupos com 2 itens ou mais.
  final List<ItemGroup> groups;
  final List<ItemFamily> families;

  /// Palavras de versão aprendidas desta lista.
  final Set<String> variantWords;
  final Set<String> genericLogos;
}

const Map<String, String> _fold = <String, String>{
  'á': 'a', 'à': 'a', 'ã': 'a', 'â': 'a', 'ä': 'a', 'é': 'e', 'ê': 'e', //
  'è': 'e', 'ë': 'e', 'í': 'i', 'î': 'i', 'ï': 'i', 'ó': 'o', 'ô': 'o', //
  'õ': 'o', 'ö': 'o', 'ò': 'o', 'ú': 'u', 'ü': 'u', 'ù': 'u', 'ç': 'c', //
  'ñ': 'n', '¹': ' 1 ', '²': ' 2 ', '³': ' 3 ', '⁴': ' 4 ', '⁵': ' 5 ', //
  '⁶': ' 6 ', '⁷': ' 7 ', '⁸': ' 8 ', '⁹': ' 9 ', '⁰': ' 0 ', '+': ' plus ',
};

final RegExp _tokenRe = RegExp(r'[\p{L}\p{N}]+', unicode: true);
final RegExp _yearRe = RegExp(r'^(19[3-9]\d|20[0-4]\d)$');

/// Palavras do nome, sem acentos e sem pontuação: "ESPN-HD" e "espn [HD]"
/// dão as mesmas palavras.
List<String> nameWords(String name) {
  final StringBuffer b = StringBuffer();
  for (final String ch in name.toLowerCase().split('')) {
    b.write(_fold[ch] ?? ch);
  }
  return <String>[
    for (final RegExpMatch m in _tokenRe.allMatches(b.toString())) m[0]!,
  ];
}

/// Ano do filme no nome (1930–2049), em qualquer formato.
int? nameYear(List<String> words) {
  for (final String w in words.reversed) {
    if (_yearRe.hasMatch(w)) return int.parse(w);
  }
  return null;
}

bool _isNumber(String w) => int.tryParse(w) != null;

// Marcadores comuns a quase toda lista; o resto é aprendido. Só ajudam
// listas pequenas, onde há poucos exemplos para aprender.
const Set<String> _seedVariants = <String>{
  'hd', 'fhd', 'sd', 'uhd', '4k', '8k', 'hevc', 'h265', 'h264', 'fullhd', //
};

class _Prepared {
  _Prepared(this.item, this.words, this.year);

  final GroupItem item;
  final List<String> words;
  final int? year;
  late List<String> core;
  String get coreKey => core.join(' ');
}

class _Union {
  _Union(int n) : _p = List<int>.generate(n, (int i) => i);

  final List<int> _p;

  int find(int x) {
    while (_p[x] != x) {
      _p[x] = _p[_p[x]];
      x = _p[x];
    }
    return x;
  }

  void join(int a, int b) {
    final int ra = find(a);
    final int rb = find(b);
    if (ra != rb) _p[ra] = rb;
  }
}

/// Agrupa [items]. Com [movies], o ano conta: anos diferentes nunca juntam,
/// e mesmo nome + mesmo ano é sinal forte.
GroupingResult groupItems(List<GroupItem> items, {required bool movies}) {
  final List<_Prepared> ps = <_Prepared>[];
  for (final GroupItem it in items) {
    List<String> w = nameWords(it.name);
    final int? year = movies ? nameYear(w) : null;
    if (year != null) w = w.where((String x) => x != '$year').toList();
    ps.add(_Prepared(it, w, year));
  }

  // 1. Imagem genérica: a mesma imagem em nomes que nem começam igual.
  final Map<String, Set<String>> firstWords = <String, Set<String>>{};
  for (final _Prepared p in ps) {
    final String? l = p.item.logo;
    if (l == null || l.isEmpty || p.words.isEmpty) continue;
    (firstWords[l] ??= <String>{}).add(p.words.first);
  }
  final Set<String> generic = <String>{
    for (final MapEntry<String, Set<String>> e in firstWords.entries)
      if (e.value.length >= 3) e.key,
  };
  // (Depois de aprender as palavras de versão, a regra fica mais rígida:
  // veja "imagem genérica pelos títulos" abaixo.)
  bool goodLogo(String? l) => l != null && l.isNotEmpty && !generic.contains(l);

  // 2. Palavras de versão: o que sobra ao comparar nomes com a mesma imagem
  // (e o mesmo começo), quando isso se repete em muitas imagens diferentes.
  final Map<String, List<_Prepared>> byLogo = <String, List<_Prepared>>{};
  for (final _Prepared p in ps) {
    if (goodLogo(p.item.logo)) (byLogo[p.item.logo!] ??= <_Prepared>[]).add(p);
  }
  final Map<String, int> seenIn = <String, int>{};
  for (final List<_Prepared> same in byLogo.values) {
    if (same.length < 2) continue;
    final Set<String> diff = <String>{};
    final List<_Prepared> sample = same.take(30).toList();
    // Só o que sobra no FIM, depois do começo igual dos dois nomes: marcas
    // de versão vêm depois do título ("Filme 4K DV", "Canal FHD"), artigos e
    // palavras do título vêm antes e nunca entram.
    for (int i = 0; i < sample.length; i++) {
      for (int j = i + 1; j < sample.length; j++) {
        final List<String> a = sample[i].words;
        final List<String> b = sample[j].words;
        int k = 0;
        while (k < a.length && k < b.length && a[k] == b[k]) {
          k++;
        }
        if (k == 0) continue;
        final List<String> la = a.sublist(k);
        final List<String> lb = b.sublist(k);
        // Um nome é o outro com algo a mais no fim, ou os dois diferem por
        // uma palavra só no fim. "Filho do Mal" x "Filho de Deus" não conta.
        final bool suffix = la.isEmpty || lb.isEmpty;
        final bool oneWord = la.length == 1 && lb.length == 1;
        if (!suffix && !oneWord) continue;
        final Set<String> ta = la.toSet();
        final Set<String> tb = lb.toSet();
        diff
          ..addAll(ta.difference(tb))
          ..addAll(tb.difference(ta));
      }
    }
    for (final String w in diff) {
      // Número curto é canal diferente (DAZN 1 x DAZN 2), não versão.
      if (_isNumber(w) && w.length <= 2) continue;
      seenIn[w] = (seenIn[w] ?? 0) + 1;
    }
  }
  // Precisa aparecer no fim de nomes em várias imagens diferentes. Numa
  // lista grande, com menos de 5, palavras de título que se repetem por
  // acaso viram "versão"; numa pequena, 3 já bastam.
  final int minSeen = byLogo.length < 1000 ? 3 : 5;
  final Set<String> variants = <String>{
    ..._seedVariants,
    for (final MapEntry<String, int> e in seenIn.entries)
      if (e.value >= minSeen) e.key,
  };
  for (final _Prepared p in ps) {
    p.core = p.words.where((String w) => !variants.contains(w)).toList();
  }

  // Imagem genérica pelos títulos: a mesma imagem em 3+ títulos diferentes
  // (sem as palavras de versão e sem o número do fim) também é genérica,
  // mesmo que todos comecem igual ("[24H] ...", "BR | ..."). A primeira
  // regra, pela palavra inicial, não pega esse caso.
  final Map<String, Set<String>> titles = <String, Set<String>>{};
  for (final _Prepared p in ps) {
    final String? l = p.item.logo;
    if (l == null || l.isEmpty || p.core.isEmpty) continue;
    final List<String> t = _isNumber(p.core.last)
        ? p.core.sublist(0, p.core.length - 1)
        : p.core;
    (titles[l] ??= <String>{}).add('${t.join(' ')}|${p.year ?? ''}');
  }
  for (final MapEntry<String, Set<String>> e in titles.entries) {
    if (e.value.length >= 3) generic.add(e.key);
  }

  // 3. Ligações. Sinais que se contradizem (guia ou TMDB diferentes)
  // impedem a ligação pelo nome.
  final _Union u = _Union(ps.length);
  final List<Set<String>> why = List<Set<String>>.generate(
    ps.length,
    (_) => <String>{},
  );
  final List<bool> strong = List<bool>.filled(ps.length, false);
  void link(int a, int b, String reason, {required bool isStrong}) {
    u.join(a, b);
    why[a].add(reason);
    why[b].add(reason);
    if (isStrong) strong[a] = strong[b] = true;
  }

  bool contradict(_Prepared a, _Prepared b) {
    final GroupItem x = a.item;
    final GroupItem y = b.item;
    if (x.tmdb != null && y.tmdb != null && x.tmdb != y.tmdb) return true;
    if (x.epg != null && y.epg != null && x.epg != y.epg) return true;
    if (movies && a.year != null && b.year != null && a.year != b.year) {
      return true;
    }
    return false;
  }

  void bucket(String? Function(_Prepared) key, String reason) {
    final Map<String, int> first = <String, int>{};
    for (int i = 0; i < ps.length; i++) {
      final String? k = key(ps[i]);
      if (k == null || k.isEmpty) continue;
      final int? f = first[k];
      if (f == null) {
        first[k] = i;
      } else {
        link(f, i, reason, isStrong: true);
      }
    }
  }

  bucket((_Prepared p) => p.item.tvgId?.toLowerCase(), 'mesmo tvg-id');
  bucket((_Prepared p) => p.item.tmdb?.toString(), 'mesmo TMDB');
  // O canal do guia não junta sozinho: o guia costuma ter um canal só para
  // várias afiliadas regionais (Globo RJ, Globo SP...). Ele confirma (sinal
  // forte junto com o nome) ou impede (canais do guia diferentes).

  // Mesmo nome sem as palavras de versão.
  final Map<String, List<int>> byCore = <String, List<int>>{};
  for (int i = 0; i < ps.length; i++) {
    if (ps[i].core.isEmpty) continue;
    (byCore[ps[i].coreKey] ??= <int>[]).add(i);
  }
  for (final List<int> same in byCore.values) {
    for (int x = 0; x < same.length; x++) {
      for (int y = x + 1; y < same.length; y++) {
        final _Prepared a = ps[same[x]];
        final _Prepared b = ps[same[y]];
        if (contradict(a, b)) continue;
        final bool logo = goodLogo(a.item.logo) && a.item.logo == b.item.logo;
        if (movies) {
          if (a.year != null && a.year == b.year) {
            link(same[x], same[y], 'mesmo nome e ano', isStrong: true);
          } else if (logo) {
            link(same[x], same[y], 'mesmo nome e imagem', isStrong: false);
          }
        } else {
          final bool guide = a.item.epg != null && a.item.epg == b.item.epg;
          link(
            same[x],
            same[y],
            guide
                ? 'mesmo nome e canal do guia'
                : (logo ? 'mesmo nome e imagem' : 'mesmo nome'),
            isStrong: guide,
          );
        }
      }
    }
  }

  // 4. Monta os grupos e separa o que ficou contraditório por encadeamento
  // (A liga B, B liga C, mas A e C têm anos ou canais do guia diferentes).
  final Map<int, List<int>> raw = <int, List<int>>{};
  for (int i = 0; i < ps.length; i++) {
    (raw[u.find(i)] ??= <int>[]).add(i);
  }
  final List<List<int>> clean = <List<int>>[];
  for (final List<int> g in raw.values) {
    clean.addAll(_splitConflicts(g, ps, movies));
  }

  // 5. Famílias (só canais): mesmo nome tirando o número do fim e a mesma
  // imagem boa. Vale também para canais que existem uma vez só por número
  // ("Pack 01", "Pack 02"...), não só para grupos com versões.
  final Map<String, List<int>> byFamily = <String, List<int>>{};
  if (!movies) {
    for (int ui = 0; ui < clean.length; ui++) {
      final _Prepared p = ps[clean[ui].first];
      if (p.core.length < 2 || !_isNumber(p.core.last)) continue;
      // Aqui vale até imagem genérica: o título igual já é exigido, e a
      // família só junta números para você escolher.
      final String? logo = p.item.logo;
      if (logo == null || logo.isEmpty) continue;
      final String k =
          '${p.core.sublist(0, p.core.length - 1).join(' ')}|${p.item.logo}';
      (byFamily[k] ??= <int>[]).add(ui);
    }
  }
  final Set<int> inFamily = <int>{
    for (final List<int> f in byFamily.values)
      if (f.length >= 2) ...f,
  };

  final List<ItemGroup> groups = <ItemGroup>[];
  final Map<int, int> groupOfUnit = <int, int>{};
  for (int ui = 0; ui < clean.length; ui++) {
    final List<int> g = clean[ui];
    // Um item sozinho só entra se faz parte de uma família.
    if (g.length < 2 && !inFamily.contains(ui)) continue;
    final List<int> ids = <int>[for (final int i in g) ps[i].item.id];
    groupOfUnit[ui] = groups.length;
    groups.add(
      ItemGroup(ids, <String>{
        for (final int i in g) ...why[i],
        if (g.length < 2) 'família numerada',
      }, strong: g.any((int i) => strong[i])),
    );
  }
  final List<ItemFamily> families = <ItemFamily>[
    for (final List<int> f in byFamily.values)
      if (f.length >= 2)
        ItemFamily(<int>[for (final int ui in f) groupOfUnit[ui]!]),
  ];

  return GroupingResult(
    groups: groups,
    families: families,
    variantWords: variants,
    genericLogos: generic,
  );
}

List<List<int>> _splitConflicts(List<int> g, List<_Prepared> ps, bool movies) {
  if (g.length < 2) return <List<int>>[g];
  String? tag(_Prepared p) {
    if (movies) return p.year?.toString();
    return p.item.epg;
  }

  final Set<String> tags = <String>{
    for (final int i in g)
      if (tag(ps[i]) != null) tag(ps[i])!,
  };
  if (tags.length <= 1) return <List<int>>[g];
  // Um subgrupo por ano (ou canal do guia); os sem marca vão para o maior.
  final Map<String, List<int>> by = <String, List<int>>{};
  final List<int> loose = <int>[];
  for (final int i in g) {
    final String? t = tag(ps[i]);
    if (t == null) {
      loose.add(i);
    } else {
      (by[t] ??= <int>[]).add(i);
    }
  }
  final List<List<int>> out = by.values.toList()
    ..sort((List<int> a, List<int> b) => b.length.compareTo(a.length));
  if (movies) {
    // Filme sem ano não sabe com qual ano ficar: fica sozinho.
    out.addAll(<List<int>>[
      for (final int i in loose) <int>[i],
    ]);
  } else {
    out.first.addAll(loose);
  }
  return out;
}

/// Uma versão dentro de um cartão agrupado.
class CardMember {
  CardMember(this.id, this.label, this.rank, {String? mark})
    : mark = mark ?? label;

  final int id;

  /// O que diferencia esta versão ("FHD", "HD LEG", "2 FHD"); "Padrão" se
  /// nada.
  final String label;

  /// A marca sem o número da família ("FHD" em "2 FHD"): é por ela que a
  /// preferência do usuário vale para todos os cartões.
  final String mark;

  /// Menor = tocada primeiro.
  double rank;
}

/// Um cartão: o nome limpo e as versões, da melhor para a pior.
class GroupCard {
  const GroupCard(
    this.name,
    this.members,
    this.key, {
    this.strong = false,
    this.reasons = const <String>{},
  });

  final String name;
  final List<CardMember> members;

  /// Identifica o cartão entre importações (para "Separar este grupo").
  final String key;

  /// Juntado por sinal forte (independente do nome): quase nunca erra. Os
  /// outros (só nome e imagem) são os que vale a pena revisar.
  final bool strong;
  final Set<String> reasons;
}

// Ordem de preferência para tocar: FHD, depois HD/sem marca, SD, e por
// último 4K e H265 (pesados para a banda e para PCs antigos).
double _rankOf(List<String> labelWords) {
  double r = 1;
  for (final String w in labelWords) {
    if (w == 'fhd' || w == 'fullhd' || w == '1080' || w == '1080p') {
      r = 0;
    } else if (w == 'sd' || w == '480' || w == '480p') {
      r = 2;
    } else if (w == '4k' || w == 'uhd' || w == '2160' || w == '8k') {
      r = 3;
    }
  }
  if (labelWords.any((String w) => w == 'h265' || w == 'hevc')) r += 0.5;
  // Versões marcadas (legendada, backup...) depois da original.
  if (labelWords.any((String w) => !_rankWords.contains(w) && !_isNumber(w))) {
    r += 0.2;
  }
  return r;
}

const Set<String> _rankWords = <String>{
  'fhd', 'fullhd', '1080', '1080p', 'hd', '720', '720p', 'sd', '480', //
  '480p', '4k', 'uhd', '2160', '8k', 'h265', 'hevc', 'h264', //
};

final RegExp _anyToken = RegExp(r'[\p{L}\p{N}]+', unicode: true);

/// Nome para o cartão: o original sem as palavras de versão (e sem o
/// número, numa família), mantendo a grafia do provedor.
String cleanCardName(String name, Set<String> drop) {
  final String s = name.replaceAllMapped(_anyToken, (Match m) {
    final List<String> w = nameWords(m[0]!);
    return w.isNotEmpty && w.every(drop.contains) ? '' : m[0]!;
  });
  return s
      .replaceAll(RegExp(r'[\[({]\s*[\])}]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAllMapped(RegExp(r'\s+([\])}])'), (Match m) => m[1]!)
      .replaceAllMapped(RegExp(r'([\[({])\s+'), (Match m) => m[1]!)
      .replaceAll(RegExp(r'^[\s\-|:.]+|[\s\-|:.]+$'), '')
      .trim();
}

/// Junta grupos e famílias em cartões prontos para a tela.
List<GroupCard> buildCards(List<GroupItem> items, GroupingResult r) {
  final Map<int, GroupItem> byId = <int, GroupItem>{
    for (final GroupItem it in items) it.id: it,
  };
  List<String> words(GroupItem it) => nameWords(it.name);

  final List<List<int>> merged = <List<int>>[];
  final Set<int> inFamily = <int>{};
  final List<bool> familyCard = <bool>[];
  final List<bool> cardStrong = <bool>[];
  final List<Set<String>> cardReasons = <Set<String>>[];
  for (final ItemFamily f in r.families) {
    merged.add(<int>[for (final int gi in f.groups) ...r.groups[gi].ids]);
    familyCard.add(true);
    cardStrong.add(f.groups.every((int gi) => r.groups[gi].strong));
    cardReasons.add(<String>{
      'mesmo nome com número',
      for (final int gi in f.groups) ...r.groups[gi].reasons,
    });
    inFamily.addAll(f.groups);
  }
  for (int gi = 0; gi < r.groups.length; gi++) {
    if (inFamily.contains(gi)) continue;
    merged.add(r.groups[gi].ids);
    familyCard.add(false);
    cardStrong.add(r.groups[gi].strong);
    cardReasons.add(r.groups[gi].reasons);
  }

  // 1ª passada: as versões de cada cartão, com a marca e a qualidade.
  final List<List<CardMember>> all = <List<CardMember>>[];
  final List<List<int>> famNum = <List<int>>[];
  final Map<String, int> markCount = <String, int>{};
  for (int c = 0; c < merged.length; c++) {
    final List<CardMember> members = <CardMember>[];
    final List<int> nums = <int>[];
    final Set<String> marksHere = <String>{};
    for (final int id in merged[c]) {
      final GroupItem it = byId[id]!;
      final List<String> w = words(it);
      final List<String> core = w
          .where((String x) => !r.variantWords.contains(x))
          .toList();
      final List<String> marks = w.where(r.variantWords.contains).toList();
      final String? number =
          familyCard[c] && core.isNotEmpty && _isNumber(core.last)
          ? core.last
          : null;
      final String mark = marks.isEmpty
          ? 'Padrão'
          : marks.join(' ').toUpperCase();
      marksHere.add(mark);
      members.add(
        CardMember(
          id,
          number == null ? mark : '$number${marks.isEmpty ? '' : ' $mark'}',
          _rankOf(marks),
          mark: mark,
        ),
      );
      nums.add(number == null ? 0 : int.parse(number));
    }
    for (final String m in marksHere) {
      markCount[m] = (markCount[m] ?? 0) + 1;
    }
    all.add(members);
    famNum.add(nums);
  }

  // 2ª passada: a ordem automática. Primeiro o número da família; depois a
  // marca que aparece em mais cartões (a "padrão" do provedor, seja qual
  // for o nome dela); a qualidade conhecida (FHD, SD...) só desempata.
  final int total = merged.isEmpty ? 1 : merged.length;
  final List<GroupCard> cards = <GroupCard>[];
  for (int c = 0; c < merged.length; c++) {
    final List<CardMember> members = all[c];
    for (int i = 0; i < members.length; i++) {
      final double share = (markCount[members[i].mark] ?? 0) / total;
      final double bucket = (share * 20).round() / 20; // de 5% em 5%
      members[i].rank =
          famNum[c][i] * 1000000 + (1 - bucket) * 100 + members[i].rank;
    }
    members.sort((CardMember a, CardMember b) => a.rank.compareTo(b.rank));
    final GroupItem best = byId[members.first.id]!;
    final Set<String> drop = <String>{...r.variantWords};
    if (familyCard[c]) {
      final List<String> w = words(best)
          .where((String x) => !r.variantWords.contains(x))
          .toList();
      if (w.isNotEmpty && _isNumber(w.last)) drop.add(w.last);
    }
    final String name = cleanCardName(best.name, drop);
    final List<String> names = <String>[
      for (final CardMember m in members) byId[m.id]!.name,
    ]..sort();
    cards.add(
      GroupCard(
        name.isEmpty ? best.name : name,
        members,
        names.join('\u0001'),
        strong: cardStrong[c],
        reasons: cardReasons[c]..remove('família numerada'),
      ),
    );
  }
  return cards;
}
