// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

News _$NewsFromJson(Map<String, dynamic> json) => News(
  id: json['id'] as String,
  title: json['title'] as String,
  summary: json['summary'] as String?,
  body: json['body'] as String?,
  imageUrl: json['image_url'] as String?,
  publishedAt: json['published_at'] == null
      ? null
      : DateTime.parse(json['published_at'] as String),
  sourceUrl: json['source_url'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$NewsToJson(News instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'summary': instance.summary,
  'body': instance.body,
  'image_url': instance.imageUrl,
  'published_at': instance.publishedAt?.toIso8601String(),
  'source_url': instance.sourceUrl,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
