// auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _c;
  AuthService(this._c);

  // eventos de sessão (útil p/ ouvir confirmação de e-mail, recovery, etc.)
  Stream<AuthState> get onAuthStateChange => _c.auth.onAuthStateChange;
  User? get currentUser => _c.auth.currentUser;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
    String? avatarUrl,
  }) {
    return _c.auth.signUp(
      email: email,
      password: password,
      data: {
        if (fullName != null) 'full_name': fullName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      },
    );
  }

  Future<AuthResponse> signInWithPassword(String email, String password) {
    return _c.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => _c.auth.signOut();

  // Recuperação por link (recomendado p/ mobile)
  Future<void> sendPasswordResetEmail(String email, {String? redirectTo}) {
    return _c.auth.resetPasswordForEmail(
      email,
      redirectTo: redirectTo, // ex.: 'io.interufmt://reset'
    );
  }

  // Depois do deep link de recovery:
  Future<void> updatePassword(String newPassword) {
    return _c.auth.updateUser(UserAttributes(password: newPassword));
  }

  // Se quiser fluxo com código (OTP) em vez de link:
  Future<void> verifyRecoveryOtp(String email, String token) {
    return _c.auth.verifyOTP(
      type: OtpType.recovery,
      email: email,
      token: token,
    );
  }

  Future<bool> signInWithGoogle() {
    return _c.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutterquickstart://login-callback/',
    );
  }

  Future<bool> signInWithApple() {
    return _c.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'io.supabase.flutterquickstart://login-callback/',
    );
  }
}
