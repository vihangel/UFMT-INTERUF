import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interufmt/features/home/home_page.dart';
import 'package:interufmt/features/login/auth/auth_viewmodel.dart';
import 'package:interufmt/features/login/choose_athletic_page.dart';
import 'package:interufmt/features/login/forgot_password_page.dart';
import 'package:interufmt/features/login/login_page.dart';
import 'package:interufmt/features/login/signup_page.dart';
import 'package:interufmt/features/login/update_password_page.dart';
import 'package:provider/provider.dart';

class AppRoutes {
  static GoRouter getRouter(
    BuildContext context,
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    final authViewModel = context.read<AuthViewModel>();
    return GoRouter(
      navigatorKey: navigatorKey,
      refreshListenable: authViewModel,
      initialLocation: '/',
      routes: [
        GoRoute(
          name: LoginPage.routename,
          path: '/',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          name: HomePage.routename,
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          name: SignUpPage.routename,
          path: '/signup',
          builder: (context, state) => const SignUpPage(),
        ),
        GoRoute(
          name: ChooseAthleticPage.routename,
          path: '/choose-athletic',
          builder: (context, state) => const ChooseAthleticPage(),
        ),
        GoRoute(
          name: ForgotPasswordPage.routename,
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordPage(),
        ),
        GoRoute(
          name: UpdatePasswordPage.routename,
          path: '/update-password',
          builder: (context, state) => const UpdatePasswordPage(),
        ),
      ],
      redirect: (BuildContext context, GoRouterState state) {
        final loggedIn = authViewModel.currentUser != null;
        // Rotas que não precisam de autenticação
        final unprotectedRoutes = [
          '/',
          '/signup',
          '/forgot-password',
          '/update-password',
          '/choose-athletic',
        ];
        final isUnprotected = unprotectedRoutes.contains(state.matchedLocation);

        if (loggedIn &&
            isUnprotected &&
            state.matchedLocation != '/update-password') {
          return '/home';
        }

        if (!loggedIn && !isUnprotected) {
          return '/';
        }

        return null;
      },
    );
  }
}
