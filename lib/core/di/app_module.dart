import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/environment.dart';
import '../../features/users/login/auth/auth_viewmodel.dart';
import '../../features/users/news/viewmodel/news_viewmodel.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/news_repository.dart';
import '../data/services/athletics_service.dart';
import '../data/services/auth_service.dart';
import '../data/services/news_service.dart';
import '../data/services/profile_service.dart';
import '../services/voting_service.dart';

class AppModule {
  /// Initializes .env/Supabase and returns the list of app providers.
  static Future<List<SingleChildWidget>> init() async {
    await Supabase.initialize(
      url: Environment.supabaseUrl,
      anonKey: Environment.supabaseAnonKey,
    );
    final client = Supabase.instance.client;

    return [
      // Leaf services receive the client
      Provider<AuthService>(create: (_) => AuthService(client)),
      Provider<ProfileService>(create: (_) => ProfileService(client)),
      Provider<AthleticsService>(create: (_) => AthleticsService(client)),
      Provider<NewsService>(create: (_) => NewsService(client)),
      Provider<VotingService>(create: (_) => VotingService(client)),

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
