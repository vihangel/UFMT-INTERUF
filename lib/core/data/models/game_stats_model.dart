import 'package:json_annotation/json_annotation.dart';

part 'game_stats_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class GameStats {
  final String gameId;
  final String statCode;
  final int value;

  GameStats({
    required this.gameId,
    required this.statCode,
    required this.value,
  });

  factory GameStats.fromJson(Map<String, dynamic> json) =>
      _$GameStatsFromJson(json);

  Map<String, dynamic> toJson() => _$GameStatsToJson(this);
}
