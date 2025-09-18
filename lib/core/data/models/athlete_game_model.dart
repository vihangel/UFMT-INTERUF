import 'package:json_annotation/json_annotation.dart';

part 'athlete_game_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AthleteGame {
  final String gameId;
  final String athleteId;
  final int shirtNumber;

  AthleteGame({
    required this.gameId,
    required this.athleteId,
    required this.shirtNumber,
  });

  factory AthleteGame.fromJson(Map<String, dynamic> json) =>
      _$AthleteGameFromJson(json);

  Map<String, dynamic> toJson() => _$AthleteGameToJson(this);
}
