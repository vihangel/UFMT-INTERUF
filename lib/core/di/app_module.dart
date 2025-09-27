import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/users/login/auth/auth_viewmodel.dart';
import '../../features/users/news/viewmodel/news_viewmodel.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/news_repository.dart';
import '../data/services/athletics_service.dart';
import '../data/services/auth_service.dart';
import '../data/services/news_service.dart';
import '../data/services/profile_service.dart';

class AppModule {
  /// Initializes .env/Supabase and returns the list of app providers.
  static Future<List<SingleChildWidget>> init() async {
    await dotenv.load(fileName: ".env");

    final url = dotenv.env['SUPABASE_URL'];
    final anon = dotenv.env['SUPABASE_ANON_KEY'];
    if (url == null || anon == null) {
      throw Exception(
        'SUPABASE_URL or SUPABASE_ANON_KEY are missing from .env',
      );
    }

    await Supabase.initialize(url: url, anonKey: anon);
    final client = Supabase.instance.client;

    return [
      // Leaf services receive the client
      Provider<AuthService>(create: (_) => AuthService(client)),
      Provider<ProfileService>(create: (_) => ProfileService(client)),
      Provider<AthleticsService>(create: (_) => AthleticsService(client)),
      Provider<NewsService>(create: (_) => NewsService(client)),

      // Repository depends on the service
      Provider<AuthRepository>(
        create: (ctx) => AuthRepository(ctx.read<AuthService>()),
      ),
      Provider<NewsRepository>(
        create: (ctx) => NewsRepository(ctx.read<NewsService>()),
      ),

      // ViewModel depends on the repository
      ChangeNotifierProvider<AuthViewModel>(
        create: (ctx) => AuthViewModel(ctx.read<AuthRepository>()),
      ),
      ChangeNotifierProvider<NewsViewModel>(
        create: (ctx) => NewsViewModel(ctx.read<NewsRepository>()),
      ),
    ];
  }
}
