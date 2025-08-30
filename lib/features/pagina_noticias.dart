// lib/features/users/pagina_noticias.dart

import 'package:flutter/material.dart';
import 'package:interufmt/core/widgets/noticias.dart';
import 'package:go_router/go_router.dart';

class PaginaNoticias extends StatelessWidget {
  const PaginaNoticias({super.key});

  @override
  Widget build(BuildContext context) {
    // Dados fictícios das notícias (pode ser substituído por dados do Supabase)
    final List<Map<String, String>> newsData = [
      {
        'imageUrl': 'assets/images/blankimg.png',
        'title': 'Equipe de Futsal Vence o Campeonato!',
        'description':
            'Em uma partida emocionante, a equipe de futsal da Atlética X conquistou o título...',
      },
      {
        'imageUrl': 'assets/images/blankimg.png',
        'title': 'Início das Vendas de Ingressos do JUCO',
        'description':
            'Garanta já seu lugar no maior evento esportivo universitário da região! As vendas...',
      },
      {
        'imageUrl': 'assets/images/blankimg.png',
        'title': 'Nova Pista de Atletismo Inaugurada na UFMT',
        'description':
            'A nova pista de atletismo promete melhorar o desempenho dos atletas...',
      },
      {
        'imageUrl': 'assets/images/blankimg.png',
        'title': 'Torcida da Atlética Compila Fica em Primeiro Lugar',
        'description':
            'Com um apoio incondicional, a torcida da Atlética Compila demonstra sua força...',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notícias'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // O ícone de seta para voltar
          onPressed: () {
            // Usa o GoRouter para voltar para a página inicial
            context.go('/home');
          },
        ),
      ),
      body: ListView.builder(
        itemCount: newsData.length,
        itemBuilder: (context, index) {
          return Noticias(
            imageUrl: newsData[index]['imageUrl']!,
            title: newsData[index]['title']!,
            description: newsData[index]['description']!,
          );
        },
      ),
    );
  }
}
