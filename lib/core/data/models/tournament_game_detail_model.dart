import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';

part 'tournament_game_detail_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TournamentGameDetail {
  final String gameId;
  final String status;
  final DateTime startAt;
  final String modality;
  final String phase;
  final String? venueName;
  final String? teamAId;
  final String teamAName;
  final String teamALogo;
  final String? teamBId;
  final String teamBName;
  final String teamBLogo;
  final int scoreA;
  final int scoreB;

  TournamentGameDetail({
    required this.gameId,
    required this.status,
    required this.startAt,
    required this.modality,
    required this.phase,
    this.venueName,
    this.teamAId,
    required this.teamAName,
    required this.teamALogo,
    this.teamBId,
    required this.teamBName,
    required this.teamBLogo,
    required this.scoreA,
    required this.scoreB,
  });

  factory TournamentGameDetail.fromJson(Map<String, dynamic> json) =>
      _$TournamentGameDetailFromJson(json);

  Map<String, dynamic> toJson() => _$TournamentGameDetailToJson(this);

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

  String get teamALogoPath => 'assets/images/$teamALogo';
  String get teamBLogoPath => 'assets/images/$teamBLogo';

  String get formattedTime => DateFormat('HH:mm').format(startAt);
  String get formattedDate => DateFormat('dd/MM/yyyy').format(startAt);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GameStatistic {
  final String name;
  final String code;
  final int teamAValue;
  final int teamBValue;
  final int? sortOrder;

  GameStatistic({
    required this.name,
    required this.code,
    required this.teamAValue,
    required this.teamBValue,
    this.sortOrder,
  });

  factory GameStatistic.fromJson(Map<String, dynamic> json) =>
      _$GameStatisticFromJson(json);

  Map<String, dynamic> toJson() => _$GameStatisticToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GameAthlete {
  final String athleteId;
  final String fullName;
  final int shirtNumber;
  final String athleticId;

  GameAthlete({
    required this.athleteId,
    required this.fullName,
    required this.shirtNumber,
    required this.athleticId,
  });

  factory GameAthlete.fromJson(Map<String, dynamic> json) =>
      _$GameAthleteFromJson(json);

  Map<String, dynamic> toJson() => _$GameAthleteToJson(this);
}
