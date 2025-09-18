// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'games_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Game _$GameFromJson(Map<String, dynamic> json) => Game(
  id: json['id'] as String,
  modalityId: json['modality_id'] as String,
  series: json['series'] as String,
  startAt: DateTime.parse(json['start_at'] as String),
  venueId: json['venue_id'] as String?,
  aAthleticId: json['a_athletic_id'] as String?,
  bAthleticId: json['b_athletic_id'] as String?,
  scoreA: (json['score_a'] as num?)?.toInt(),
  scoreB: (json['score_b'] as num?)?.toInt(),
  partials: (json['partials'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
  athleticsStandings: (json['athletics_standings'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
  winnerAthleticId: json['winner_athletic_id'] as String?,
  status: json['status'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$GameToJson(Game instance) => <String, dynamic>{
  'id': instance.id,
  'modality_id': instance.modalityId,
  'series': instance.series,
  'start_at': instance.startAt.toIso8601String(),
  'venue_id': instance.venueId,
  'a_athletic_id': instance.aAthleticId,
  'b_athletic_id': instance.bAthleticId,
  'score_a': instance.scoreA,
  'score_b': instance.scoreB,
  'partials': instance.partials,
  'athletics_standings': instance.athleticsStandings,
  'winner_athletic_id': instance.winnerAthleticId,
  'status': instance.status,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
