import 'package:go_router/go_router.dart';

import '../../features/home/presenter/home_page.dart';

class AppRoutes {
  static final router = GoRouter(
    initialLocation: HomePage.routename,
    routes: [
      GoRoute(
        path: HomePage.routename,
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}
