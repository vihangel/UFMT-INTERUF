// lib/core/data/models/bracket_game_model.dart

import 'package:interufmt/core/theme/app_icons.dart';
import 'package:intl/intl.dart';

class BracketGame {
  final String gameId;
  final String status;
  final String series;
  final DateTime startAt;
  final String modality;
  final String phase;
  final String? venueName;
  final String? teamAId;
  final String? teamAName;
  final String? teamALogo;
  final String? teamBId;
  final String? teamBName;
  final String? teamBLogo;
  final int scoreA;
  final int scoreB;

  BracketGame({
    required this.gameId,
    required this.status,
    required this.series,
    required this.startAt,
    required this.modality,
    required this.phase,
    this.venueName,
    this.teamAId,
    this.teamAName,
    this.teamALogo,
    this.teamBId,
    this.teamBName,
    this.teamBLogo,
    required this.scoreA,
    required this.scoreB,
  });

  factory BracketGame.fromJson(Map<String, dynamic> json) {
    return BracketGame(
      gameId: json['game_id'] as String,
      status: json['status'] as String,
      series: json['series'] as String,
      startAt: json['start_at'] is String
          ? DateTime.parse(json['start_at'])
          : json['start_at'] as DateTime,
      modality: json['modality'] as String,
      phase: json['phase'] as String,
      venueName: json['venue_name'] as String?,
      teamAId: json['team_a_id'] as String?,
      teamAName: json['team_a_name'] as String?,
      teamALogo: json['team_a_logo'] as String?,
      teamBId: json['team_b_id'] as String?,
      teamBName: json['team_b_name'] as String?,
      teamBLogo: json['team_b_logo'] as String?,
      scoreA: (json['score_a'] as int?) ?? 0,
      scoreB: (json['score_b'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'game_id': gameId,
      'status': status,
      'series': series,
      'start_at': startAt.toIso8601String(),
      'modality': modality,
      'phase': phase,
      'venue_name': venueName,
      'team_a_id': teamAId,
      'team_a_name': teamAName,
      'team_a_logo': teamALogo,
      'team_b_id': teamBId,
      'team_b_name': teamBName,
      'team_b_logo': teamBLogo,
      'score_a': scoreA,
      'score_b': scoreB,
    };
  }

  // Helper methods
  bool get hasTeams => teamAId != null && teamBId != null;

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

  String get startTimeDateFormatted {
    return DateFormat('HH:mm - EEE, dd MMM', 'pt_BR').format(startAt);
  }

  String get gameIcon => AppIcons.getGameIcon(modality);

  String get teamALogoPath => teamALogo != null
      ? 'assets/images/$teamALogo'
      : 'assets/images/blankimg.png';

  String get teamBLogoPath => teamBLogo != null
      ? 'assets/images/$teamBLogo'
      : 'assets/images/blankimg.png';
}
