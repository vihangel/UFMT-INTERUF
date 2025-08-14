import 'package:flutter/material.dart';
import 'package:interufmt/core/services/auth_service.dart';
import 'package:interufmt/core/services/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpViewModel extends ChangeNotifier {
  final AuthService _auth;
  final ProfileService _profiles;

  bool loading = false;
  String? error;

  SignUpViewModel(this._auth, this._profiles);

  Future<bool> signUp({
    required String email,
    required String password,
    String? fullName,
    required bool acceptedTerms,
  }) async {
    if (!acceptedTerms) {
      error = 'Aceite os termos para continuar';
      notifyListeners();
      return false;
    }

    loading = true;
    error = null;
    notifyListeners();
    try {
      final res = await _auth.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      // Se session == null, precisa confirmar e-mail
      final needsConfirmation = res.session == null;

      return !needsConfirmation; // true => já logado, pode ir escolher atlética
    } on AuthException catch (e) {
      error = e.message;
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> chooseAthletic(String athleticId) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await _profiles.chooseAthletic(athleticId);
    } catch (e) {
      error = 'Falha ao salvar sua atlética';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> onGoogleSignIn() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await _auth.signInWithGoogle();
    } on AuthException catch (e) {
      error = e.message;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> onAppleSignIn() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await _auth.signInWithApple();
    } on AuthException catch (e) {
      error = e.message;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
