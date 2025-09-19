import 'package:json_annotation/json_annotation.dart';

part 'venues_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Venue {
  final String id;
  final String name;
  final String? address;
  final double? lat;
  final double? lng;
  final DateTime createdAt;
  final DateTime updatedAt;

  Venue({
    required this.id,
    required this.name,
    this.address,
    this.lat,
    this.lng,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Venue.fromJson(Map<String, dynamic> json) => _$VenueFromJson(json);

  Map<String, dynamic> toJson() => _$VenueToJson(this);
}
