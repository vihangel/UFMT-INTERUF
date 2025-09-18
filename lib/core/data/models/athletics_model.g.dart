// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'athletics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Athletics _$AthleticsFromJson(Map<String, dynamic> json) => Athletics(
  id: json['id'] as String,
  name: json['name'] as String,
  nickname: json['nickname'] as String?,
  series: json['series'] as String,
  logoUrl: json['logo_url'] as String?,
  description: json['description'] as String?,
  instagram: json['instagram'] as String?,
  twitter: json['twitter'] as String?,
  youtube: json['youtube'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$AthleticsToJson(Athletics instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'nickname': instance.nickname,
  'series': instance.series,
  'logo_url': instance.logoUrl,
  'description': instance.description,
  'instagram': instance.instagram,
  'twitter': instance.twitter,
  'youtube': instance.youtube,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
