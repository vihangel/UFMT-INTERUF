import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VotingService {
  final SupabaseClient _supabaseClient;
  static const String _hasVotedKey = 'has_voted';
  static const String _votedAtleticIdKey = 'voted_athletic_id';

  VotingService(this._supabaseClient);

  /// Check if user is authenticated
  bool get isUserAuthenticated => _supabaseClient.auth.currentUser != null;

  /// Get current user
  User? get currentUser => _supabaseClient.auth.currentUser;

  /// Checks if the authenticated user has already voted
  Future<bool> hasAuthenticatedUserVoted() async {
    if (!isUserAuthenticated) return false;

    try {
      final userId = _supabaseClient.auth.currentUser!.id;

      final response = await _supabaseClient
          .from('athletic_vote')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      return response != null;
    } catch (error) {
      print('Error checking vote status: $error');
      return false;
    }
  }

  /// Gets the athletic ID the authenticated user voted for (if any)
  Future<String?> getAuthenticatedUserVote() async {
    if (!isUserAuthenticated) return null;

    try {
      final userId = _supabaseClient.auth.currentUser!.id;

      final response = await _supabaseClient
          .from('athletic_vote')
          .select('athletic_id')
          .eq('user_id', userId)
          .maybeSingle();

      return response?['athletic_id'] as String?;
    } catch (error) {
      print('Error getting user vote: $error');
      return null;
    }
  }

  /// Checks if the user has already voted (from local storage - for non-authenticated flow)
  Future<bool> hasVoted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasVotedKey) ?? false;
  }

  /// Gets the athletic ID the user voted for (from local storage - for non-authenticated flow)
  Future<String?> getVotedAthleticId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_votedAtleticIdKey);
  }

  /// Registers a vote for an athletic (REQUIRES AUTHENTICATION)
  Future<void> vote(String athleticId) async {
    // Check if user is authenticated
    if (!isUserAuthenticated) {
      throw Exception('Você precisa fazer login para votar');
    }

    try {
      final user = _supabaseClient.auth.currentUser!;
      final userId = user.id;
      final userEmail = user.email;

      // Check if user has already voted
      final alreadyVoted = await hasAuthenticatedUserVoted();

      if (alreadyVoted) {
        // Get the previously voted athletic
        final previousVote = await getAuthenticatedUserVote();

        if (previousVote == athleticId) {
          // Same vote, no need to do anything
          return;
        }

        // Delete previous vote (RLS policy allows users to delete their own votes)
        await _supabaseClient
            .from('athletic_vote')
            .delete()
            .eq('user_id', userId);
      }

      // Insert new vote with authentication data
      await _supabaseClient.from('athletic_vote').insert({
        'athletic_id': athleticId,
        'user_id': userId,
        'user_email': userEmail,
        'votante_id': 'auth-$userId', // For backward compatibility
      });

      // Store vote status locally for quick access
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hasVotedKey, true);
      await prefs.setString(_votedAtleticIdKey, athleticId);
    } on PostgrestException catch (error) {
      if (error.message.contains('duplicate key')) {
        throw Exception('Você já votou nesta atlética');
      }
      throw Exception('Erro ao registrar voto: ${error.message}');
    } catch (error) {
      throw Exception('Erro ao registrar voto: $error');
    }
  }

  /// Clears the vote (for testing purposes or if user wants to change vote)
  Future<void> clearVote() async {
    if (!isUserAuthenticated) {
      throw Exception('Você precisa estar autenticado para limpar o voto');
    }

    try {
      final userId = _supabaseClient.auth.currentUser!.id;

      // Delete vote from database
      await _supabaseClient
          .from('athletic_vote')
          .delete()
          .eq('user_id', userId);

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
    final hasVoted = await hasAuthenticatedUserVoted();
    final votedFor = await getAuthenticatedUserVote();
    final userEmail = _supabaseClient.auth.currentUser?.email;

    return {
      'is_authenticated': isUserAuthenticated,
      'user_email': userEmail,
      'has_voted': hasVoted,
      'voted_for': votedFor,
    };
  }
}
