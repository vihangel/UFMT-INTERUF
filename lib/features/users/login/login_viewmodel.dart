import 'package:flutter/material.dart';
import 'package:interufmt/core/data/services/auth_service.dart';
import 'package:interufmt/core/data/services/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum LoginResult { successHome, successChooseAthletic, failure }

class LoginViewModel extends ChangeNotifier {
  final AuthService _auth;
  final ProfileService _profileService;
  final formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool remember = false;
  bool obscure = true;
  bool loading = false;
  String? error;

  LoginViewModel(this._auth, this._profileService);

  void toggleObscure() {
    obscure = !obscure;
    notifyListeners();
  }

  set rememberSetter(bool v) {
    remember = v;
    notifyListeners();
  }

  set emailSetter(String v) {
    email = v;
    notifyListeners();
  }

  set passwordSetter(String v) {
    password = v;
    notifyListeners();
  }

  Future<LoginResult> login(String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await _auth.signInWithPassword(email, password);
      final profile = await _profileService.getMyProfile();
      if (profile?['selected_athletic_id'] == null) {
        return LoginResult.successChooseAthletic;
      } else {
        return LoginResult.successHome;
      }
    } on AuthException catch (e) {
      error = e.message;
      return LoginResult.failure;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Ações (plugue com seu backend)
  void onForgotPassword() {
    // TODO: navegar para fluxo de recuperação
  }

  Future<LoginResult> onSubmit() async {
    if (formKey.currentState?.validate() ?? false) {
      return await login(email, password);
    }
    return LoginResult.failure;
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

  void onGoToRegister() {
    // TODO: navegar para registro
  }
}
