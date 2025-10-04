// lib/core/data/models/athletic_game_model.dart
import 'package:interufmt/core/theme/app_icons.dart';
import 'package:intl/intl.dart';

typedef Json = Map<String, dynamic>;

class AthleticGameKeys {
  static const gameId = 'game_id';
  static const modalityId = 'modality_id';
  static const startAt = 'start_at';
  static const status = 'status';
  static const series = 'series';
  static const modalityPhase = 'modality_phase';
  static const venueName = 'venue_name';
  static const teamAId = 'team_a_id';
  static const teamALogo = 'team_a_logo';
  static const teamBId = 'team_b_id';
  static const teamBLogo = 'team_b_logo';
  static const scoreA = 'score_a';
  static const scoreB = 'score_b';
  static const athleticsStandings = 'athletics_standings';

  static const athleticsData = 'athletics_data';
  static const logoUrl = 'logo_url';
}

class AthleticGame {
  final String gameId;
  final DateTime startAt;
  final String status;
  final String modalityPhase;
  final String? venueName;

  final String? modalityId;
  final String? series;

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
    this.modalityId,
    this.series,
    this.teamAId,
    this.teamALogo,
    this.teamBId,
    this.teamBLogo,
    this.scoreA,
    this.scoreB,
    this.athleticsStandings,
  });

  factory AthleticGame.fromJson(Json json) {
    // Normaliza athletics_standings para um Map com 'athletics_data'
    Map<String, dynamic>? normalizedStandings;
    final rawStandings = json[AthleticGameKeys.athleticsStandings];

    if (rawStandings is Map<String, dynamic>) {
      normalizedStandings = rawStandings;
    } else if (rawStandings is List) {
      normalizedStandings = {
        AthleticGameKeys.athleticsData: rawStandings
            .whereType<Map>() // garante Map
            .map(
              (item) => {
                AthleticGameKeys.logoUrl: item[AthleticGameKeys.logoUrl],
              },
            )
            .where((m) => m[AthleticGameKeys.logoUrl] != null)
            .toList(),
      };
    }

    final rawStart = json[AthleticGameKeys.startAt];
    final date = rawStart is String
        ? DateTime.parse(rawStart)
        : rawStart as DateTime;

    return AthleticGame(
      gameId: json[AthleticGameKeys.gameId] as String,
      startAt: date,
      status: json[AthleticGameKeys.status] as String,
      modalityPhase: json[AthleticGameKeys.modalityPhase] as String,
      venueName: json[AthleticGameKeys.venueName] as String?,
      modalityId: json[AthleticGameKeys.modalityId] as String?,
      series: json[AthleticGameKeys.series] as String?,
      teamAId: json[AthleticGameKeys.teamAId] as String?,
      teamALogo: json[AthleticGameKeys.teamALogo] as String?,
      teamBId: json[AthleticGameKeys.teamBId] as String?,
      teamBLogo: json[AthleticGameKeys.teamBLogo] as String?,
      scoreA: json[AthleticGameKeys.scoreA] as int?,
      scoreB: json[AthleticGameKeys.scoreB] as int?,
      athleticsStandings: normalizedStandings,
    );
  }

  Json toJson() {
    return {
      AthleticGameKeys.gameId: gameId,
      AthleticGameKeys.modalityId: modalityId,
      AthleticGameKeys.startAt: startAt.toIso8601String(),
      AthleticGameKeys.status: status,
      AthleticGameKeys.series: series,
      AthleticGameKeys.modalityPhase: modalityPhase,
      AthleticGameKeys.venueName: venueName,
      AthleticGameKeys.teamAId: teamAId,
      AthleticGameKeys.teamALogo: teamALogo,
      AthleticGameKeys.teamBId: teamBId,
      AthleticGameKeys.teamBLogo: teamBLogo,
      AthleticGameKeys.scoreA: scoreA,
      AthleticGameKeys.scoreB: scoreB,
      AthleticGameKeys.athleticsStandings: athleticsStandings,
    };
  }

  // ===== Helpers / Getters =====

  bool get isTwoTeamGame => teamAId != null && teamBId != null;

  bool get isMultiTeamGame =>
      athleticsStandings != null &&
      athleticsStandings![AthleticGameKeys.athleticsData] != null;

  List<String> get multiTeamLogos {
    if (!isMultiTeamGame) return const [];
    final list = athleticsStandings![AthleticGameKeys.athleticsData] as List?;
    if (list == null) return const [];
    return list
        .whereType<Map>()
        .map((m) => m[AthleticGameKeys.logoUrl] as String?)
        .where((s) => s != null && s.isNotEmpty)
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

  String get startTimeDateFormatted =>
      DateFormat('HH:mm - EEE, dd MMM', 'pt_BR').format(startAt);

  /// Ícone sugerido para a modalidade (conveniência p/ UI)
  String get gameIcon => AppIcons.getGameIcon(modalityPhase);

  // Asset paths locais (se usar imagens empacotadas)
  String? get teamAAssetPath => teamALogo != null ? 'images/$teamALogo' : null;
  String? get teamBAssetPath => teamBLogo != null ? 'images/$teamBLogo' : null;

  AthleticGame copyWith({
    String? gameId,
    DateTime? startAt,
    String? status,
    String? modalityPhase,
    String? venueName,
    String? modalityId,
    String? series,
    String? teamAId,
    String? teamALogo,
    String? teamBId,
    String? teamBLogo,
    int? scoreA,
    int? scoreB,
    Map<String, dynamic>? athleticsStandings,
  }) {
    return AthleticGame(
      gameId: gameId ?? this.gameId,
      startAt: startAt ?? this.startAt,
      status: status ?? this.status,
      modalityPhase: modalityPhase ?? this.modalityPhase,
      venueName: venueName ?? this.venueName,
      modalityId: modalityId ?? this.modalityId,
      series: series ?? this.series,
      teamAId: teamAId ?? this.teamAId,
      teamALogo: teamALogo ?? this.teamALogo,
      teamBId: teamBId ?? this.teamBId,
      teamBLogo: teamBLogo ?? this.teamBLogo,
      scoreA: scoreA ?? this.scoreA,
      scoreB: scoreB ?? this.scoreB,
      athleticsStandings: athleticsStandings ?? this.athleticsStandings,
    );
  }
}
