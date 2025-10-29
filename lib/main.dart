import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:interufmt/core/config/url_strategy.dart';
import 'package:interufmt/firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:interufmt/features/landing/branding_screen.dart';
import 'core/config/environment.dart';
import 'core/data/services/local_storage_service.dart';
import 'core/di/app_module.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  configureUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Environment.init();
  final providers = await AppModule.init();
  final localStorageService = LocalStorageService();
  final chosenAthletic = await localStorageService.getChosenAthleticName();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(
    MultiProvider(
      providers: providers,
      child: MyApp(initialRoute: chosenAthletic != null ? '/home' : '/'),
    ),
  );
}

class MyApp extends StatefulWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoRouter appRoutes;
  bool _isShowingBranding = true; // 1. Controla o estado

  @override
  void initState() {
    super.initState();

    // 2. Inicia o timer de 3 segundos
    Timer(const Duration(seconds: 3), () {
      // 3. Após 3s, inicializa o GoRouter...
      appRoutes = AppRoutes.getRouter(
        context,
        navigatorKey,
        widget.initialRoute,
      );

      // 4. ...e manda o build() reconstruir, agora mostrando o app principal
      if (mounted) {
        setState(() {
          _isShowingBranding = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 5. Lógica de exibição
    if (_isShowingBranding) {
      // Se ainda estivermos no tempo da branding, mostre a tela
      return const BrandingScreen();
    }

    // 6. Quando o tempo acabar, mostre seu app principal com GoRouter
    return MaterialApp.router(
      title: 'InterUFMT',
      theme: AppTheme.theme,
      routerConfig: appRoutes,
      locale: const Locale('pt', 'BR'),
    );
  }
}
