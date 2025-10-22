import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:interufmt/core/config/url_strategy.dart';
import 'package:interufmt/firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

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
  @override
  void initState() {
    super.initState();
    appRoutes = AppRoutes.getRouter(context, navigatorKey, widget.initialRoute);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'InterUFMT',
      theme: AppTheme.theme,
      routerConfig: appRoutes,
      locale: const Locale('pt', 'BR'),
    );
  }
}
