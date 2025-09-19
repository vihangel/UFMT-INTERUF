// lib/features/users/home_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interufmt/features/pagina_noticias.dart';
import 'package:provider/provider.dart';
import 'package:interufmt/core/widgets/tabela_classificacao.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:interufmt/core/data/atletica_model.dart'; // Importa a classe Atletica
import 'package:interufmt/core/data/services/athletics_service.dart';
import 'package:interufmt/features/users/news/news_page.dart';
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
  const _HomeContent({Key? key}) : super(key: key);

  static Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Não foi possível abrir o link $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final athleticsService = context.read<AthleticsService>();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () =>
                      _launchURL('https://www.instagram.com/interufmt'),
                  child: const FaIcon(FontAwesomeIcons.instagram, size: 40),
                ),
                GestureDetector(
                  onTap: () => _launchURL('https://twitter.com/interufmt'),
                  child: const FaIcon(FontAwesomeIcons.x, size: 40),
                ),
                GestureDetector(
                  onTap: () => _launchURL('https://www.youtube.com/interufmt'),
                  child: const FaIcon(FontAwesomeIcons.youtube, size: 40),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
                      context.goNamed(PaginaNoticias.routename);
                    },
                    child: const Row(
                      children: [Text('Ver'), Icon(Icons.arrow_forward)],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Classificação Geral',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          // Série A with FutureBuilder
          FutureBuilder<List<Atletica>>(
            future: athleticsService.getAthleticsStandings('A'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Card(
                  margin: EdgeInsets.all(16),
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Card(
                  margin: const EdgeInsets.all(16),
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

          // Série B with FutureBuilder
          FutureBuilder<List<Atletica>>(
            future: athleticsService.getAthleticsStandings('B'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Card(
                  margin: EdgeInsets.all(16),
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Card(
                  margin: const EdgeInsets.all(16),
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
