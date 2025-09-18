import 'package:json_annotation/json_annotation.dart';

part 'stat_definitions_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class StatDefinition {
  final String code;
  final String name;
  final String? description;
  final String? unit;
  final int sortOrder;

  StatDefinition({
    required this.code,
    required this.name,
    this.description,
    this.unit,
    required this.sortOrder,
  });

  factory StatDefinition.fromJson(Map<String, dynamic> json) =>
      _$StatDefinitionFromJson(json);

  Map<String, dynamic> toJson() => _$StatDefinitionToJson(this);
}
