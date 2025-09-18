// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modalities_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Modality _$ModalityFromJson(Map<String, dynamic> json) => Modality(
  id: json['id'] as String,
  name: json['name'] as String,
  gender: json['gender'] as String,
  icon: json['icon'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ModalityToJson(Modality instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'gender': instance.gender,
  'icon': instance.icon,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
