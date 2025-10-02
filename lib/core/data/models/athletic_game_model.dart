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
  final Map<String, dynamic>? athleticsStandings;

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
    this.athleticsStandings,
  });

  factory AthleticGame.fromJson(Map<String, dynamic> json) {
    // Handle athletics_standings which can be Map, List, or null
    Map<String, dynamic>? athleticsStandings;
    final rawStandings = json['athletics_standings'];

    if (rawStandings is Map<String, dynamic>) {
      athleticsStandings = rawStandings;
    } else if (rawStandings is List) {
      // Convert List to the expected format
      athleticsStandings = {
        'athletics_data': rawStandings
            .map((item) => {'logo_url': item is Map ? item['logo_url'] : null})
            .where((item) => item['logo_url'] != null)
            .toList(),
      };
    }

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
      athleticsStandings: athleticsStandings,
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
      'athletics_standings': athleticsStandings,
    };
  }

  // Helper methods
  bool get isTwoTeamGame => teamAId != null && teamBId != null;

  bool get isMultiTeamGame =>
      athleticsStandings != null &&
      athleticsStandings!['athletics_data'] != null;

  List<String> get multiTeamLogos {
    if (!isMultiTeamGame) return [];

    final athleticsData = athleticsStandings!['athletics_data'] as List?;
    if (athleticsData == null) return [];

    return athleticsData
        .map((team) => team['logo_url'] as String?)
        .where((logo) => logo != null)
        .cast<String>()
        .toList();
  }

  // Helper method to get team A asset path
  String? get teamAAssetPath => teamALogo != null ? 'images/$teamALogo' : null;

  // Helper method to get team B asset path
  String? get teamBAssetPath => teamBLogo != null ? 'images/$teamBLogo' : null;
}
