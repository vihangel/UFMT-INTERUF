// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameDetail _$GameDetailFromJson(Map<String, dynamic> json) => GameDetail(
  gameId: json['game_id'] as String,
  modalityName: json['modality_name'] as String,
  modalityGender: json['modality_gender'] as String,
  startAt: DateTime.parse(json['start_at'] as String),
  status: json['status'] as String,
  venueName: json['venue_name'] as String?,
  participatingAthleticsIds:
      (json['participating_athletics_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  standings: (json['standings'] as List<dynamic>)
      .map((e) => AthleteStanding.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GameDetailToJson(GameDetail instance) =>
    <String, dynamic>{
      'game_id': instance.gameId,
      'modality_name': instance.modalityName,
      'modality_gender': instance.modalityGender,
      'start_at': instance.startAt.toIso8601String(),
      'status': instance.status,
      'venue_name': instance.venueName,
      'participating_athletics_ids': instance.participatingAthleticsIds,
      'standings': instance.standings,
    };

AthleteStanding _$AthleteStandingFromJson(Map<String, dynamic> json) =>
    AthleteStanding(
      position: (json['position'] as num).toInt(),
      athleteId: json['athlete_id'] as String,
      athleteName: json['athlete_name'] as String,
      athleticId: json['athletic_id'] as String,
      athleticName: json['athletic_name'] as String,
      athleticLogoUrl: json['athletic_logo_url'] as String?,
      stats: json['stats'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AthleteStandingToJson(AthleteStanding instance) =>
    <String, dynamic>{
      'position': instance.position,
      'athlete_id': instance.athleteId,
      'athlete_name': instance.athleteName,
      'athletic_id': instance.athleticId,
      'athletic_name': instance.athleticName,
      'athletic_logo_url': instance.athleticLogoUrl,
      'stats': instance.stats,
    };
