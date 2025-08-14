import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/di/app_module.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final providers = await AppModule.init();
  runApp(MultiProvider(providers: providers, child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<AuthState>? _sub;
  late GoRouter appRoutes;
  @override
  void initState() {
    super.initState();
    appRoutes = AppRoutes.getRouter(context, navigatorKey);
    final auth = Supabase.instance.client.auth;
    _sub = auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.passwordRecovery) {
        appRoutes.go('/update-password');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'InterUFMT',
      theme: AppTheme.theme,
      routerConfig: appRoutes,
    );
  }
}
