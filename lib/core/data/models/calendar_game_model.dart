class CalendarGame {
  final String gameId;
  final DateTime startAt;
  final String status;
  final String series;
  final Map<String, dynamic>? athleticsStandings;
  final String modalityPhase;
  final String? venueName;
  final String? teamAId;
  final String? teamALogo;
  final String? teamBId;
  final String? teamBLogo;
  final int? scoreA;
  final int? scoreB;

  CalendarGame({
    required this.gameId,
    required this.startAt,
    required this.status,
    required this.series,
    this.athleticsStandings,
    required this.modalityPhase,
    this.venueName,
    this.teamAId,
    this.teamALogo,
    this.teamBId,
    this.teamBLogo,
    this.scoreA,
    this.scoreB,
  });

  factory CalendarGame.fromJson(Map<String, dynamic> json) {
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

    return CalendarGame(
      gameId: json['game_id'] as String,
      startAt: json['start_at'] is String
          ? DateTime.parse(json['start_at'])
          : json['start_at'] as DateTime,
      status: json['status'] as String,
      series: json['series'] as String,
      athleticsStandings: athleticsStandings,
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
      'series': series,
      'athletics_standings': athleticsStandings,
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

  int get displayScoreA => scoreA ?? 0;
  int get displayScoreB => scoreB ?? 0;

  String get statusDisplayText {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'Agendado';
      case 'inprogress':
      case 'in_progress':
        return 'Em andamento';
      case 'finished':
        return 'Finalizado';
      default:
        return status;
    }
  }

  String get dayLabel {
    // Extract day from date for "Dia 1", "Dia 2", "Dia 3" classification
    final day = startAt.day;
    final baseDay =
        30; // Assuming competition starts on day 30 based on your query
    final dayNumber = day - baseDay + 1;
    return 'Dia $dayNumber';
  }
}
