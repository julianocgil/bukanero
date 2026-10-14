/// Um item de uma playlist (canal ao vivo, filme ou episódio).
class Channel {
  const Channel({
    required this.name,
    required this.url,
    this.group,
    this.logo,
    this.tvgId,
    this.tvgName,
  });

  final String name;
  final String url;
  final String? group;
  final String? logo;
  final String? tvgId;
  final String? tvgName;

  @override
  String toString() => 'Channel($name, group: $group)';
}
