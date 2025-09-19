// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stat_definitions_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatDefinition _$StatDefinitionFromJson(Map<String, dynamic> json) =>
    StatDefinition(
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      unit: json['unit'] as String?,
      sortOrder: (json['sort_order'] as num).toInt(),
    );

Map<String, dynamic> _$StatDefinitionToJson(StatDefinition instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'description': instance.description,
      'unit': instance.unit,
      'sort_order': instance.sortOrder,
    };
