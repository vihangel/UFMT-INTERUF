import 'package:json_annotation/json_annotation.dart';

part 'game_detail_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class GameDetail {
  final String gameId;
  final String modalityName;
  final String modalityGender;
  final DateTime startAt;
  final String status;
  final String? venueName;
  final List<String> participatingAthleticsIds;
  final List<AthleteStanding> standings;

  GameDetail({
    required this.gameId,
    required this.modalityName,
    required this.modalityGender,
    required this.startAt,
    required this.status,
    this.venueName,
    required this.participatingAthleticsIds,
    required this.standings,
  });

  factory GameDetail.fromJson(Map<String, dynamic> json) =>
      _$GameDetailFromJson(json);

  Map<String, dynamic> toJson() => _$GameDetailToJson(this);

  String get fullModalityName => '$modalityName $modalityGender';

  String get statusDisplayText {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'Agendado';
      case 'inprogress':
      case 'in_progress':
        return 'Em andamento';
      case 'finished':
        return 'Finalizado';
      default:
        return status;
    }
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AthleteStanding {
  final int position;
  final String athleteId;
  final String athleteName;
  final String athleticId;
  final String athleticName;
  final String? athleticLogoUrl;
  final Map<String, dynamic>? stats;

  const AthleteStanding({
    required this.position,
    required this.athleteId,
    required this.athleteName,
    required this.athleticId,
    required this.athleticName,
    this.athleticLogoUrl,
    this.stats,
  });

  factory AthleteStanding.fromJson(Map<String, dynamic> json) =>
      _$AthleteStandingFromJson(json);

  Map<String, dynamic> toJson() => _$AthleteStandingToJson(this);

  String get athleticLogoPath =>
      athleticLogoUrl != null ? 'images/${athleticLogoUrl!}' : '';
}
