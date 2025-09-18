// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'athlete_game_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AthleteGameStats _$AthleteGameStatsFromJson(Map<String, dynamic> json) =>
    AthleteGameStats(
      gameId: json['game_id'] as String,
      athleteId: json['athlete_id'] as String,
      statCode: json['stat_code'] as String,
      value: (json['value'] as num).toInt(),
    );

Map<String, dynamic> _$AthleteGameStatsToJson(AthleteGameStats instance) =>
    <String, dynamic>{
      'game_id': instance.gameId,
      'athlete_id': instance.athleteId,
      'stat_code': instance.statCode,
      'value': instance.value,
    };
