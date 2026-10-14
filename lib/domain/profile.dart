/// Um usuário do app com a sua playlist (URL http/https ou arquivo local).
class Profile {
  const Profile({required this.id, required this.name, required this.url});

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json['id'] as String,
    name: json['name'] as String,
    url: json['url'] as String,
  );

  final String id;
  final String name;
  final String url;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'url': url,
  };
}
