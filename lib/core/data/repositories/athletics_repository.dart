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
}
