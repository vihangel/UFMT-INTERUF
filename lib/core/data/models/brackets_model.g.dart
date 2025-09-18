// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brackets_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bracket _$BracketFromJson(Map<String, dynamic> json) => Bracket(
  id: json['id'] as String,
  modalityId: json['modality_id'] as String,
  series: json['series'] as String,
  year: (json['year'] as num?)?.toInt(),
  heapBrackeat: (json['heap_brackeat'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$BracketToJson(Bracket instance) => <String, dynamic>{
  'id': instance.id,
  'modality_id': instance.modalityId,
  'series': instance.series,
  'year': instance.year,
  'heap_brackeat': instance.heapBrackeat,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
