import 'package:go_router/go_router.dart';

import '../../features/login/login_page.dart';

class AppRoutes {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        name: LoginPage.routename,
        path: '/',
        builder: (context, state) => const LoginPage(),
      ),
    ],
  );
}
