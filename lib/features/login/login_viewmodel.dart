import 'package:flutter/material.dart';
import 'package:interufmt/core/data/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _auth;
  final formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool remember = false;
  bool obscure = true;
  bool loading = false;
  String? error;

  LoginViewModel(this._auth);

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

  Future<bool> login(String email, String password) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await _auth.signInWithPassword(email, password);
      return true;
    } on AuthException catch (e) {
      error = e.message;
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Ações (plugue com seu backend)
  void onForgotPassword() {
    // TODO: navegar para fluxo de recuperação
  }

  Future<void> onSubmit() async {
    if (formKey.currentState?.validate() ?? false) {
      await login(email, password);
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

  void onGoToRegister() {
    // TODO: navegar para registro
  }
}
