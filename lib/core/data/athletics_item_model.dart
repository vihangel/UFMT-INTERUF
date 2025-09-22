// lib/core/data/athletics_item_model.dart

class AthleticsItem {
  final String id;
  final String name;
  final String nickname;
  final String logoUrl;

  const AthleticsItem({
    required this.id,
    required this.name,
    required this.nickname,
    required this.logoUrl,
  });

  factory AthleticsItem.fromJson(Map<String, dynamic> json) {
    return AthleticsItem(
      id: json['id'] as String,
      name: json['name'] as String,
      nickname: json['nickname'] as String,
      logoUrl: json['logo_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'nickname': nickname, 'logo_url': logoUrl};
  }

  // Helper method to get the correct asset path for athletic logos
  String get assetPath => 'images/$logoUrl';
}
