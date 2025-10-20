// lib/core/data/repositories/athletics_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../athletics_item_model.dart';

class AthleticsRepository {
  final SupabaseClient _client;

  AthleticsRepository(this._client);

  /// Get athletics by series with the specific query format
  /// select (id, name, nickname, logo_url) from athletics where series = 'A'
  Future<List<AthleticsItem>> getAthleticsBySeries(String series) async {
    try {
      final response = await _client
          .from('athletics')
          .select('id, name, nickname, logo_url')
          .eq('series', series)
          .order('nickname');

      if (response.isEmpty) {
        return [];
      }

      return (response as List<dynamic>)
          .map((item) => AthleticsItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar atléticas da série $series: $e');
    }
  }

  /// Get all athletics for both series
  Future<Map<String, List<AthleticsItem>>> getAllAthletics() async {
    try {
      final futures = await Future.wait([
        getAthleticsBySeries('A'),
        getAthleticsBySeries('B'),
      ]);

      return {'A': futures[0], 'B': futures[1]};
    } catch (e) {
      throw Exception('Erro ao carregar todas as atléticas: $e');
    }
  }

  /// CRUD methods for admin panel

  /// Get all athletics (raw data for CRUD)
  Future<List<Map<String, dynamic>>> getAllAthleticsForCrud() async {
    try {
      final response = await _client.from('athletics').select().order('name');

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Erro ao carregar atléticas: $e');
    }
  }

  /// Create new athletic
  Future<void> createAthletic({
    required String name,
    String? nickname,
    required String series,
    String? logoUrl,
    String? description,
    String? instagram,
    String? twitter,
    String? youtube,
  }) async {
    try {
      await _client.from('athletics').insert({
        'name': name,
        'nickname': nickname,
        'series': series,
        'logo_url': logoUrl,
        'description': description,
        'instagram': instagram,
        'twitter': twitter,
        'youtube': youtube,
      });
    } catch (e) {
      throw Exception('Erro ao criar atlética: $e');
    }
  }

  /// Update athletic
  Future<void> updateAthletic({
    required String id,
    required String name,
    String? nickname,
    required String series,
    String? logoUrl,
    String? description,
    String? instagram,
    String? twitter,
    String? youtube,
  }) async {
    try {
      await _client
          .from('athletics')
          .update({
            'name': name,
            'nickname': nickname,
            'series': series,
            'logo_url': logoUrl,
            'description': description,
            'instagram': instagram,
            'twitter': twitter,
            'youtube': youtube,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      throw Exception('Erro ao atualizar atlética: $e');
    }
  }

  /// Delete athletic
  Future<void> deleteAthletic(String id) async {
    try {
      await _client.from('athletics').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao excluir atlética: $e');
    }
  }
}
