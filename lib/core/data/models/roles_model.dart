import 'package:json_annotation/json_annotation.dart';

part 'roles_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Role {
  final String id;
  final String userId;
  final String role;
  final DateTime? createdAt;

  Role({
    required this.id,
    required this.userId,
    required this.role,
    this.createdAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);

  Map<String, dynamic> toJson() => _$RoleToJson(this);
}
