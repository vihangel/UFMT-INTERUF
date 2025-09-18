import 'package:json_annotation/json_annotation.dart';

part 'games_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Game {
  final String id;
  final String modalityId;
  final String series;
  final DateTime startAt;
  final String? venueId;
  final String? aAthleticId;
  final String? bAthleticId;
  final int? scoreA;
  final int? scoreB;
  final List<Map<String, dynamic>>? partials;
  final List<Map<String, dynamic>>? athleticsStandings;
  final String? winnerAthleticId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Game({
    required this.id,
    required this.modalityId,
    required this.series,
    required this.startAt,
    this.venueId,
    this.aAthleticId,
    this.bAthleticId,
    this.scoreA,
    this.scoreB,
    this.partials,
    this.athleticsStandings,
    this.winnerAthleticId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);

  Map<String, dynamic> toJson() => _$GameToJson(this);
}
