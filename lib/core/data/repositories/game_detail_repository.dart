import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/game_detail_model.dart';

class GameDetailRepository {
  final SupabaseClient _client;

  GameDetailRepository(this._client);

  /// Get game detail by modality ID for unique games
  Future<GameDetail?> getGameDetailByModality(
    String modalityId,
    String series,
  ) async {
    try {
      // Get the unique game for this modality and series (where a_athletic_id and b_athletic_id are null)
      final gameResponse = await _client
          .from('games')
          .select('''
            id,
            start_at,
            status,
            athletics_standings,
            venues(name),
            modalities(name, gender)
          ''')
          .eq('modality_id', modalityId)
          .eq('series', series)
          .isFilter('a_athletic_id', null)
          .isFilter('b_athletic_id', null)
          .maybeSingle();

      if (gameResponse == null) {
        return null;
      }

      final modality = gameResponse['modalities'] as Map<String, dynamic>;
      final venue = gameResponse['venues'] as Map<String, dynamic>?;

      // Extract participating athletics IDs from athletics_standings
      final participatingIds = _extractParticipatingAthletics(
        gameResponse['athletics_standings'],
      );

      // Get athlete standings for this game
      final standings = await _getAthleteStandings(
        gameResponse['id'] as String,
      );

      return GameDetail(
        gameId: gameResponse['id'] as String,
        modalityName: modality['name'] as String,
        modalityGender: modality['gender'] as String,
        startAt: DateTime.parse(gameResponse['start_at'] as String),
        status: gameResponse['status'] as String,
        venueName: venue?['name'] as String?,
        participatingAthleticsIds: participatingIds,
        standings: standings,
      );
    } catch (e) {
      throw Exception('Erro ao carregar detalhes do jogo: $e');
    }
  }

  /// Get participating athletics logos
  Future<List<String>> getParticipatingAthleticsLogos(
    String modalityId,
    String series,
  ) async {
    try {
      final gameResponse = await _client
          .from('games')
          .select('athletics_standings')
          .eq('modality_id', modalityId)
          .eq('series', series)
          .isFilter('a_athletic_id', null)
          .isFilter('b_athletic_id', null)
          .maybeSingle();

      if (gameResponse == null) return [];

      final athleticsStandings = gameResponse['athletics_standings'];
      if (athleticsStandings == null) return [];

      final athleticIds = _extractParticipatingAthletics(athleticsStandings);

      if (athleticIds.isEmpty) return [];

      // Get athletics logos
      final athleticsResponse = await _client
          .from('athletics')
          .select('logo_url')
          .inFilter('id', athleticIds);

      return athleticsResponse
          .map((athletic) => athletic['logo_url'] as String? ?? '')
          .where((logo) => logo.isNotEmpty)
          .toList();
    } catch (e) {
      // Return empty list if error occurs
      return [];
    }
  }

  /// Extract participating athletics IDs from athletics_standings JSON
  List<String> _extractParticipatingAthletics(dynamic athleticsStandings) {
    if (athleticsStandings == null) return [];

    try {
      if (athleticsStandings is Map<String, dynamic>) {
        // Check different possible structures in the JSON
        if (athleticsStandings.containsKey('id_atletics')) {
          final idAtletics = athleticsStandings['id_atletics'];
          if (idAtletics is List) {
            return List<String>.from(idAtletics);
          }
        }

        // Alternative structure: list of athletics with IDs
        if (athleticsStandings.containsKey('athletics')) {
          final athletics = athleticsStandings['athletics'];
          if (athletics is List) {
            return athletics
                .where((item) => item is Map && item.containsKey('id'))
                .map((item) => item['id'] as String)
                .toList();
          }
        }
      }

      if (athleticsStandings is List) {
        // Direct list of athletics IDs or objects
        return athleticsStandings
            .where((item) => item != null)
            .map((item) {
              if (item is String) return item;
              if (item is Map && item.containsKey('id'))
                return item['id'] as String;
              return null;
            })
            .where((id) => id != null)
            .cast<String>()
            .toList();
      }
    } catch (e) {
      // If parsing fails, return empty list
    }

    return [];
  }

  /// Get athlete standings for a game
  Future<List<AthleteStanding>> _getAthleteStandings(String gameId) async {
    try {
      // Get athletes who participated in this game with their athletics info
      final response = await _client
          .from('athlete_game')
          .select('''
            athletes!inner(id, full_name, athletic_id),
            athletics:athletes!inner(athletic_id)
          ''')
          .eq('game_id', gameId);

      if (response.isEmpty) {
        return [];
      }

      // Get athletics info for the athletes
      final athleticIds = response
          .map(
            (item) =>
                (item['athletes'] as Map<String, dynamic>)['athletic_id']
                    as String,
          )
          .toSet()
          .toList();

      final athleticsResponse = await _client
          .from('athletics')
          .select('id, name, logo_url')
          .inFilter('id', athleticIds);

      // Create a map for quick lookup of athletics info
      final athleticsMap = <String, Map<String, dynamic>>{};
      for (final athletic in athleticsResponse) {
        athleticsMap[athletic['id']] = athletic;
      }

      final standings = <AthleteStanding>[];

      for (int i = 0; i < response.length; i++) {
        final athleteData = response[i]['athletes'] as Map<String, dynamic>;
        final athleticId = athleteData['athletic_id'] as String;
        final athleticData = athleticsMap[athleticId] ?? {};

        standings.add(
          AthleteStanding(
            position: i + 1, // Position based on order
            athleteId: athleteData['id'] as String,
            athleteName: athleteData['full_name'] as String,
            athleticId: athleticId,
            athleticName: athleticData['name'] as String? ?? '',
            athleticLogoUrl: athleticData['logo_url'] as String?,
          ),
        );
      }

      // Sort by athlete name for consistent ordering
      standings.sort((a, b) => a.athleteName.compareTo(b.athleteName));

      // Reassign positions after sorting
      for (int i = 0; i < standings.length; i++) {
        standings[i] = AthleteStanding(
          position: i + 1,
          athleteId: standings[i].athleteId,
          athleteName: standings[i].athleteName,
          athleticId: standings[i].athleticId,
          athleticName: standings[i].athleticName,
          athleticLogoUrl: standings[i].athleticLogoUrl,
          stats: standings[i].stats,
        );
      }

      return standings;
    } catch (e) {
      // Return empty list if error occurs
      return [];
    }
  }
}
