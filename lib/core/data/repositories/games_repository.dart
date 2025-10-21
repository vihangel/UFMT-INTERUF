// lib/core/data/repositories/games_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class GamesRepository {
  final SupabaseClient _client;

  GamesRepository(this._client);

  /// Get all games with related data
  Future<List<Map<String, dynamic>>> getAllGames() async {
    try {
      final response = await _client
          .from('games')
          .select('''
            id,
            modality_id,
            series,
            start_at,
            venue_id,
            a_athletic_id,
            b_athletic_id,
            score_a,
            score_b,
            partials,
            athletics_standings,
            winner_athletic_id,
            status,
            created_at,
            updated_at,
            modalities:modality_id (
              id,
              name,
              gender,
              icon
            ),
            venues:venue_id (
              id,
              name
            ),
            a_athletic:a_athletic_id (
              id,
              name,
              nickname,
              logo_url
            ),
            b_athletic:b_athletic_id (
              id,
              name,
              nickname,
              logo_url
            ),
            winner_athletic:winner_athletic_id (
              id,
              name,
              nickname
            )
          ''')
          .order('start_at', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Erro ao carregar jogos: $e');
    }
  }

  /// Get game by ID with all details
  Future<Map<String, dynamic>?> getGameById(String id) async {
    try {
      final response = await _client
          .from('games')
          .select('''
            id,
            modality_id,
            series,
            start_at,
            venue_id,
            a_athletic_id,
            b_athletic_id,
            score_a,
            score_b,
            partials,
            athletics_standings,
            winner_athletic_id,
            status,
            created_at,
            updated_at,
            modalities:modality_id (
              id,
              name,
              gender,
              icon
            ),
            venues:venue_id (
              id,
              name
            ),
            a_athletic:a_athletic_id (
              id,
              name,
              nickname,
              logo_url
            ),
            b_athletic:b_athletic_id (
              id,
              name,
              nickname,
              logo_url
            ),
            winner_athletic:winner_athletic_id (
              id,
              name,
              nickname
            )
          ''')
          .eq('id', id)
          .single();

      return response;
    } catch (e) {
      throw Exception('Erro ao carregar jogo: $e');
    }
  }

  /// Create new game
  Future<String> createGame({
    required String modalityId,
    required String series,
    required DateTime startAt,
    String? venueId,
    String? aAthleticId,
    String? bAthleticId,
    Map<String, dynamic>? athleticsStandings,
    String status = 'scheduled',
  }) async {
    try {
      final response = await _client
          .from('games')
          .insert({
            'modality_id': modalityId,
            'series': series,
            'start_at': startAt.toIso8601String(),
            'venue_id': venueId,
            'a_athletic_id': aAthleticId,
            'b_athletic_id': bAthleticId,
            'athletics_standings': athleticsStandings,
            'status': status,
            'score_a': 0,
            'score_b': 0,
          })
          .select('id')
          .single();

      return response['id'] as String;
    } catch (e) {
      throw Exception('Erro ao criar jogo: $e');
    }
  }

  /// Update game
  Future<void> updateGame({
    required String id,
    String? modalityId,
    String? series,
    DateTime? startAt,
    String? venueId,
    String? aAthleticId,
    String? bAthleticId,
    int? scoreA,
    int? scoreB,
    Map<String, dynamic>? athleticsStandings,
    Map<String, dynamic>? partials,
    String? winnerAthleticId,
    String? status,
    bool clearAthleticIds = false,
    bool clearAthleticsStandings = false,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (modalityId != null) updateData['modality_id'] = modalityId;
      if (series != null) updateData['series'] = series;
      if (startAt != null) updateData['start_at'] = startAt.toIso8601String();
      if (venueId != null) updateData['venue_id'] = venueId;

      // Handle team IDs - allow explicit null when switching to unique game
      if (clearAthleticIds) {
        updateData['a_athletic_id'] = null;
        updateData['b_athletic_id'] = null;
      } else {
        if (aAthleticId != null) updateData['a_athletic_id'] = aAthleticId;
        if (bAthleticId != null) updateData['b_athletic_id'] = bAthleticId;
      }

      if (scoreA != null) updateData['score_a'] = scoreA;
      if (scoreB != null) updateData['score_b'] = scoreB;

      // Handle athletics_standings - allow explicit null when switching to bracket game
      if (clearAthleticsStandings) {
        updateData['athletics_standings'] = null;
      } else if (athleticsStandings != null) {
        updateData['athletics_standings'] = athleticsStandings;
      }

      if (partials != null) updateData['partials'] = partials;
      if (winnerAthleticId != null) {
        updateData['winner_athletic_id'] = winnerAthleticId;
      }
      if (status != null) updateData['status'] = status;

      await _client.from('games').update(updateData).eq('id', id);
    } catch (e) {
      throw Exception('Erro ao atualizar jogo: $e');
    }
  }

  /// Delete game
  Future<void> deleteGame(String id) async {
    try {
      // First delete related athlete_game records
      await _client.from('athlete_game').delete().eq('game_id', id);

      // Then delete game_stats
      await _client.from('game_stats').delete().eq('game_id', id);

      // Finally delete the game
      await _client.from('games').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao excluir jogo: $e');
    }
  }

  /// Get athletes in a game
  Future<List<Map<String, dynamic>>> getGameAthletes(String gameId) async {
    try {
      final response = await _client
          .from('athlete_game')
          .select('''
            *,
            athletes:athlete_id (
              id,
              full_name,
              athletic_id,
              athletics:athletic_id (
                id,
                name,
                nickname,
                logo_url
              )
            )
          ''')
          .eq('game_id', gameId)
          .order('shirt_number');

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Erro ao carregar atletas do jogo: $e');
    }
  }

  /// Add athlete to game
  Future<void> addAthleteToGame({
    required String gameId,
    required String athleteId,
    required int shirtNumber,
  }) async {
    try {
      await _client.from('athlete_game').insert({
        'game_id': gameId,
        'athlete_id': athleteId,
        'shirt_number': shirtNumber,
      });
    } catch (e) {
      throw Exception('Erro ao adicionar atleta ao jogo: $e');
    }
  }

  /// Remove athlete from game
  Future<void> removeAthleteFromGame({
    required String gameId,
    required String athleteId,
  }) async {
    try {
      await _client
          .from('athlete_game')
          .delete()
          .eq('game_id', gameId)
          .eq('athlete_id', athleteId);
    } catch (e) {
      throw Exception('Erro ao remover atleta do jogo: $e');
    }
  }

  /// Get game statistics
  Future<List<Map<String, dynamic>>> getGameStats(String gameId) async {
    try {
      final response = await _client
          .from('game_stats')
          .select('''
            *,
            stat_definitions:stat_code (
              code,
              name,
              description,
              unit
            )
          ''')
          .eq('game_id', gameId)
          .order('stat_code');

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Erro ao carregar estatísticas do jogo: $e');
    }
  }

  /// Update game stat
  Future<void> updateGameStat({
    required String gameId,
    required String statCode,
    required int value,
  }) async {
    try {
      await _client.from('game_stats').upsert({
        'game_id': gameId,
        'stat_code': statCode,
        'value': value,
      });
    } catch (e) {
      throw Exception('Erro ao atualizar estatística do jogo: $e');
    }
  }

  /// Get athlete game statistics
  Future<List<Map<String, dynamic>>> getAthleteGameStats({
    required String gameId,
    required String athleteId,
  }) async {
    try {
      final response = await _client
          .from('athlete_game_stats')
          .select('''
            *,
            stat_definitions:stat_code (
              code,
              name,
              description,
              unit
            )
          ''')
          .eq('game_id', gameId)
          .eq('athlete_id', athleteId)
          .order('stat_code');

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Erro ao carregar estatísticas do atleta: $e');
    }
  }

  /// Update athlete game stat
  Future<void> updateAthleteGameStat({
    required String gameId,
    required String athleteId,
    required String statCode,
    required int value,
  }) async {
    try {
      await _client.from('athlete_game_stats').upsert({
        'game_id': gameId,
        'athlete_id': athleteId,
        'stat_code': statCode,
        'value': value,
      });
    } catch (e) {
      throw Exception('Erro ao atualizar estatística do atleta: $e');
    }
  }

  /// Get all stat definitions
  Future<List<Map<String, dynamic>>> getStatDefinitions() async {
    try {
      final response = await _client
          .from('stat_definitions')
          .select()
          .order('sort_order');

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Erro ao carregar definições de estatísticas: $e');
    }
  }

  /// Get athletics for standings (for unique games)
  Future<List<Map<String, dynamic>>> getAthleticsForStandings(
    List<String> athleticIds,
  ) async {
    try {
      final response = await _client
          .from('athletics')
          .select('id, name, nickname, logo_url')
          .inFilter('id', athleticIds)
          .order('name');

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Erro ao carregar atléticas: $e');
    }
  }
}
