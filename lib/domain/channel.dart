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
  });

  final String name;
  final String url;
  final String? group;
  final String? logo;
  final String? tvgId;
  final String? tvgName;

  /// Nota vinda do servidor da lista (quando há), na escala dele.
  final double? rating;

  @override
  String toString() => 'Channel($name, group: $group)';
}
