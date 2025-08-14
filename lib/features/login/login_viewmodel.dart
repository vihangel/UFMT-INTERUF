import 'package:flutter/material.dart';
import 'package:interufmt/features/auth/auth_viewmodel.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthViewModel _authViewModel;
  final formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool remember = false;
  bool obscure = true;

  LoginViewModel(this._authViewModel);

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

  // Ações (plugue com seu backend)
  void onForgotPassword() {
    // TODO: navegar para fluxo de recuperação
  }

  Future<void> onSubmit() async {
    if (formKey.currentState?.validate() ?? false) {
      await _authViewModel.signInWithPassword(email, password);
    }
  }

  void onGoogleSignIn() {
    // TODO
  }

  void onAppleSignIn() {
    // TODO
  }

  void onGoToRegister() {
    // TODO: navegar para registro
  }
}
