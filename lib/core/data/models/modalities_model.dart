import 'package:json_annotation/json_annotation.dart';

part 'modalities_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Modality {
  final String id;
  final String name;
  final String gender;
  final String? icon;
  final DateTime createdAt;
  final DateTime updatedAt;

  Modality({
    required this.id,
    required this.name,
    required this.gender,
    this.icon,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Modality.fromJson(Map<String, dynamic> json) =>
      _$ModalityFromJson(json);

  Map<String, dynamic> toJson() => _$ModalityToJson(this);
}
