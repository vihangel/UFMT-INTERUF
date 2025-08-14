import 'dart:async';

import 'package:flutter/material.dart';
import 'package:interufmt/core/data/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  late final StreamSubscription<AuthState> _authStateSubscription;
  String? _error;

  String? get error => _error;

  AuthViewModel(this._authRepository) {
    _authStateSubscription = _authRepository.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  User? get currentUser => _authRepository.currentUser;

  Future<void> signOut() async {
    try {
      _error = null;
      await _authRepository.signOut();
    } on AuthException catch (e) {
      _error = e.message;
    } finally {
      notifyListeners();
    }
  }

  Future<void> signInWithPassword(String email, String password) async {
    try {
      _error = null;
      await _authRepository.signInWithPassword(email, password);
    } on AuthException catch (e) {
      _error = e.message;
    } finally {
      notifyListeners();
    }
  }
}
