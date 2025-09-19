// lib/features/users/home_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interufmt/core/widgets/tabela_classificacao.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:interufmt/core/data/atletica_model.dart'; 

import 'package:interufmt/features/users/news/news_page.dart';
// Importa a classe Atletica

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
    Center(child: Text('Página de Classificação')),
    Center(child: Text('Página de Local')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
            icon: Icon(Icons.group),
            label: 'Classificação',
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
    // Agora as listas de dados são do tipo List<Atletica>
    final List<Atletica> classificacaoSerieA = [
      const Atletica(
        posicao: 1,
        nome: 'Trojan',
        ouro: 12,
        prata: 4,
        bronze: 2,
        pontos: 452,
      ),
      const Atletica(
        posicao: 2,
        nome: 'Pintada',
        ouro: 2,
        prata: 6,
        bronze: 7,
        pontos: 256,
      ),
      const Atletica(
        posicao: 3,
        nome: 'Guará',
        ouro: 1,
        prata: 4,
        bronze: 10,
        pontos: 142,
      ),
      const Atletica(
        posicao: 4,
        nome: 'Turuna',
        ouro: 0,
        prata: 0,
        bronze: 0,
        pontos: 0,
      ),
      const Atletica(
        posicao: 5,
        nome: 'Outra',
        ouro: 0,
        prata: 0,
        bronze: 0,
        pontos: 0,
      ),
      const Atletica(
        posicao: 6,
        nome: 'Mais',
        ouro: 0,
        prata: 0,
        bronze: 0,
        pontos: 0,
      ),
      const Atletica(
        posicao: 7,
        nome: 'Uma',
        ouro: 0,
        prata: 0,
        bronze: 0,
        pontos: 0,
      ),
    ];

    final List<Atletica> classificacaoSerieB = [
      const Atletica(
        posicao: 1,
        nome: 'Gato Preto',
        ouro: 12,
        prata: 4,
        bronze: 2,
        pontos: 452,
      ),
      const Atletica(
        posicao: 2,
        nome: 'Admafia',
        ouro: 2,
        prata: 6,
        bronze: 7,
        pontos: 256,
      ),
      const Atletica(
        posicao: 3,
        nome: 'Macabra',
        ouro: 1,
        prata: 4,
        bronze: 10,
        pontos: 142,
      ),
      const Atletica(
        posicao: 4,
        nome: 'Metralha',
        ouro: 0,
        prata: 0,
        bronze: 0,
        pontos: 0,
      ),
      const Atletica(
        posicao: 5,
        nome: 'Outra B',
        ouro: 0,
        prata: 0,
        bronze: 0,
        pontos: 0,
      ),
      const Atletica(
        posicao: 6,
        nome: 'Mais B',
        ouro: 0,
        prata: 0,
        bronze: 0,
        pontos: 0,
      ),
      const Atletica(
        posicao: 7,
        nome: 'Uma B',
        ouro: 0,
        prata: 0,
        bronze: 0,
        pontos: 0,
      ),
    ];

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
          const SizedBox(height: 16),

          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Classificação Geral',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          GestureDetector(
            onTap: () {
              context.go(
                '/classificacao',
                extra: {
                  'title': 'Série A',
                  'data': classificacaoSerieA.map((a) => a.toMap()).toList(),
                },
              );
            },
            child: TabelaClassificacao(
              title: 'Série A',
              data: classificacaoSerieA.take(4).toList(),
            ),
          ),

          GestureDetector(
            onTap: () {
              context.go(
                '/classificacao',
                extra: {
                  'title': 'Série B',
                  'data': classificacaoSerieB.map((a) => a.toMap()).toList(),
                },
              );
            },
            child: TabelaClassificacao(
              title: 'Série B',
              data: classificacaoSerieB.take(4).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
