import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interufmt/core/data/repositories/auth_repository.dart';
import 'package:interufmt/core/data/services/auth_service.dart';
import 'package:interufmt/features/admin/home/admin_home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminLoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository(
    AuthService(Supabase.instance.client),
  );

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _loading = false;
  bool get loading => _loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    log('Error message set: $message');
    _errorMessage = message;
    notifyListeners();
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    _setLoading(true);

    try {
      await _authRepo.signInWithPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw const AuthException('User not found after login.');
      }

      final response = await Supabase.instance.client
          .from('roles')
          .select('role')
          .eq('user_id', user.id)
          .single();

      final role = response['role'];

      if (role == 'admin') {
        if (context.mounted) {
          context.goNamed(AdminHomePage.routename);
        }
      } else {
        await _authRepo.signOut();
        _setErrorMessage('Access denied. You are not an administrator.');
      }
    } on AuthException catch (e) {
      await _authRepo.signOut();
      _setErrorMessage(e.message);
    } catch (e) {
      await _authRepo.signOut();
      _setErrorMessage('An unexpected error occurred: $e');
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
