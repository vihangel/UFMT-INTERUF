// lib/core/data/repositories/venues_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/venues_model.dart';

class VenuesRepository {
  final SupabaseClient _client;

  VenuesRepository(this._client);

  /// Get all venues with the specific query format
  /// select id, name, address, lat, lng from venues
  Future<List<Venue>> getAllVenues() async {
    try {
      final response = await _client
          .from('venues')
          .select('id, name, address, lat, lng, created_at, updated_at')
          .order('name');

      if (response.isEmpty) {
        return [];
      }

      return (response as List<dynamic>)
          .map((item) => Venue.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar locais: $e');
    }
  }

  /// Get venues with coordinates (lat and lng not null)
  Future<List<Venue>> getVenuesWithCoordinates() async {
    try {
      final response = await _client
          .from('venues')
          .select('id, name, address, lat, lng, created_at, updated_at')
          .not('lat', 'is', null)
          .not('lng', 'is', null)
          .order('name');

      if (response.isEmpty) {
        return [];
      }

      return (response as List<dynamic>)
          .map((item) => Venue.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar locais com coordenadas: $e');
    }
  }

  /// Get venues without coordinates (lat or lng is null)
  Future<List<Venue>> getVenuesWithoutCoordinates() async {
    try {
      final response = await _client
          .from('venues')
          .select('id, name, address, lat, lng, created_at, updated_at')
          .or('lat.is.null,lng.is.null')
          .order('name');

      if (response.isEmpty) {
        return [];
      }

      return (response as List<dynamic>)
          .map((item) => Venue.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar locais sem coordenadas: $e');
    }
  }

  /// Get all venues as raw maps (for CRUD operations)
  Future<List<Map<String, dynamic>>> getAllVenuesForCrud() async {
    try {
      final response = await _client
          .from('venues')
          .select('id, name, address, lat, lng, created_at, updated_at')
          .order('name');

      if (response.isEmpty) {
        return [];
      }

      return (response as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Erro ao carregar locais: $e');
    }
  }
}
