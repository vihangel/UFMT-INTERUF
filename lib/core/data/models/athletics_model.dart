import 'package:json_annotation/json_annotation.dart';

part 'athletics_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Athletics {
  final String id;
  final String name;
  final String? nickname;
  final String series;
  final String? logoUrl;
  final String? description;
  final String? instagram;
  final String? twitter;
  final String? youtube;
  final DateTime createdAt;
  final DateTime updatedAt;

  Athletics({
    required this.id,
    required this.name,
    this.nickname,
    required this.series,
    this.logoUrl,
    this.description,
    this.instagram,
    this.twitter,
    this.youtube,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Athletics.fromJson(Map<String, dynamic> json) =>
      _$AthleticsFromJson(json);

  Map<String, dynamic> toJson() => _$AthleticsToJson(this);
}
