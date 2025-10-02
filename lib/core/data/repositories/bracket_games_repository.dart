// lib/core/data/repositories/bracket_games_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bracket_game_model.dart';

class BracketGamesRepository {
  final SupabaseClient _client;

  BracketGamesRepository(this._client);

  /// Get bracket games for a specific modality, series, and phase
  Future<List<BracketGame>> getBracketGamesByModalitySeriesAndPhase({
    required String modalityId,
    required String series,
    required String phase,
  }) async {
    // Map phase names to position ranges
    Map<String, String> phaseConditions = {
      'Final': 'bracket_info.position = 1',
      'Semis': 'bracket_info.position BETWEEN 2 AND 3',
      'Quartas': 'bracket_info.position BETWEEN 4 AND 7',
      'Oitavas': 'bracket_info.position BETWEEN 8 AND 15',
    };

    final String phaseCondition =
        phaseConditions[phase] ?? 'bracket_info.position BETWEEN 1 AND 15';

    final query =
        '''
      SELECT
        games.id AS game_id,
        games.status,
        games.series,
        games.start_at,
        CONCAT(
          modalities.name, ' ', modalities.gender) AS modality,
        CASE
          WHEN bracket_info.position = 1 THEN 'Final'
          WHEN bracket_info.position BETWEEN 2 AND 3 THEN 'Semifinal'
          WHEN bracket_info.position BETWEEN 4 AND 7 THEN 'Quartas'
          WHEN bracket_info.position BETWEEN 8 AND 15 THEN 'Oitavas'
          ELSE ''
        END AS phase,
        venues.name AS venue_name,
        team_a.id AS team_a_id,
        team_a.name AS team_a_name,
        team_a.logo_url AS team_a_logo,
        team_b.id AS team_b_id,
        team_b.name AS team_b_name,
        team_b.logo_url AS team_b_logo,
        games.score_a,
        games.score_b
      FROM
        games
      JOIN
        modalities ON games.modality_id = modalities.id
      LEFT JOIN
        venues ON games.venue_id = venues.id
      LEFT JOIN
        athletics AS team_a ON games.a_athletic_id = team_a.id
      LEFT JOIN
        athletics AS team_b ON games.b_athletic_id = team_b.id
      LEFT JOIN (
        SELECT
          t.game_id, t.position
        FROM
          brackets, unnest(brackets.heap_brackeat) WITH ordinality AS t(game_id, position)
      ) AS bracket_info ON games.id = bracket_info.game_id::uuid
      WHERE
        modalities.id = '$modalityId' 
        AND games.series = '$series'
        AND $phaseCondition
      ORDER BY games.start_at ASC
    ''';

    try {
      final response = await _client.rpc(
        'execute_raw_sql',
        params: {'query': query},
      );

      if (response == null) return [];

      final List<dynamic> gamesList = response as List<dynamic>;

      return gamesList.map((gameData) {
        final Map<String, dynamic> gameMap = Map<String, dynamic>.from(
          gameData,
        );

        // Convert start_at to DateTime if it's a string
        if (gameMap['start_at'] is String) {
          gameMap['start_at'] = DateTime.parse(gameMap['start_at']);
        }

        return BracketGame.fromJson(gameMap);
      }).toList();
    } catch (error) {
      throw Exception('Failed to fetch bracket games: $error');
    }
  }

  /// Get all bracket games for a specific modality and series
  Future<Map<String, List<BracketGame>>> getAllBracketGamesByModalityAndSeries({
    required String modalityId,
    required String series,
  }) async {
    final Map<String, List<BracketGame>> groupedGames = {};
    final phases = ['Oitavas', 'Quartas', 'Semis', 'Final'];

    for (String phase in phases) {
      final games = await getBracketGamesByModalitySeriesAndPhase(
        modalityId: modalityId,
        series: series,
        phase: phase,
      );
      groupedGames[phase] = games;
    }

    return groupedGames;
  }

  /// Get bracket games for both series A and B
  Future<Map<String, Map<String, List<BracketGame>>>>
  getAllBracketGamesByModality({required String modalityId}) async {
    try {
      final futures = await Future.wait([
        getAllBracketGamesByModalityAndSeries(
          modalityId: modalityId,
          series: 'A',
        ),
        getAllBracketGamesByModalityAndSeries(
          modalityId: modalityId,
          series: 'B',
        ),
      ]);

      return {'A': futures[0], 'B': futures[1]};
    } catch (e) {
      throw Exception('Erro ao carregar jogos da modalidade: $e');
    }
  }
}
