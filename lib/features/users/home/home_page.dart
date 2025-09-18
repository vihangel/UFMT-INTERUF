// lib/features/users/home_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interufmt/core/data/mocks/classificacao_mock.dart';
import 'package:interufmt/core/widgets/tabela_classificacao.dart';
import 'package:interufmt/features/rating_page.dart';
// Importe a classe Noticias

class HomePage extends StatefulWidget {
  static const String routename = 'home';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Índice da aba selecionada

  static const List<Widget> _widgetOptions = <Widget>[
    _HomeContent(), // Página de Início agora é um widget separado
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

// O conteúdo da Home agora está em um widget separado para melhor organização
// lib/features/users/home_page.dart

// ... imports e classes HomePage, _HomePageState

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Links para Redes Sociais
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.camera_alt), // Ícone de Instagram
                Icon(Icons.flutter_dash), // Placeholder para Twitter
                Icon(Icons.play_circle_fill), // Ícone de YouTube
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
                  // Ícone/Imagem
                  const Icon(Icons.article),

                  const SizedBox(width: 16),

                  // Título e Descrição
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

                  // Botão "Ver"
                  TextButton(
                    onPressed: () {
                      context.go(
                        '/noticias',
                      ); // Navega para a página de notícias
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

          // --- Seção de Classificação ---
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Classificação Geral',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          // Tabela de Classificação da Série A (resumo)
          GestureDetector(
            onTap: () {
              context.go(
                RatingPage.routename,
                extra: {'title': 'Série A', 'data': classificacaoSerieA},
              );
            },
            child: TabelaClassificacao(
              title: 'Série A',
              data: classificacaoSerieA.take(4).toList(),
            ),
          ),

          // Tabela de Classificação da Série B (resumo)
          GestureDetector(
            onTap: () {
              context.go(
                RatingPage.routename,
                extra: {'title': 'Série B', 'data': classificacaoSerieB},
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
