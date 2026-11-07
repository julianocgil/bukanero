import 'package:flutter_test/flutter_test.dart';
import 'package:bukanero/domain/profile.dart';

void main() {
  test('perfil antigo (sem a opção) continua carregando', () {
    final Profile p = Profile.fromJson(<String, dynamic>{
      'id': '1',
      'name': 'A',
      'url': 'http://s/x.m3u',
    });
    expect(p.allowInsecure, isFalse);
    expect(p.toJson().containsKey('allowInsecure'), isFalse);
  });

  test('opção de certificado é salva e lida', () {
    const Profile p = Profile(
      id: '1',
      name: 'A',
      url: 'https://s/x.m3u',
      allowInsecure: true,
    );
    expect(Profile.fromJson(p.toJson()).allowInsecure, isTrue);
  });

  test('atualização automática: padrão de 24 h, salva e lida', () {
    final Profile old = Profile.fromJson(<String, dynamic>{
      'id': '1',
      'name': 'A',
      'url': 'http://s/x.m3u',
    });
    expect(old.refreshHours, 24);
    expect(old.toJson().containsKey('refreshHours'), isFalse);
    const Profile p = Profile(
      id: '1',
      name: 'A',
      url: 'http://s/x.m3u',
      refreshHours: 6,
    );
    expect(Profile.fromJson(p.toJson()).refreshHours, 6);
  });

  test('quando a lista precisa ser baixada de novo', () {
    final DateTime now = DateTime(2026, 1, 2, 12);
    const Profile daily = Profile(id: '1', name: 'A', url: 'http://s/x.m3u');
    expect(daily.listRefreshDue(DateTime(2026, 1, 1, 13), now), isFalse);
    expect(daily.listRefreshDue(DateTime(2026, 1, 1, 12), now), isTrue);
    expect(daily.listRefreshDue(null, now), isFalse);
    const Profile never = Profile(
      id: '1',
      name: 'A',
      url: 'http://s/x.m3u',
      refreshHours: 0,
    );
    expect(never.listRefreshDue(DateTime(2020), now), isFalse);
  });
}
