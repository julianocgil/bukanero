/// Um item de uma playlist (canal ao vivo, filme ou episódio).
class Channel {
  const Channel({
    required this.name,
    required this.url,
    this.group,
    this.logo,
    this.tvgId,
    this.tvgName,
    this.rating,
    this.itemId,
    this.versions = const <ChannelVersion>[],
    this.groupKey,
  });

  final String name;
  final String url;
  final String? group;
  final String? logo;
  final String? tvgId;
  final String? tvgName;

  /// Nota vinda do servidor da lista (quando há), na escala dele.
  final double? rating;

  /// Id do item no catálogo (para achar o grupo dele).
  final int? itemId;

  /// Num cartão agrupado: todas as versões, da preferida para a última
  /// (este próprio item é a primeira). Vazio num item sozinho.
  final List<ChannelVersion> versions;

  /// Identifica o grupo, para o usuário poder separá-lo.
  final String? groupKey;

  bool get isGroup => versions.length > 1;

  @override
  String toString() => 'Channel($name, group: $group)';
}

/// Uma versão de um cartão agrupado ("FHD", "HD LEG", "2 4K").
class ChannelVersion {
  const ChannelVersion(this.label, this.channel, {String? mark})
    : mark = mark ?? label;

  final String label;
  final Channel channel;

  /// A marca sem o número da família ("FHD" em "2 FHD").
  final String mark;
}
