import 'dart:async';

import 'package:flutter/material.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRoutes.getRouter(context, navigatorKey);
    return AuthEventsListener(
      child: MaterialApp.router(
        title: 'InterUFMT',
        theme: AppTheme.theme,
        routerConfig: router,
      ),
    );
  }
}

class AuthEventsListener extends StatefulWidget {
  final Widget child;
  const AuthEventsListener({super.key, required this.child});

  @override
  State<AuthEventsListener> createState() => _AuthEventsListenerState();
}

class _AuthEventsListenerState extends State<AuthEventsListener> {
  StreamSubscription<AuthState>? _sub;

  @override
  void initState() {
    super.initState();
    final auth = Supabase.instance.client.auth;
    _sub = auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.passwordRecovery) {
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/update-password',
          (route) => false,
        );
      }
      // Se quiser tratar signedIn/signedOut aqui também, é o lugar.
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
