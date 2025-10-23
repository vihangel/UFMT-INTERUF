import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interufmt/core/data/atletica_model.dart';
import 'package:interufmt/features/admin/admin_panel_page.dart';
import 'package:interufmt/features/admin/athletes_crud_page.dart';
import 'package:interufmt/features/admin/athletics_crud_page.dart';
import 'package:interufmt/features/admin/auth/admin_login_page.dart';
import 'package:interufmt/features/admin/games_crud_page.dart';
import 'package:interufmt/features/admin/home/admin_home_page.dart';
import 'package:interufmt/features/admin/modalities_crud_page.dart';
import 'package:interufmt/features/admin/news_crud_page.dart';
import 'package:interufmt/features/admin/venues_crud_page.dart';
import 'package:interufmt/features/escolha_atletica_page.dart';
import 'package:interufmt/features/rating_page.dart';
import 'package:interufmt/features/torcidometro_page.dart';
import 'package:interufmt/features/users/athletics/athletics_page.dart';
import 'package:interufmt/features/users/calendar/calendar_page.dart';
import 'package:interufmt/features/users/home/home_page.dart';
import 'package:interufmt/features/users/login/auth/auth_viewmodel.dart';
import 'package:interufmt/features/users/login/forgot_password_page.dart';
import 'package:interufmt/features/users/login/login_page.dart';
import 'package:interufmt/features/users/login/signup_page.dart';
import 'package:interufmt/features/users/login/update_password_page.dart';
import 'package:interufmt/features/users/modalities/modalities_page.dart';
import 'package:interufmt/features/users/news/news_page.dart';
import 'package:interufmt/features/users/venues/venues_page.dart';
import 'package:provider/provider.dart';

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
          path: '/auth/callback',
          builder: (context, state) {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Autenticando...'),
                  ],
                ),
              ),
            );
          },
          redirect: (context, state) async {
            await Future.delayed(const Duration(milliseconds: 800));

            return '/home';
          },
        ),
        GoRoute(
          name: HomePage.routename,
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          name: NewsPage.routename,
          path: '/noticias',
          builder: (context, state) => const NewsPage(),
        ),
        GoRoute(
          name: TorcidometroPage.routename,
          path: '/torcidometro',
          builder: (context, state) => const TorcidometroPage(),
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
        // Admin Panel (for moderators and admins)
        GoRoute(
          name: AdminPanelPage.routename,
          path: '/admin-panel',
          builder: (context, state) => const AdminPanelPage(),
        ),
        // Admin CRUD Pages
        GoRoute(
          name: VenuesCrudPage.routename,
          path: '/admin-panel/venues',
          builder: (context, state) => const VenuesCrudPage(),
        ),
        GoRoute(
          name: NewsCrudPage.routename,
          path: '/admin-panel/news',
          builder: (context, state) => const NewsCrudPage(),
        ),
        GoRoute(
          name: ModalitiesCrudPage.routename,
          path: '/admin-panel/modalities',
          builder: (context, state) => const ModalitiesCrudPage(),
        ),
        GoRoute(
          name: AthleticsCrudPage.routename,
          path: '/admin-panel/athletics',
          builder: (context, state) => const AthleticsCrudPage(),
        ),
        GoRoute(
          name: AthletesCrudPage.routename,
          path: '/admin-panel/athletes',
          builder: (context, state) => const AthletesCrudPage(),
        ),
        GoRoute(
          name: GamesCrudPage.routename,
          path: '/admin-panel/games',
          builder: (context, state) => const GamesCrudPage(),
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

        // // Se estiver rodando na web e for a rota inicial ('/'), redireciona para o painel admin
        // if (kIsWeb &&
        //     state.matchedLocation == initialLocation &&
        //     (initialLocation == '/' || initialLocation.isEmpty)) {
        //   return '/admin-panel';
        // }

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
