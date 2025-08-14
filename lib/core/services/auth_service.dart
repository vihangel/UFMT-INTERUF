import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final GoTrueClient _client;

  AuthService(this._client);

  Stream<AuthState> get onAuthStateChange => _client.onAuthStateChange;

  User? get currentUser => _client.currentUser;

  Future<void> signOut() async {
    await _client.signOut();
  }

  Future<void> signInWithPassword(String email, String password) async {
    await _client.signInWithPassword(email: email, password: password);
  }
}
