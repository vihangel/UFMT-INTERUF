import 'package:json_annotation/json_annotation.dart';

part 'athletes_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Athlete {
  final String id;
  final String athleticId;
  final String fullName;
  final String? rga;
  final String? course;
  final DateTime? birthdate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Athlete({
    required this.id,
    required this.athleticId,
    required this.fullName,
    this.rga,
    this.course,
    this.birthdate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Athlete.fromJson(Map<String, dynamic> json) =>
      _$AthleteFromJson(json);

  Map<String, dynamic> toJson() => _$AthleteToJson(this);
}
