import 'package:json_annotation/json_annotation.dart';

part 'league_socials_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class LeagueSocial {
  final String id;
  final String url;

  LeagueSocial({required this.id, required this.url});

  factory LeagueSocial.fromJson(Map<String, dynamic> json) =>
      _$LeagueSocialFromJson(json);

  Map<String, dynamic> toJson() => _$LeagueSocialToJson(this);
}
