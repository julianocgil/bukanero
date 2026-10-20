import 'package:flutter_test/flutter_test.dart';
import 'package:meu_iptv/domain/profile.dart';

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
}
