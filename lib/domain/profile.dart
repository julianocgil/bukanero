/// Um usuário do app com a sua playlist (URL http/https ou arquivo local).
class Profile {
  const Profile({
    required this.id,
    required this.name,
    required this.url,
    this.epgUrl,
    this.allowInsecure = false,
    this.refreshHours = defaultRefreshHours,
  });

  /// Intervalo padrão da atualização automática da lista.
  static const int defaultRefreshHours = 24;

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json['id'] as String,
    name: json['name'] as String,
    url: json['url'] as String,
    epgUrl: json['epgUrl'] as String?,
    allowInsecure: (json['allowInsecure'] as bool?) ?? false,
    refreshHours: (json['refreshHours'] as int?) ?? defaultRefreshHours,
  );

  final String id;
  final String name;
  final String url;

  /// URL (ou arquivo) XMLTV informada à mão. Se nula, o app procura sozinho.
  final String? epgUrl;

  /// Aceita certificado TLS inválido (autoassinado) do servidor da lista.
  final bool allowInsecure;

  /// De quantas em quantas horas a lista é baixada de novo sozinha
  /// (0 = só quando o usuário pedir).
  final int refreshHours;

  /// Se a lista baixada em [last] já passou do intervalo em [now].
  bool listRefreshDue(DateTime? last, DateTime now) {
    if (refreshHours <= 0 || last == null) return false;
    return now.difference(last) >= Duration(hours: refreshHours);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'url': url,
    if (epgUrl != null) 'epgUrl': epgUrl,
    if (allowInsecure) 'allowInsecure': true,
    if (refreshHours != defaultRefreshHours) 'refreshHours': refreshHours,
  };
}
