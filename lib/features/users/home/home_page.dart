// lib/features/users/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:interufmt/core/data/atletica_model.dart'; // Importa a classe Atletica
import 'package:interufmt/core/data/services/athletics_service.dart';
import 'package:interufmt/core/data/services/auth_service.dart';
import 'package:interufmt/core/theme/app_colors.dart';
import 'package:interufmt/core/theme/app_icons.dart';
import 'package:interufmt/core/widgets/tabela_classificacao.dart';
import 'package:interufmt/features/admin/admin_panel_page.dart';
import 'package:interufmt/features/users/athletics/athletics_page.dart';
import 'package:interufmt/features/users/calendar/calendar_page.dart';
import 'package:interufmt/features/users/home/widgets/sections_social_media_widget.dart';
import 'package:interufmt/features/users/home/widgets/tabela_classificacao_shimmer.dart';
import 'package:interufmt/features/users/modalities/modalities_page.dart';
import 'package:interufmt/features/users/news/news_page.dart';
import 'package:interufmt/features/users/venues/venues_page.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  static const String routename = 'home';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  Widget _page = const _HomeContent();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          _page = const _HomeContent();
          break;
        case 1:
          _page = const AthleticsPage();
          break;
        case 2:
          _page = const CalendarPage();
          break;
        case 3:
          _page = const ModalitiesPage();
          break;
        case 4:
          _page = const VenuesPage();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _page,
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AppIcons.icHome,
              colorFilter: const ColorFilter.mode(
                AppColors.unselectedColorIcon,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              AppIcons.icHome,
              colorFilter: const ColorFilter.mode(
                AppColors.primaryText,
                BlendMode.srcIn,
              ),
            ),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AppIcons.icChess,
              colorFilter: const ColorFilter.mode(
                AppColors.unselectedColorIcon,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              AppIcons.icChess,
              colorFilter: const ColorFilter.mode(
                AppColors.primaryText,
                BlendMode.srcIn,
              ),
            ),
            label: 'Atléticas',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AppIcons.icCalendar,
              colorFilter: const ColorFilter.mode(
                AppColors.unselectedColorIcon,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              AppIcons.icCalendar,
              colorFilter: const ColorFilter.mode(
                AppColors.primaryText,
                BlendMode.srcIn,
              ),
            ),
            label: 'Calendário',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AppIcons.icTrophy,
              colorFilter: const ColorFilter.mode(
                AppColors.unselectedColorIcon,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              AppIcons.icTrophy,
              colorFilter: const ColorFilter.mode(
                AppColors.primaryText,
                BlendMode.srcIn,
              ),
            ),
            label: 'Modalidade',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              AppIcons.icLocation,
              colorFilter: const ColorFilter.mode(
                AppColors.unselectedColorIcon,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              AppIcons.icLocation,
              colorFilter: const ColorFilter.mode(
                AppColors.primaryText,
                BlendMode.srcIn,
              ),
            ),
            label: 'Local',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primaryText,

        unselectedItemColor: AppColors.unselectedColorIcon,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  bool _isAdminOrModerator = false;
  bool _isCheckingRole = true;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final authService = context.read<AuthService>();

    if (!authService.isAuthenticated) {
      setState(() {
        _isCheckingRole = false;
        _isAdminOrModerator = false;
      });
      return;
    }

    final isAuthorized = await authService.isAdminOrModerator();
    setState(() {
      _isCheckingRole = false;
      _isAdminOrModerator = isAuthorized;
    });
  }

  @override
  Widget build(BuildContext context) {
    final athleticsService = context.read<AthleticsService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Início'),
        actions: [
          if (!_isCheckingRole && _isAdminOrModerator)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Painel Administrativo',
              onPressed: () {
                context.pushNamed(AdminPanelPage.routename);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 36),
            SectionsSocialMediaWidget(),
            const SizedBox(height: 32),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.newspaper, size: 24),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notícias',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Acompanhe as novidades mais recentes...',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.goNamed(NewsPage.routename);
                      },
                      child: const Row(
                        children: [Text('Ver'), Icon(Icons.arrow_forward)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Série A with FutureBuilder
            FutureBuilder<List<Atletica>>(
              future: athleticsService.getAthleticsStandings('A'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const TabelaClassificacaoShimmer();
                }

                if (snapshot.hasError) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(height: 8),
                          Text(
                            'Erro ao carregar Série A: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final classificacaoSerieA = snapshot.data ?? [];

                return GestureDetector(
                  onTap: () {
                    context.go(
                      '/classificacao',
                      extra: {
                        'title': 'Série A',
                        'data': classificacaoSerieA
                            .map((a) => a.toMap())
                            .toList(),
                      },
                    );
                  },
                  child: TabelaClassificacao(
                    title: 'Série A',
                    data: classificacaoSerieA.take(4).toList(),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            // Série B with FutureBuilder
            FutureBuilder<List<Atletica>>(
              future: athleticsService.getAthleticsStandings('B'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const TabelaClassificacaoShimmer();
                }

                if (snapshot.hasError) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(height: 8),
                          Text(
                            'Erro ao carregar Série B: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final classificacaoSerieB = snapshot.data ?? [];

                return GestureDetector(
                  onTap: () {
                    context.go(
                      '/classificacao',
                      extra: {
                        'title': 'Série B',
                        'data': classificacaoSerieB
                            .map((a) => a.toMap())
                            .toList(),
                      },
                    );
                  },
                  child: TabelaClassificacao(
                    title: 'Série B',
                    data: classificacaoSerieB.take(4).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
