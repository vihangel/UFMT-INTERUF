// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameStats _$GameStatsFromJson(Map<String, dynamic> json) => GameStats(
  gameId: json['game_id'] as String,
  statCode: json['stat_code'] as String,
  value: (json['value'] as num).toInt(),
);

Map<String, dynamic> _$GameStatsToJson(GameStats instance) => <String, dynamic>{
  'game_id': instance.gameId,
  'stat_code': instance.statCode,
  'value': instance.value,
};
