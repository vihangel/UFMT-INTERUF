// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'athletes_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Athlete _$AthleteFromJson(Map<String, dynamic> json) => Athlete(
  id: json['id'] as String,
  athleticId: json['athletic_id'] as String,
  fullName: json['full_name'] as String,
  rga: json['rga'] as String?,
  course: json['course'] as String?,
  birthdate: json['birthdate'] == null
      ? null
      : DateTime.parse(json['birthdate'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$AthleteToJson(Athlete instance) => <String, dynamic>{
  'id': instance.id,
  'athletic_id': instance.athleticId,
  'full_name': instance.fullName,
  'rga': instance.rga,
  'course': instance.course,
  'birthdate': instance.birthdate?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
