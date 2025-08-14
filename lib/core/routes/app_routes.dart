import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interufmt/features/auth/auth_viewmodel.dart';
import 'package:interufmt/features/home/home_page.dart';
import 'package:interufmt/features/login/login_page.dart';
import 'package:provider/provider.dart';

class AppRoutes {
  static GoRouter getRouter(BuildContext context) {
    final authViewModel = context.read<AuthViewModel>();
    return GoRouter(
      refreshListenable: authViewModel,
      initialLocation: '/',
      routes: [
        GoRoute(
          name: LoginPage.routename,
          path: '/',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          name: 'home',
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
      ],
      redirect: (BuildContext context, GoRouterState state) {
        final loggedIn = authViewModel.currentUser != null;
        final loggingIn = state.matchedLocation == '/';

        if (!loggedIn) {
          return '/';
        }

        if (loggingIn) {
          return '/home';
        }

        return null;
      },
    );
  }
}
