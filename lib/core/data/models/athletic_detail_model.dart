// lib/core/data/models/athletic_detail_model.dart

class AthleticDetail {
  final String id;
  final String name;
  final String nickname;
  final String logoUrl;
  final String series;
  final String? description;

  const AthleticDetail({
    required this.id,
    required this.name,
    required this.nickname,
    required this.logoUrl,
    required this.series,
    this.description,
  });

  factory AthleticDetail.fromJson(Map<String, dynamic> json) {
    return AthleticDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      nickname: json['nickname'] as String,
      logoUrl: json['logo_url'] as String? ?? '',
      series: json['series'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nickname': nickname,
      'logo_url': logoUrl,
      'series': series,
      'description': description,
    };
  }

  // Helper method to get the correct asset path for athletic logos
  String get assetPath => 'images/$logoUrl';
}
