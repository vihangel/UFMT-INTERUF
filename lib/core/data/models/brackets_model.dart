import 'package:json_annotation/json_annotation.dart';

part 'brackets_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Bracket {
  final String id;
  final String modalityId;
  final String series;
  final int? year;
  final List<String>? heapBrackeat;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bracket({
    required this.id,
    required this.modalityId,
    required this.series,
    this.year,
    this.heapBrackeat,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Bracket.fromJson(Map<String, dynamic> json) =>
      _$BracketFromJson(json);

  Map<String, dynamic> toJson() => _$BracketToJson(this);
}
