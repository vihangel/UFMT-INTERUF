// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament_game_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TournamentGameDetail _$TournamentGameDetailFromJson(
  Map<String, dynamic> json,
) => TournamentGameDetail(
  gameId: json['game_id'] as String,
  status: json['status'] as String,
  startAt: DateTime.parse(json['start_at'] as String),
  modality: json['modality'] as String,
  phase: json['phase'] as String,
  venueName: json['venue_name'] as String?,
  teamAId: json['team_a_id'] as String?,
  teamAName: json['team_a_name'] as String,
  teamALogo: json['team_a_logo'] as String,
  teamBId: json['team_b_id'] as String?,
  teamBName: json['team_b_name'] as String,
  teamBLogo: json['team_b_logo'] as String,
  scoreA: (json['score_a'] as num).toInt(),
  scoreB: (json['score_b'] as num).toInt(),
);

Map<String, dynamic> _$TournamentGameDetailToJson(
  TournamentGameDetail instance,
) => <String, dynamic>{
  'game_id': instance.gameId,
  'status': instance.status,
  'start_at': instance.startAt.toIso8601String(),
  'modality': instance.modality,
  'phase': instance.phase,
  'venue_name': instance.venueName,
  'team_a_id': instance.teamAId,
  'team_a_name': instance.teamAName,
  'team_a_logo': instance.teamALogo,
  'team_b_id': instance.teamBId,
  'team_b_name': instance.teamBName,
  'team_b_logo': instance.teamBLogo,
  'score_a': instance.scoreA,
  'score_b': instance.scoreB,
};

GameStatistic _$GameStatisticFromJson(Map<String, dynamic> json) =>
    GameStatistic(
      name: json['name'] as String,
      code: json['code'] as String,
      teamAValue: (json['team_a_value'] as num).toInt(),
      teamBValue: (json['team_b_value'] as num).toInt(),
      sortOrder: (json['sort_order'] as num?)?.toInt(),
    );

Map<String, dynamic> _$GameStatisticToJson(GameStatistic instance) =>
    <String, dynamic>{
      'name': instance.name,
      'code': instance.code,
      'team_a_value': instance.teamAValue,
      'team_b_value': instance.teamBValue,
      'sort_order': instance.sortOrder,
    };

GameAthlete _$GameAthleteFromJson(Map<String, dynamic> json) => GameAthlete(
  athleteId: json['athlete_id'] as String,
  fullName: json['full_name'] as String,
  shirtNumber: (json['shirt_number'] as num).toInt(),
  athleticId: json['athletic_id'] as String,
);

Map<String, dynamic> _$GameAthleteToJson(GameAthlete instance) =>
    <String, dynamic>{
      'athlete_id': instance.athleteId,
      'full_name': instance.fullName,
      'shirt_number': instance.shirtNumber,
      'athletic_id': instance.athleticId,
    };
