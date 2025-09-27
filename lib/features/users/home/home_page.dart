// lib/features/users/home_page.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:interufmt/core/data/atletica_model.dart'; // Importa a classe Atletica
import 'package:interufmt/core/data/services/athletics_service.dart';
import 'package:interufmt/core/widgets/tabela_classificacao.dart';
import 'package:interufmt/features/users/home/widgets/sections_social_media_widget.dart';
import 'package:interufmt/features/users/news/news_page.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  static const String routename = 'home';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    _HomeContent(),
    Center(child: Text('Página de Atléticas')),
    Center(child: Text('Página do Calendário')),
    Center(child: Text('Página de Modalidades')),
    Center(child: Text('Página de Local')),
  ];

  void _onItemTapped(int index) {
    if (index == 1) {
      // Navigate to athletics page
      context.go('/athletics');
    } else if (index == 2) {
      // Navigate to calendar page
      context.go('/calendar');
    } else if (index == 3) {
      // Navigate to modalities page
      context.go('/modalities');
    } else if (index == 4) {
      // Navigate to venues page
      context.go('/venues');
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Início')),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.shield), label: 'Atléticas'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendário',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Modalidade',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.place), label: 'Local'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final athleticsService = context.read<AthleticsService>();

    return SingleChildScrollView(
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
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
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
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
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
    );
  }
}
