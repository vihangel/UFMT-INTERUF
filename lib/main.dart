import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:interufmt/core/config/url_strategy_mobile.dart';
import 'package:provider/provider.dart';

import 'core/data/services/local_storage_service.dart';
import 'core/di/app_module.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

export 'package:interufmt/core/config/url_strategy_mobile.dart'
    if (dart.library.html) 'package:interufmt/core/config/url_strategy_web.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  configureUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables first
  await dotenv.load(fileName: ".env");
  final providers = await AppModule.init();
  final localStorageService = LocalStorageService();
  final chosenAthletic = await localStorageService.getChosenAthleticName();

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
    );
  }
}
