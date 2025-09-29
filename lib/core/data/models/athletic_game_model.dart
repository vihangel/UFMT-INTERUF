// lib/core/data/models/athletic_game_model.dart

class AthleticGame {
  final String gameId;
  final DateTime startAt;
  final String status;
  final String modalityPhase;
  final String? venueName;
  final String? teamAId;
  final String? teamALogo;
  final String? teamBId;
  final String? teamBLogo;
  final int? scoreA;
  final int? scoreB;

  const AthleticGame({
    required this.gameId,
    required this.startAt,
    required this.status,
    required this.modalityPhase,
    this.venueName,
    this.teamAId,
    this.teamALogo,
    this.teamBId,
    this.teamBLogo,
    this.scoreA,
    this.scoreB,
  });

  factory AthleticGame.fromJson(Map<String, dynamic> json) {
    return AthleticGame(
      gameId: json['game_id'] as String,
      startAt: DateTime.parse(json['start_at'] as String),
      status: json['status'] as String,
      modalityPhase: json['modality_phase'] as String,
      venueName: json['venue_name'] as String?,
      teamAId: json['team_a_id'] as String?,
      teamALogo: json['team_a_logo'] as String?,
      teamBId: json['team_b_id'] as String?,
      teamBLogo: json['team_b_logo'] as String?,
      scoreA: json['score_a'] as int?,
      scoreB: json['score_b'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'game_id': gameId,
      'start_at': startAt.toIso8601String(),
      'status': status,
      'modality_phase': modalityPhase,
      'venue_name': venueName,
      'team_a_id': teamAId,
      'team_a_logo': teamALogo,
      'team_b_id': teamBId,
      'team_b_logo': teamBLogo,
      'score_a': scoreA,
      'score_b': scoreB,
    };
  }

  // Helper method to get team A asset path
  String? get teamAAssetPath => teamALogo != null ? 'images/$teamALogo' : null;

  // Helper method to get team B asset path
  String? get teamBAssetPath => teamBLogo != null ? 'images/$teamBLogo' : null;
}
