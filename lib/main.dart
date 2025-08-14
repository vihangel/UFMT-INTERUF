import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:interufmt/core/repositories/auth_repository.dart';
import 'package:interufmt/core/services/auth_service.dart';
import 'package:interufmt/features/auth/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final authService = AuthService(Supabase.instance.client.auth);
  final authRepository = AuthRepository(authService);

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthViewModel(authRepository),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter App',
      theme: AppTheme.theme,
      routerConfig: AppRoutes.getRouter(context),
    );
  }
}

final supabase = Supabase.instance.client;
