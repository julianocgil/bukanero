import 'package:bukanero/domain/grouping.dart';
import 'package:flutter_test/flutter_test.dart';

List<GroupItem> _items(List<(String, String?)> l) => <GroupItem>[
  for (int i = 0; i < l.length; i++)
    GroupItem(id: i, name: l[i].$1, logo: l[i].$2),
];

List<Set<String>> _groups(List<GroupItem> items, {bool movies = false}) {
  final GroupingResult r = groupItems(items, movies: movies);
  return <Set<String>>[
    for (final ItemGroup g in r.groups)
      <String>{for (final int id in g.ids) items[id].name},
  ];
}

void main() {
  test('estilos diferentes de lista: aprende as palavras de versão', () {
    // Lista inventada que usa "Backup" e "Alt" em vez de HD/FHD. Uma palavra
    // só vira "de versão" se aparecer em 3 ou mais canais diferentes.
    final List<GroupItem> items = _items(<(String, String?)>[
      ('Canal Um', 'a'),
      ('Canal Um Backup', 'a'),
      ('Canal Um Alt', 'a'),
      ('Canal Dois', 'b'),
      ('Canal Dois Backup', 'b'),
      ('Canal Tres', 'c'),
      ('Canal Tres Alt', 'c'),
      ('Canal Quatro', 'd'),
      ('Canal Quatro Backup', 'd'),
      ('Canal Cinco', 'e'),
      ('Canal Cinco Alt', 'e'),
      ('Outro Backup', null),
      ('Outro', null),
    ]);
    final GroupingResult r = groupItems(items, movies: false);
    expect(r.variantWords, containsAll(<String>['backup', 'alt']));
    expect(
      _groups(items),
      containsAll(<Set<String>>[
        <String>{'Canal Um', 'Canal Um Backup', 'Canal Um Alt'},
        <String>{'Outro', 'Outro Backup'},
      ]),
    );
  });

  test('pontuação e colchetes não importam', () {
    final List<GroupItem> items = _items(<(String, String?)>[
      ('ESPN-HD', 'e'),
      ('ESPN [FHD]', 'e'),
      ('espn.sd', 'e'),
    ]);
    expect(_groups(items), <Set<String>>[
      <String>{'ESPN-HD', 'ESPN [FHD]', 'espn.sd'},
    ]);
  });

  test('números são canais diferentes, mas viram família', () {
    final List<GroupItem> items = _items(<(String, String?)>[
      ('Esporte 1 HD', 'x'),
      ('Esporte 1 SD', 'x'),
      ('Esporte 2 HD', 'x'),
      ('Esporte 2 SD', 'x'),
    ]);
    final GroupingResult r = groupItems(items, movies: false);
    expect(r.groups, hasLength(2));
    expect(r.families.single.groups, hasLength(2));
    final List<GroupCard> cards = buildCards(items, r);
    expect(cards.single.name, 'Esporte');
    expect(cards.single.members.map((CardMember m) => m.label), <String>[
      '1 HD',
      '1 SD',
      '2 HD',
      '2 SD',
    ]);
  });

  test('imagem genérica não junta nomes diferentes', () {
    final List<GroupItem> items = _items(<(String, String?)>[
      ('Alfa', 'gen'),
      ('Beta', 'gen'),
      ('Gama', 'gen'),
      ('Delta', 'gen'),
    ]);
    final GroupingResult r = groupItems(items, movies: false);
    expect(r.genericLogos, contains('gen'));
    expect(r.groups, isEmpty);
  });

  test('filmes: ano diferente nunca junta; mesmo nome e ano junta', () {
    final List<GroupItem> items = _items(<(String, String?)>[
      ('O Pacto (2011)', 'p1'),
      ('O Pacto (2023)', 'p2'),
      ('O Pacto - 2023 [L]', 'p3'),
      ('Sem Ano', 's1'),
      ('Sem Ano', 's2'),
      // Outros filmes com [L], para o app aprender que [L] é versão.
      ('Um', 'u'),
      ('Um [L]', 'u'),
      ('Dois', 'd'),
      ('Dois [L]', 'd'),
      ('Tres', 't'),
      ('Tres [L]', 't'),
    ]);
    final List<Set<String>> g = _groups(items, movies: true);
    expect(
      g,
      contains(equals(<String>{'O Pacto (2023)', 'O Pacto - 2023 [L]'})),
    );
    expect(g.any((Set<String> x) => x.contains('O Pacto (2011)')), isFalse);
    // Sem ano e com imagens diferentes: provavelmente filmes diferentes.
    expect(g.any((Set<String> x) => x.contains('Sem Ano')), isFalse);
  });

  test('guia diferente impede juntar canais de mesmo nome', () {
    final List<GroupItem> items = <GroupItem>[
      const GroupItem(id: 0, name: 'Rede SP', epg: 'sp'),
      const GroupItem(id: 1, name: 'Rede SP HD', epg: 'sp'),
      const GroupItem(id: 2, name: 'Rede SP SD', epg: 'rj'),
    ];
    final GroupingResult r = groupItems(items, movies: false);
    expect(r.groups.single.ids.toSet(), <int>{0, 1});
    expect(r.groups.single.strong, isTrue);
  });

  test('ordem automática: a marca presente em mais cartões vem primeiro', () {
    // Lista inventada com marcas sem significado conhecido: Q2 está nos 6
    // canais; Q1 e Q3, em 3 cada.
    final List<GroupItem> items = _items(<(String, String?)>[
      for (final String c in <String>['A', 'B', 'C']) ...<(String, String?)>[
        ('Canal $c Q1', c),
        ('Canal $c Q2', c),
      ],
      for (final String c in <String>['D', 'E', 'F']) ...<(String, String?)>[
        ('Canal $c Q3', c),
        ('Canal $c Q2', c),
      ],
    ]);
    final GroupingResult r = groupItems(items, movies: false);
    final List<GroupCard> cards = buildCards(items, r);
    expect(cards, hasLength(6));
    for (final GroupCard c in cards) {
      expect(c.members.first.mark, 'Q2');
    }
  });

  test('lista pequena: "Amor Paixão" e "Amor Ódio" não agrupam', () {
    for (final bool movies in <bool>[false, true]) {
      // Imagens diferentes (o normal)...
      expect(
        _groups(
          _items(<(String, String?)>[
            ('Amor Paixão', 'p'),
            ('Amor Ódio', 'o'),
            ('Outro Filme', 'x'),
          ]),
          movies: movies,
        ),
        isEmpty,
      );
      // ...e até no pior caso, com a mesma imagem nos dois.
      final List<GroupItem> same = _items(<(String, String?)>[
        ('Amor Paixão', 'a'),
        ('Amor Ódio', 'a'),
        ('Outro Filme', 'x'),
      ]);
      final GroupingResult r = groupItems(same, movies: movies);
      expect(r.groups, isEmpty);
      expect(r.variantWords, isNot(contains('paixao')));
      expect(r.variantWords, isNot(contains('odio')));
    }
  });

  test('nome do cartão mantém a grafia do provedor', () {
    expect(cleanCardName('TNT FHD [H265]', <String>{'fhd', 'h265'}), 'TNT');
    expect(
      cleanCardName('BR | Globo SP - HD', <String>{'hd'}),
      'BR | Globo SP',
    );
  });
}
