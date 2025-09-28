// lib/core/data/services/athletics_service.dart

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:interufmt/core/data/atletica_model.dart';
import 'package:interufmt/core/data/mocks/athletics_mock.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AthleticsService {
  final SupabaseClient client;
  final bool useMock = false;

  AthleticsService(this.client);

  Future<List<Atletica>> getAthleticsStandings(String series) async {
    if (useMock && kDebugMode) {
      log('Using athletics mock data');
      await Future.delayed(const Duration(seconds: 1));
      return getMockDataForSeries(series);
    }

    final response = await client.rpc(
      'get_athletics_standings',
      params: {'series_filter': series},
    );

    if (response == null) {
      return [];
    }

    return convertToAtleticaList(response as List);
  }
}
