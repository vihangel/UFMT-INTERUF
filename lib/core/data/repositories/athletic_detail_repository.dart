// lib/core/data/repositories/athletic_detail_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/athletic_detail_model.dart';
import '../models/athletic_game_model.dart';
import '../models/modality_with_status_model.dart';

class AthleticDetailRepository {
  final SupabaseClient _client;

  AthleticDetailRepository(this._client);

  /// Get athletic detail by ID
  Future<AthleticDetail?> getAthleticDetail(String athleticId) async {
    try {
      final response = await _client
          .from('athletics')
          .select('id, name, nickname, logo_url, series, description')
          .eq('id', athleticId)
          .single();

      return AthleticDetail.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao carregar detalhes da atlética: $e');
    }
  }

  /// Get athletic games for a specific date
  Future<List<AthleticGame>> getAthleticGames(
    String athleticId,
    String date,
  ) async {
    try {
      // Try using the custom RPC function first
      final response = await _client.rpc(
        'get_athletic_games',
        params: {'athletic_id_param': athleticId, 'date_param': date},
      );

      if (response != null) {
        return (response as List<dynamic>)
            .map((item) => AthleticGame.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // If RPC function doesn't exist, fallback to direct query
      // print('RPC function not available, using fallback query: $e');
    }

    // Fallback: use direct table query with raw SQL for better control
    try {
      final query =
          '''
        SELECT
          g.id AS game_id,
          g.start_at,
          g.status,
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
          g.a_athletic_id = '$athleticId'::uuid
          OR g.b_athletic_id = '$athleticId'::uuid
          OR (
            g.athletics_standings IS NOT NULL 
            AND g.athletics_standings->'id_atletics' ? '$athleticId'::text
          )
        )
        AND g.start_at::date = '$date'::date
        ORDER BY g.start_at ASC
      ''';

      final response = await _client.rpc(
        'execute_raw_sql',
        params: {'query': query},
      );

      if (response == null) return [];

      final List<dynamic> gamesList = response as List<dynamic>;

      return gamesList.map<AthleticGame>((gameData) {
        final Map<String, dynamic> gameMap = Map<String, dynamic>.from(
          gameData,
        );

        // Convert start_at to DateTime if it's a string
        if (gameMap['start_at'] is String) {
          gameMap['start_at'] = DateTime.parse(gameMap['start_at'] as String);
        }

        return AthleticGame.fromJson(gameMap);
      }).toList();
    } catch (e) {
      throw Exception('Erro ao carregar jogos da atlética: $e');
    }
  }

  /// Get modalities that the athletic participates in
  Future<List<ModalityAggregated>> getAthleticModalities(
    String athleticId,
  ) async {
    try {
      // Use raw SQL query to get modalities including athletics_standings
      // is_unique_game = true when a_athletic_id is null AND athletics_standings is not null
      final query =
          '''
        SELECT DISTINCT
          m.id AS modality_id,
          m.name AS modality_name,
          m.gender AS modality_gender,
          m.icon AS modality_icon,
          g.series AS series,
          array_agg(DISTINCT g.status) AS statuses,
          bool_or(g.a_athletic_id IS NULL AND g.athletics_standings IS NOT NULL) AS is_unique_game
        FROM games g
        JOIN modalities m ON g.modality_id = m.id
        WHERE (
          g.a_athletic_id = '$athleticId'::uuid
          OR g.b_athletic_id = '$athleticId'::uuid
          OR (
            g.athletics_standings IS NOT NULL 
            AND g.athletics_standings->'id_atletics' ? '$athleticId'::text
          )
        )
        GROUP BY m.id, m.name, m.gender, m.icon, g.series
        ORDER BY m.name ASC
      ''';

      final response = await _client.rpc(
        'execute_raw_sql',
        params: {'query': query},
      );

      if (response == null) return [];

      final List<dynamic> modalitiesList = response as List<dynamic>;

      return modalitiesList.map<ModalityAggregated>((modalityData) {
        final Map<String, dynamic> modalityMap = Map<String, dynamic>.from(
          modalityData,
        );

        // Extract statuses array
        final List<String> statuses = (modalityMap['statuses'] as List<dynamic>)
            .map((status) => status.toString())
            .toList();

        // Get is_unique_game from the query result
        final isUniqueGame = modalityMap['is_unique_game'] as bool? ?? false;

        return ModalityAggregated(
          id: modalityMap['modality_id'] as String,
          name: modalityMap['modality_name'] as String,
          gender: modalityMap['modality_gender'] as String,
          icon: modalityMap['modality_icon'] as String?,
          series: modalityMap['series'] as String? ?? '',
          isUniqueGame: isUniqueGame,
          gameStatuses: statuses,
          modalityStatus: ModalityWithStatus.getModalityStatus(statuses),
        );
      }).toList();
    } catch (e) {
      throw Exception('Erro ao carregar modalidades da atlética: $e');
    }
  }

  /// Get available dates for the series
  List<String> getSeriesDates(String series) {
    if (series == 'A') {
      return ['2025-10-31', '2025-11-01', '2025-11-02'];
    } else {
      return ['2025-11-14', '2025-11-15', '2025-11-16'];
    }
  }
}
