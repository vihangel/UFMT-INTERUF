import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interufmt/features/admin/auth/admin_login_page.dart';
import 'package:interufmt/features/admin/home/admin_home_page.dart';
import 'package:interufmt/features/escolha_atletica_page.dart';
import 'package:interufmt/features/pagina_noticias.dart';
import 'package:interufmt/features/rating_page.dart';
import 'package:interufmt/features/users/home/home_page.dart';
import 'package:interufmt/features/users/login/auth/auth_viewmodel.dart';
import 'package:interufmt/features/users/login/forgot_password_page.dart';
import 'package:interufmt/features/users/login/login_page.dart';
import 'package:interufmt/features/users/login/signup_page.dart';
import 'package:interufmt/features/users/login/update_password_page.dart';
import 'package:interufmt/features/users/athletics/athletics_page.dart';
import 'package:interufmt/features/users/venues/venues_page.dart';
import 'package:interufmt/features/users/modalities/modalities_page.dart';
import 'package:interufmt/features/users/calendar/calendar_page.dart';
import 'package:provider/provider.dart';
import 'package:interufmt/core/data/atletica_model.dart';

class AppRoutes {
  static GoRouter getRouter(
    BuildContext context,
    GlobalKey<NavigatorState> navigatorKey,
    String initialLocation,
  ) {
    final authViewModel = context.read<AuthViewModel>();
    return GoRouter(
      navigatorKey: navigatorKey,
      refreshListenable: authViewModel,
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          name: EscolhaAtleticaPage.routename,
          path: '/',
          builder: (context, state) => const EscolhaAtleticaPage(),
        ),
        GoRoute(
          name: LoginPage.routename,
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          name: HomePage.routename,
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          name: PaginaNoticias.routename,
          path: '/noticias',
          builder: (context, state) => const PaginaNoticias(),
        ),
        GoRoute(
          name: 'athletics',
          path: '/athletics',
          builder: (context, state) => const AthleticsPage(),
        ),
        GoRoute(
          name: 'calendar',
          path: '/calendar',
          builder: (context, state) => const CalendarPage(),
        ),
        GoRoute(
          name: 'venues',
          path: '/venues',
          builder: (context, state) => const VenuesPage(),
        ),
        GoRoute(
          name: 'modalities',
          path: '/modalities',
          builder: (context, state) => const ModalitiesPage(),
        ),
        GoRoute(
          name: RatingPage.routename,
          path: '/classificacao',
          builder: (context, state) {
            final Map<String, dynamic> extras =
                state.extra as Map<String, dynamic>;
            final List<Atletica> dataAtletica = (extras['data'] as List)
                .map((e) => Atletica.fromJson(e))
                .toList();
            return RatingPage(title: extras['title'], data: dataAtletica);
          },
        ),
        GoRoute(
          name: SignUpPage.routename,
          path: '/signup',
          builder: (context, state) => const SignUpPage(),
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
        // Rotas admin
        GoRoute(
          name: AdminLoginPage.routename,
          path: '/admin/login',
          builder: (context, state) => const AdminLoginPage(),
        ),
        GoRoute(
          name: AdminHomePage.routename,
          path: '/admin/home',
          builder: (context, state) => const AdminHomePage(),
        ),
      ],
      redirect: (BuildContext context, GoRouterState state) {
        final isAdminLoggedIn = authViewModel.currentAdmin != null;
        final isAdminRoute = state.matchedLocation.startsWith('/admin');
        final isAdminLogin = state.matchedLocation == '/admin/login';

        // Se for rota admin e não estiver logado como admin, redireciona para login admin
        if (isAdminRoute && !isAdminLoggedIn && !isAdminLogin) {
          return '/admin/login';
        }

        // Se já estiver logado como admin e tentar acessar login admin, redireciona para home admin
        if (isAdminLoggedIn && isAdminLogin) {
          return '/admin/home';
        }

        // Usuário comum não precisa estar logado para acessar rotas públicas
        return null;
      },
    );
  }
}
