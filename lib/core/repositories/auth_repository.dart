import 'dart:async';

import 'package:interufmt/core/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Stream<AuthState> get onAuthStateChange => _authService.onAuthStateChange;

  User? get currentUser => _authService.currentUser;

  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException('An unknown error occurred.');
    }
  }

  Future<void> signInWithPassword(String email, String password) async {
    try {
      await _authService.signInWithPassword(email, password);
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException('An unknown error occurred.');
    }
  }
}
