import 'package:json_annotation/json_annotation.dart';

part 'athlete_game_stats_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AthleteGameStats {
  final String gameId;
  final String athleteId;
  final String statCode;
  final int value;

  AthleteGameStats({
    required this.gameId,
    required this.athleteId,
    required this.statCode,
    required this.value,
  });

  factory AthleteGameStats.fromJson(Map<String, dynamic> json) =>
      _$AthleteGameStatsFromJson(json);

  Map<String, dynamic> toJson() => _$AthleteGameStatsToJson(this);
}
