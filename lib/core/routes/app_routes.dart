import 'package:go_router/go_router.dart';

import '../../features/home/presenter/login_page.dart';

class AppRoutes {
  static final router = GoRouter(
    initialLocation: LoginPage.routename,
    routes: [
      GoRoute(
        name: LoginPage.routename,
        path: '/',
        builder: (context, state) => const LoginPage(),
      ),
    ],
  );
}
