import 'package:json_annotation/json_annotation.dart';

part 'athletic_vote_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AthleticVote {
  final String id;
  final String athleticId;
  final String votanteId;
  final DateTime createdAt;
  final DateTime updatedAt;

  AthleticVote({
    required this.id,
    required this.athleticId,
    required this.votanteId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AthleticVote.fromJson(Map<String, dynamic> json) =>
      _$AthleticVoteFromJson(json);

  Map<String, dynamic> toJson() => _$AthleticVoteToJson(this);
}
