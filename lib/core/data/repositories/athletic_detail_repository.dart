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

    // Fallback: use direct table query with joins
    try {
      final response = await _client
          .from('games')
          .select('''
            id,
            start_at,
            status,
            score_a,
            score_b,
            modalities!inner(name, gender),
            venues(name),
            a_athletics:athletics!a_athletic_id(id, logo_url),
            b_athletics:athletics!b_athletic_id(id, logo_url)
          ''')
          .or('a_athletic_id.eq.$athleticId,b_athletic_id.eq.$athleticId')
          .gte('start_at', '${date}T00:00:00+00:00')
          .lt('start_at', '${date}T23:59:59+00:00')
          .order('start_at');

      return response.map<AthleticGame>((game) {
        final modality = game['modalities'] as Map<String, dynamic>?;
        final venue = game['venues'] as Map<String, dynamic>?;
        final teamA = game['a_athletics'] as Map<String, dynamic>?;
        final teamB = game['b_athletics'] as Map<String, dynamic>?;

        return AthleticGame(
          gameId: game['id'] as String,
          startAt: DateTime.parse(game['start_at'] as String),
          status: game['status'] as String,
          modalityPhase: modality != null
              ? '${modality['name']} ${modality['gender']}'
              : 'Modalidade',
          venueName: venue?['name'] as String?,
          teamAId: teamA?['id'] as String?,
          teamALogo: teamA?['logo_url'] as String?,
          teamBId: teamB?['id'] as String?,
          teamBLogo: teamB?['logo_url'] as String?,
          scoreA: game['score_a'] as int?,
          scoreB: game['score_b'] as int?,
        );
      }).toList();
    } catch (e) {
      throw Exception('Erro ao carregar jogos da atlética: $e');
    }
  }

  /// Get modalities that the athletic participates in
  Future<List<ModalityWithStatus>> getAthleticModalities(
    String athleticId,
  ) async {
    try {
      // Get all modalities where this athletic has games
      final response = await _client
          .from('games')
          .select('''
            modalities!inner(id, name, gender, icon),
            status
          ''')
          .or('a_athletic_id.eq.$athleticId,b_athletic_id.eq.$athleticId');

      // Group by modality and determine status
      final modalityMap = <String, Map<String, dynamic>>{};

      for (final game in response) {
        final modality = game['modalities'] as Map<String, dynamic>;
        final modalityId = modality['id'] as String;

        if (!modalityMap.containsKey(modalityId)) {
          modalityMap[modalityId] = {
            'modality': modality,
            'statuses': <String>[],
          };
        }

        (modalityMap[modalityId]!['statuses'] as List<String>).add(
          game['status'] as String,
        );
      }

      return modalityMap.values.map((entry) {
        final modality = entry['modality'] as Map<String, dynamic>;
        final statuses = entry['statuses'] as List<String>;

        return ModalityWithStatus(
          id: modality['id'] as String,
          name: modality['name'] as String,
          gender: modality['gender'] as String,
          icon: modality['icon'] as String?,
          series: '', // Will be filled from athletic detail
          status: ModalityWithStatus.getModalityStatus(statuses),
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
