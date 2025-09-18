// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'athlete_game_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AthleteGame _$AthleteGameFromJson(Map<String, dynamic> json) => AthleteGame(
  gameId: json['game_id'] as String,
  athleteId: json['athlete_id'] as String,
  shirtNumber: (json['shirt_number'] as num).toInt(),
);

Map<String, dynamic> _$AthleteGameToJson(AthleteGame instance) =>
    <String, dynamic>{
      'game_id': instance.gameId,
      'athlete_id': instance.athleteId,
      'shirt_number': instance.shirtNumber,
    };
