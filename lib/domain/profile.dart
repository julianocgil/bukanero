/// Um usuário do app com a sua playlist (URL http/https ou arquivo local).
class Profile {
  const Profile({
    required this.id,
    required this.name,
    required this.url,
    this.epgUrl,
    this.allowInsecure = false,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json['id'] as String,
    name: json['name'] as String,
    url: json['url'] as String,
    epgUrl: json['epgUrl'] as String?,
    allowInsecure: (json['allowInsecure'] as bool?) ?? false,
  );

  final String id;
  final String name;
  final String url;

  /// URL (ou arquivo) XMLTV informada à mão. Se nula, o app procura sozinho.
  final String? epgUrl;

  /// Aceita certificado TLS inválido (autoassinado) do servidor da lista.
  final bool allowInsecure;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'url': url,
    if (epgUrl != null) 'epgUrl': epgUrl,
    if (allowInsecure) 'allowInsecure': true,
  };
}
