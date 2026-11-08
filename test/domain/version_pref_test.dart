import 'package:bukanero/domain/version_pref.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('guarda só as últimas 10 escolhas', () {
    List<String> h = <String>[];
    for (int i = 0; i < 12; i++) {
      h = pushChoice(h, 'M$i');
    }
    expect(h, hasLength(10));
    expect(h.first, 'M2');
    expect(decodeChoices(encodeChoices(h)), h);
    expect(decodeChoices(null), isEmpty);
  });

  test('duas mais escolhidas; empate vai para a mais recente', () {
    expect(
      topMarks(<String>['Padrão', 'L', 'Padrão', '4K', 'Padrão', 'L']),
      <String>['Padrão', 'L'],
    );
    expect(topMarks(<String>['L', '4K']), <String>['4K', 'L']);
    expect(topMarks(<String>[]), isEmpty);
  });

  test('ordem: 1ª preferência, 2ª, depois a automática', () {
    final List<String> versions = <String>['4K', 'Padrão', 'L', 'SD'];
    // Prefere dublado (Padrão), depois legendado (L).
    expect(
      orderByPreference(versions, (String m) => m, <String>['Padrão', 'L']),
      <String>['Padrão', 'L', '4K', 'SD'],
    );
    // Filme sem dublado: abre no L, não no 4K.
    expect(
      orderByPreference(
        <String>['4K', 'L'],
        (String m) => m,
        <String>['Padrão', 'L'],
      ),
      <String>['L', '4K'],
    );
    // Parecido também conta: preferiu "4K DV HDR", o cartão só tem "4K".
    expect(
      orderByPreference(
        <String>['Padrão', '4K'],
        (String m) => m,
        <String>['4K DV HDR'],
      ),
      <String>['4K', 'Padrão'],
    );
  });
}
