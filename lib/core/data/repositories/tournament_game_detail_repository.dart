import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tournament_game_detail_model.dart';

class TournamentGameDetailRepository {
  final SupabaseClient _client;

  TournamentGameDetailRepository(this._client);

  /// Get tournament game detail by game ID
  Future<TournamentGameDetail?> getTournamentGameDetail(String gameId) async {
    try {
      final query =
          '''
        SELECT
          games.id AS game_id,
          games.status,
          games.start_at,
          CONCAT(
            modalities.name, ' ', modalities.gender) AS modality,
          CASE
            WHEN bracket_info.position = 1 THEN 'Final'
            WHEN bracket_info.position BETWEEN 2 AND 3 THEN 'Semifinal'
            WHEN bracket_info.position BETWEEN 4 AND 7 THEN 'Quartas de final'
            WHEN bracket_info.position BETWEEN 8 AND 15 THEN 'Oitavas de final'
            ELSE ''
          END
          AS phase,
          venues.name AS venue_name,
          team_a.id AS team_a_id,
          team_a.nickname AS team_a_name,
          team_a.logo_url AS team_a_logo,
          team_b.id AS team_b_id,
          team_b.nickname AS team_b_name,
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
          games.id = '$gameId'
      ''';

      final response = await _client.rpc(
        'execute_raw_sql',
        params: {'query': query},
      );

      if (response == null || response.isEmpty) {
        return null;
      }

      final gameData = response.first;
      return TournamentGameDetail.fromJson(Map<String, dynamic>.from(gameData));
    } catch (e) {
      throw Exception('Erro ao carregar detalhes do jogo: $e');
    }
  }

  /// Get game statistics by game ID
  Future<List<GameStatistic>> getGameStatistics(String gameId) async {
    try {
      // First query: Get stats from athlete_game_stats (aggregated by team)
      final athleteStatsQuery =
          '''
        SELECT
          stat_definitions.name,
          stat_definitions.code,
          SUM(CASE WHEN athletes.athletic_id = games.a_athletic_id THEN athlete_game_stats.value ELSE 0 END)::integer AS team_a_value,
          SUM(CASE WHEN athletes.athletic_id = games.b_athletic_id THEN athlete_game_stats.value ELSE 0 END)::integer AS team_b_value,
          stat_definitions.sort_order
        FROM
          athlete_game_stats
        JOIN
          athletes ON athlete_game_stats.athlete_id = athletes.id
        JOIN
          games ON athlete_game_stats.game_id = games.id
        JOIN
          stat_definitions ON athlete_game_stats.stat_code = stat_definitions.code
        WHERE
          athlete_game_stats.game_id = '$gameId'
        GROUP BY
          stat_definitions.code, stat_definitions.name, stat_definitions.sort_order
        ORDER BY
          stat_definitions.sort_order
      ''';

      final athleteStatsResponse = await _client.rpc(
        'execute_raw_sql',
        params: {'query': athleteStatsQuery},
      );

      final List<GameStatistic> allStats = [];
      final Set<String> existingStatCodes = {};

      // Process athlete stats
      if (athleteStatsResponse != null) {
        final List<dynamic> athleteStatsList =
            athleteStatsResponse as List<dynamic>;
        for (var statData in athleteStatsList) {
          final stat = GameStatistic.fromJson(
            Map<String, dynamic>.from(statData),
          );
          allStats.add(stat);
          existingStatCodes.add(stat.code);
        }
      }

      // Second query: Get stats from game_stats (team-level stats)
      final gameStatsQuery =
          '''
        SELECT
          stat_definitions.name,
          stat_definitions.code,
          game_stats.valuea AS team_a_value,
          game_stats.valueb AS team_b_value,
          stat_definitions.sort_order
        FROM
          game_stats
        JOIN
          stat_definitions ON game_stats.stat_code = stat_definitions.code
        WHERE
          game_stats.game_id = '$gameId'
        ORDER BY
          stat_definitions.sort_order
      ''';

      final gameStatsResponse = await _client.rpc(
        'execute_raw_sql',
        params: {'query': gameStatsQuery},
      );

      // Process game stats and add only those not already present
      if (gameStatsResponse != null) {
        final List<dynamic> gameStatsList = gameStatsResponse as List<dynamic>;
        for (var statData in gameStatsList) {
          final stat = GameStatistic.fromJson(
            Map<String, dynamic>.from(statData),
          );
          // Only add if this stat code is not already in the list
          if (!existingStatCodes.contains(stat.code)) {
            allStats.add(stat);
          }
        }
      }

      // Sort all stats by sort_order if available
      allStats.sort((a, b) {
        if (a.sortOrder != null && b.sortOrder != null) {
          return a.sortOrder!.compareTo(b.sortOrder!);
        }
        return 0; // Keep original order if sort_order is not available
      });

      return allStats;
    } catch (e) {
      // Return empty list if error occurs
      return [];
    }
  }

  /// Get athletes for a specific game
  Future<Map<String, List<GameAthlete>>> getGameAthletes(String gameId) async {
    try {
      final query =
          '''
        SELECT
            athletes.id AS athlete_id,
            athletes.full_name,
            athlete_game.shirt_number,
            athletes.athletic_id
        FROM
            athlete_game
        JOIN
            athletes ON athlete_game.athlete_id = athletes.id
        WHERE
            athlete_game.game_id = '$gameId'
        ORDER BY
            athletes.athletic_id, athlete_game.shirt_number
      ''';

      final response = await _client.rpc(
        'execute_raw_sql',
        params: {'query': query},
      );
      final idTeamA = await _client
          .from('games')
          .select('a_athletic_id')
          .eq('id', gameId)
          .single()
          .then((value) => value['a_athletic_id'] as String);
      if (response == null) return {'teamA': [], 'teamB': []};

      final List<dynamic> athletesList = response as List<dynamic>;

      final athletes = athletesList.map((athleteData) {
        return GameAthlete.fromJson(Map<String, dynamic>.from(athleteData));
      }).toList();

      // Group athletes by team
      final Map<String, List<GameAthlete>> groupedAthletes = {
        'teamA': [],
        'teamB': [],
      };

      // Get the first athletic ID to determine which is team A
      if (athletes.isNotEmpty) {
        
        for (final athlete in athletes) {
          if (athlete.athleticId == idTeamA) {
            groupedAthletes['teamA']!.add(athlete);
          } else {
            groupedAthletes['teamB']!.add(athlete);
          }
        }
      }

      return groupedAthletes;
    } catch (e) {
      // Return empty lists if error occurs
      return {'teamA': [], 'teamB': []};
    }
  }
}
