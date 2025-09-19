import 'package:json_annotation/json_annotation.dart';

part 'news_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class News {
  final String id;
  final String title;
  final String? summary;
  final String? body;
  final String? imageUrl;
  final DateTime? publishedAt;
  final String? sourceUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  News({
    required this.id,
    required this.title,
    this.summary,
    this.body,
    this.imageUrl,
    this.publishedAt,
    this.sourceUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory News.fromJson(Map<String, dynamic> json) => _$NewsFromJson(json);

  Map<String, dynamic> toJson() => _$NewsToJson(this);
}
