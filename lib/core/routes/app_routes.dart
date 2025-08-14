import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interufmt/features/auth/auth_viewmodel.dart';
import 'package:interufmt/features/auth/choose_athletic_page.dart';
import 'package:interufmt/features/auth/forgot_password_page.dart';
import 'package:interufmt/features/auth/signup_page.dart';
import 'package:interufmt/features/auth/update_password_page.dart';
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
        GoRoute(
          name: 'signup',
          path: '/signup',
          builder: (context, state) => const SignUpPage(),
        ),
        GoRoute(
          name: 'choose-athletic',
          path: '/choose-athletic',
          builder: (context, state) => const ChooseAthleticPage(),
        ),
        GoRoute(
          name: 'forgot-password',
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordPage(),
        ),
        GoRoute(
          name: 'update-password',
          path: '/update-password',
          builder: (context, state) => const UpdatePasswordPage(),
        ),
      ],
      redirect: (BuildContext context, GoRouterState state) {
        final loggedIn = authViewModel.currentUser != null;
        final loggingIn = state.matchedLocation == '/';
        final creatingAccount = state.matchedLocation == '/signup';

        if (!loggedIn) {
          return loggingIn || creatingAccount ? null : '/';
        }

        if (loggingIn) {
          return '/home';
        }

        return null;
      },
    );
  }
}
