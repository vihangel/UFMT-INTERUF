// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'athletic_vote_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AthleticVote _$AthleticVoteFromJson(Map<String, dynamic> json) => AthleticVote(
  id: json['id'] as String,
  athleticId: json['athletic_id'] as String,
  votanteId: json['votante_id'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$AthleticVoteToJson(AthleticVote instance) =>
    <String, dynamic>{
      'id': instance.id,
      'athletic_id': instance.athleticId,
      'votante_id': instance.votanteId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
