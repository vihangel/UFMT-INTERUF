// lib/core/data/repositories/modalities_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/modality_with_status_model.dart';

class ModalitiesRepository {
  final SupabaseClient _client;

  ModalitiesRepository(this._client);

  /// Get modalities with game status for a specific series
  /// Query: select m.id, m.name, m.gender, m.icon, g.series, g.status from modalities m
  /// left join games g on m.id = g.modality_id where series = 'A'
  /// group by m.id, m.name, m.gender, m.icon, g.series, g.status
  Future<List<ModalityAggregated>> getModalitiesBySeries(String series) async {
    try {
      // Note: Supabase doesn't directly support the exact SQL query with GROUP BY
      // We'll need to use a simpler approach and do the aggregation in Dart
      final response = await _client
          .from('modalities')
          .select('''
            id, name, gender, icon,
            games!inner(series, status)
          ''')
          .eq('games.series', series);

      if (response.isEmpty) {
        return [];
      }

      // Process the response to group by modality and aggregate statuses
      final Map<String, List<ModalityWithStatus>> modalityGroups = {};

      for (final item in response) {
        final games = item['games'] as List<dynamic>;

        for (final game in games) {
          final modalityWithStatus = ModalityWithStatus(
            id: item['id'] as String,
            name: item['name'] as String,
            gender: item['gender'] as String,
            icon: item['icon'] as String?,
            series: game['series'] as String,
            status: game['status'] as String,
          );

          final modalityId = modalityWithStatus.id;
          if (!modalityGroups.containsKey(modalityId)) {
            modalityGroups[modalityId] = [];
          }
          modalityGroups[modalityId]!.add(modalityWithStatus);
        }
      }

      // Convert to aggregated modalities
      return modalityGroups.values
          .map(
            (modalityList) =>
                ModalityAggregated.fromModalityWithStatusList(modalityList),
          )
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      throw Exception('Erro ao carregar modalidades da série $series: $e');
    }
  }

  /// Get modalities for both series A and B
  Future<Map<String, List<ModalityAggregated>>>
  getAllModalitiesBySeries() async {
    try {
      final futures = await Future.wait([
        getModalitiesBySeries('A'),
        getModalitiesBySeries('B'),
      ]);

      return {'A': futures[0], 'B': futures[1]};
    } catch (e) {
      throw Exception('Erro ao carregar todas as modalidades: $e');
    }
  }

  /// Group modalities by gender
  Map<String, List<ModalityAggregated>> groupModalitiesByGender(
    List<ModalityAggregated> modalities,
  ) {
    final Map<String, List<ModalityAggregated>> groupedModalities = {
      'Masculino': [],
      'Feminino': [],
      'Misto': [],
    };

    for (final modality in modalities) {
      final gender = modality.gender;
      if (groupedModalities.containsKey(gender)) {
        groupedModalities[gender]!.add(modality);
      }
    }

    // Sort each gender group by name
    groupedModalities.forEach((key, value) {
      value.sort((a, b) => a.name.compareTo(b.name));
    });

    return groupedModalities;
  }

  // Admin CRUD methods
  Future<List<Map<String, dynamic>>> getAllModalities() async {
    final response = await _client
        .from('modalities')
        .select()
        .order('name', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createModality({
    required String name,
    required String gender,
    String? icon,
  }) async {
    final response = await _client
        .from('modalities')
        .insert({'name': name, 'gender': gender, 'icon': icon})
        .select()
        .single();

    return response;
  }

  Future<Map<String, dynamic>> updateModality({
    required String id,
    required String name,
    required String gender,
    String? icon,
  }) async {
    final response = await _client
        .from('modalities')
        .update({'name': name, 'gender': gender, 'icon': icon})
        .eq('id', id)
        .select()
        .single();

    return response;
  }

  Future<void> deleteModality(String id) async {
    await _client.from('modalities').delete().eq('id', id);
  }
}
