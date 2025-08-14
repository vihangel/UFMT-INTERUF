import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:interufmt/core/data/repositories/auth_repository.dart';
import 'package:interufmt/core/data/services/auth_service.dart';
import 'package:interufmt/core/data/services/profile_service.dart';
import 'package:interufmt/features/login/auth/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ModuleInitializer {
  static Future<List<SingleChildWidget>> initialize() async {
    await dotenv.load(fileName: ".env");

    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );

    final supabaseClient = Supabase.instance.client;
    final authService = AuthService(supabaseClient);
    final profileService = ProfileService(supabaseClient);
    final authRepository = AuthRepository(authService);

    return [
      Provider.value(value: authService),
      Provider.value(value: profileService),
      ChangeNotifierProvider(create: (_) => AuthViewModel(authRepository)),
    ];
  }
}
