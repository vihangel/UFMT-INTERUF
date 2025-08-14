import 'package:flutter/material.dart';
import 'package:interufmt/features/login/auth/auth_viewmodel.dart';

class AuthProvider extends InheritedWidget {
  final AuthViewModel authViewModel;

  const AuthProvider({
    super.key,
    required this.authViewModel,
    required super.child,
  });

  static AuthProvider of(BuildContext context) {
    final AuthProvider? result = context
        .dependOnInheritedWidgetOfExactType<AuthProvider>();
    assert(result != null, 'No AuthProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AuthProvider oldWidget) {
    return authViewModel != oldWidget.authViewModel;
  }
}
