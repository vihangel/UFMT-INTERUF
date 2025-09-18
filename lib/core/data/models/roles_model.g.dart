// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roles_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Role _$RoleFromJson(Map<String, dynamic> json) => Role(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  role: json['role'] as String,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$RoleToJson(Role instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'role': instance.role,
  'created_at': instance.createdAt?.toIso8601String(),
};
