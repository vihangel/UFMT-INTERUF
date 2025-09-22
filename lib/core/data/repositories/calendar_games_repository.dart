import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/calendar_game_model.dart';

class CalendarGamesRepository {
  final SupabaseClient _client;

  CalendarGamesRepository(this._client);

  Future<List<CalendarGame>> getGamesBySeriesAndDate({
    required String series,
    required DateTime date,
  }) async {
    final dateString = date.toIso8601String().split(
      'T',
    )[0]; // Format: YYYY-MM-DD

    final query =
        '''
      SELECT
        g.id AS game_id,
        g.start_at,
        g.status,
        g.series,
        -- Update athletics_standings to include logo URLs
        CASE 
          WHEN g.athletics_standings IS NOT NULL THEN
            jsonb_build_object(
              'athletics_data', (
                SELECT jsonb_agg(
                  jsonb_build_object(
                    'logo_url', a.logo_url
                  )
                )
                FROM athletics a
                WHERE a.id = ANY(
                  ARRAY(
                    SELECT jsonb_array_elements_text(g.athletics_standings->'id_atletics')
                  )::uuid[]
                )
              )
            )
          ELSE NULL
        END AS athletics_standings,
        CONCAT(
          m.name, ' ', m.gender,
          CASE
            WHEN bracket_info.position = 1 THEN ' - Final'
            WHEN bracket_info.position BETWEEN 2 AND 3 THEN ' - Semifinal'
            WHEN bracket_info.position BETWEEN 4 AND 7 THEN ' - Quartas'
            WHEN bracket_info.position BETWEEN 8 AND 15 THEN ' - Oitavas'
            ELSE ''
          END
        ) AS modality_phase,
        v.name AS venue_name,
        ta.id AS team_a_id,
        ta.logo_url AS team_a_logo,
        tb.id AS team_b_id,
        tb.logo_url AS team_b_logo,
        g.score_a,
        g.score_b
      FROM games g
      JOIN modalities m ON g.modality_id = m.id
      LEFT JOIN venues v ON g.venue_id = v.id
      LEFT JOIN athletics ta ON g.a_athletic_id = ta.id
      LEFT JOIN athletics tb ON g.b_athletic_id = tb.id
      LEFT JOIN (
        SELECT
          t.game_id, t.position
        FROM
          brackets, unnest(brackets.heap_brackeat) WITH ordinality AS t(game_id, position)
      ) AS bracket_info ON g.id = bracket_info.game_id::uuid
      WHERE (
        (g.athletics_standings -> 'id_atletics' is not null AND g.series = '$series' AND g.start_at::date = '$dateString'::date)
        OR 
        (g.start_at::date = '$dateString'::date AND g.series = '$series' AND (g.a_athletic_id IS NOT NULL OR g.b_athletic_id IS NOT NULL))
      )
      ORDER BY g.start_at ASC
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

        return CalendarGame.fromJson(gameMap);
      }).toList();
    } catch (error) {
      // ignore: avoid_print
      print(error);
      throw Exception('Failed to fetch calendar games: $error');
    }
  }

  Future<Map<String, List<CalendarGame>>> getGamesBySeriesGroupedByDay({
    required String series,
    required List<DateTime> dates,
  }) async {
    final Map<String, List<CalendarGame>> groupedGames = {};

    for (int i = 0; i < dates.length; i++) {
      final dayLabel = 'Dia ${i + 1}';
      final games = await getGamesBySeriesAndDate(
        series: series,
        date: dates[i],
      );
      groupedGames[dayLabel] = games;
    }

    return groupedGames;
  }
}
