// lib/core/data/repositories/athletes_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class AthletesRepository {
  final SupabaseClient _client;

  AthletesRepository(this._client);

  /// Get all athletes with athletic info
  Future<List<Map<String, dynamic>>> getAllAthletes() async {
    try {
      final response = await _client
          .from('athletes')
          .select('''
            *,
            athletics:athletic_id (
              id,
              name,
              nickname,
              series
            )
          ''')
          .order('full_name');

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Erro ao carregar atletas: $e');
    }
  }

  /// Get athletes by athletic
  Future<List<Map<String, dynamic>>> getAthletesByAthletic(String athleticId) async {
    try {
      final response = await _client
          .from('athletes')
          .select()
          .eq('athletic_id', athleticId)
          .order('full_name');

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Erro ao carregar atletas: $e');
    }
  }

  /// Create new athlete
  Future<void> createAthlete({
    required String athleticId,
    required String fullName,
    String? rga,
    String? course,
    DateTime? birthdate,
  }) async {
    try {
      await _client.from('athletes').insert({
        'athletic_id': athleticId,
        'full_name': fullName,
        'rga': rga,
        'course': course,
        'birthdate': birthdate?.toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erro ao criar atleta: $e');
    }
  }

  /// Update athlete
  Future<void> updateAthlete({
    required String id,
    required String athleticId,
    required String fullName,
    String? rga,
    String? course,
    DateTime? birthdate,
  }) async {
    try {
      await _client.from('athletes').update({
        'athletic_id': athleticId,
        'full_name': fullName,
        'rga': rga,
        'course': course,
        'birthdate': birthdate?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      throw Exception('Erro ao atualizar atleta: $e');
    }
  }

  /// Delete athlete
  Future<void> deleteAthlete(String id) async {
    try {
      await _client.from('athletes').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao excluir atleta: $e');
    }
  }
}
