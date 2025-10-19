// auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _c;

  AuthService(this._c);

  /// List of allowed email domains (add your restrictions here)
  /// Example: ['ufmt.br', 'gmail.com']
  /// Leave empty to allow all domains
  static const List<String> allowedDomains = [
    'sou.ufmt.br',
    // 'gmail.com', // Uncomment to allow specific domains
  ];

  // eventos de sessão (útil p/ ouvir confirmação de e-mail, recovery, etc.)
  Stream<AuthState> get onAuthStateChange => _c.auth.onAuthStateChange;
  User? get currentUser => _c.auth.currentUser;

  /// Check if user is currently authenticated
  bool get isAuthenticated => _c.auth.currentUser != null;

  /// Get current user's email
  String? get userEmail => _c.auth.currentUser?.email;

  /// Get user display name
  String? get userDisplayName {
    final user = currentUser;
    if (user == null) return null;

    final metadata = user.userMetadata;
    return metadata?['full_name'] as String? ??
        metadata?['name'] as String? ??
        user.email?.split('@').first;
  }

  /// Get user profile picture URL
  String? get userPhotoUrl {
    final user = currentUser;
    if (user == null) return null;

    final metadata = user.userMetadata;
    return metadata?['avatar_url'] as String? ??
        metadata?['picture'] as String?;
  }

  /// Validate if email domain is allowed
  bool isEmailDomainAllowed(String email) {
    if (allowedDomains.isEmpty) {
      return true; // No restrictions
    }

    final emailLower = email.toLowerCase().trim();
    for (final domain in allowedDomains) {
      if (emailLower.endsWith('@${domain.toLowerCase()}')) {
        return true;
      }
    }
    return false;
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
    String? avatarUrl,
  }) async {
    // Validate email format
    if (!_isValidEmail(email)) {
      throw AuthException('Por favor, insira um email válido');
    }

    // Check if email domain is allowed
    if (!isEmailDomainAllowed(email)) {
      final domainsText = allowedDomains.map((d) => '@$d').join(', ');
      throw AuthException(
        'Email não permitido.\n'
        'Apenas emails dos domínios: $domainsText são aceitos.',
      );
    }

    try {
      return await _c.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: kIsWeb ? null : 'interufmt://login-callback',
        data: {
          if (fullName != null) 'full_name': fullName,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
        },
      );
    } on AuthException catch (error) {
      if (error.message.contains('already registered')) {
        throw AuthException('Este email já está cadastrado');
      }
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signInWithPassword(String email, String password) async {
    // Validate email format
    if (!_isValidEmail(email)) {
      throw AuthException('Por favor, insira um email válido');
    }

    // Check if email domain is allowed
    if (!isEmailDomainAllowed(email)) {
      final domainsText = allowedDomains.map((d) => '@$d').join(', ');
      throw AuthException(
        'Email não permitido.\n'
        'Apenas emails dos domínios: $domainsText são aceitos.',
      );
    }

    try {
      return await _c.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (error) {
      if (error.message.contains('Invalid login credentials')) {
        throw AuthException('Email ou senha incorretos');
      }
      rethrow;
    }
  }

  /// Sign in with Magic Link (Passwordless)
  /// Sends an email with a magic link for authentication
  Future<void> signInWithMagicLink(String email) async {
    // Validate email format
    if (!_isValidEmail(email)) {
      throw AuthException('Por favor, insira um email válido');
    }

    // Check if email domain is allowed
    if (!isEmailDomainAllowed(email)) {
      final domainsText = allowedDomains.map((d) => '@$d').join(', ');
      throw AuthException(
        'Email não permitido.\n'
        'Apenas emails dos domínios: $domainsText são aceitos.',
      );
    }

    try {
      await _c.auth.signInWithOtp(
        email: email,
        emailRedirectTo: kIsWeb ? null : 'interufmt://login-callback',
      );
    } on AuthException {
      rethrow;
    }
  }

  /// Verify OTP code sent to email
  Future<AuthResponse> verifyEmailOtp(String email, String token) async {
    try {
      return await _c.auth.verifyOTP(
        type: OtpType.email,
        email: email,
        token: token,
      );
    } on AuthException {
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() => _c.auth.signOut();

  // Recuperação por link (recomendado p/ mobile)
  Future<void> sendPasswordResetEmail(String email, {String? redirectTo}) {
    return _c.auth.resetPasswordForEmail(
      email,
      redirectTo: redirectTo ?? (kIsWeb ? null : 'interufmt://reset'),
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
}
