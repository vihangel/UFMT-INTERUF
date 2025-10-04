import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/athlete_detail_model.dart';

class AthleteDetailRepository {
  final SupabaseClient _supabaseClient;

  AthleteDetailRepository(this._supabaseClient);

  Future<AthleteDetail?> getAthleteDetail(
    String athleteId,
    String gameId,
  ) async {
    try {
      final response = await _supabaseClient.rpc(
        'execute_raw_sql',
        params: {
          'query':
              '''
            SELECT
              a.full_name,
              a.course,
              EXTRACT(YEAR FROM AGE(a.birthdate)) AS age,
              ag.shirt_number,
              g.series,
              m.name,
              m.gender,
              (
                SELECT
                  jsonb_agg(jsonb_build_object(
                    'code', statdef.code,
                    'name', statdef.name,
                    'value', stats.value,
                    'order', statdef.sort_order
                  ))
                FROM
                  public.athlete_game_stats AS stats
                JOIN
                  public.stat_definitions AS statdef ON stats.stat_code = statdef.code
                WHERE
                  stats.athlete_id = a.id AND stats.game_id = g.id
              ) AS statistics
            FROM
              public.athletes AS a
            JOIN
              public.athlete_game AS ag ON a.id = ag.athlete_id
            JOIN
              public.games AS g ON ag.game_id = g.id
            JOIN
              public.modalities as m on g.modality_id = m.id
            WHERE
              a.id = '$athleteId' AND g.id = '$gameId'
          ''',
        },
      );

      if (response != null && response is List && response.isNotEmpty) {
        return AthleteDetail.fromJson(response[0] as Map<String, dynamic>);
      }

      return null;
    } catch (error) {
      throw Exception('Erro ao buscar detalhes do atleta: $error');
    }
  }
}
