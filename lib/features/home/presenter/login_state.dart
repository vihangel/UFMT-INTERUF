import 'package:flutter/material.dart';

class LoginState extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool remember = false;
  bool obscure = true;

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

  void onSubmit() {
    if (formKey.currentState?.validate() ?? false) {
      // TODO: autenticar
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
