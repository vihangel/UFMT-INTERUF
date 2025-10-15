import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class VotingService {
  final SupabaseClient _supabaseClient;
  static const String _votanteIdKey = 'votante_id';
  static const String _hasVotedKey = 'has_voted';
  static const String _votedAtleticIdKey = 'voted_athletic_id';

  VotingService(this._supabaseClient);

  /// Gets or creates a unique voter ID for this device/user
  /// This ID persists across app sessions
  Future<String> getOrCreateVotanteId() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if we already have a votante_id stored
    String? votanteId = prefs.getString(_votanteIdKey);

    if (votanteId == null || votanteId.isEmpty) {
      // Generate a new unique ID
      votanteId = await _generateUniqueVotanteId();
      await prefs.setString(_votanteIdKey, votanteId);
    }

    return votanteId;
  }

  /// Generates a unique voter ID based on platform
  Future<String> _generateUniqueVotanteId() async {
    // Use UUID for a unique identifier
    final uuid = Uuid();
    String uniqueId = uuid.v4();

    // Add platform prefix for better tracking
    String platform = _getPlatformPrefix();

    return '$platform-$uniqueId';
  }

  /// Gets platform prefix for voter ID
  String _getPlatformPrefix() {
    if (kIsWeb) {
      return 'web';
    } else if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    } else if (Platform.isWindows) {
      return 'windows';
    } else if (Platform.isMacOS) {
      return 'macos';
    } else if (Platform.isLinux) {
      return 'linux';
    }
    return 'unknown';
  }

  /// Checks if the user has already voted
  Future<bool> hasVoted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasVotedKey) ?? false;
  }

  /// Gets the athletic ID the user voted for (if any)
  Future<String?> getVotedAthleticId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_votedAtleticIdKey);
  }

  /// Registers a vote for an athletic
  Future<void> vote(String athleticId) async {
    try {
      // Get or create votante ID
      final votanteId = await getOrCreateVotanteId();

      // Check if user has already voted
      final alreadyVoted = await hasVoted();

      if (alreadyVoted) {
        // Get the previously voted athletic
        final previousVote = await getVotedAthleticId();

        if (previousVote == athleticId) {
          // Same vote, no need to do anything
          return;
        }

        // Delete previous vote
        await _supabaseClient
            .from('athletic_vote')
            .delete()
            .eq('votante_id', votanteId);
      }

      // Insert new vote
      await _supabaseClient.from('athletic_vote').insert({
        'athletic_id': athleticId,
        'votante_id': votanteId,
      });

      // Store vote status locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hasVotedKey, true);
      await prefs.setString(_votedAtleticIdKey, athleticId);
    } catch (error) {
      throw Exception('Erro ao registrar voto: $error');
    }
  }

  /// Clears the vote (for testing purposes or if user wants to change vote)
  Future<void> clearVote() async {
    try {
      final votanteId = await getOrCreateVotanteId();

      // Delete vote from database
      await _supabaseClient
          .from('athletic_vote')
          .delete()
          .eq('votante_id', votanteId);

      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_hasVotedKey);
      await prefs.remove(_votedAtleticIdKey);
    } catch (error) {
      throw Exception('Erro ao limpar voto: $error');
    }
  }

  /// Gets voting statistics for debugging
  Future<Map<String, dynamic>> getVotingStats() async {
    final votanteId = await getOrCreateVotanteId();
    final hasVoted = await this.hasVoted();
    final votedFor = await getVotedAthleticId();

    return {
      'votante_id': votanteId,
      'has_voted': hasVoted,
      'voted_for': votedFor,
    };
  }
}
