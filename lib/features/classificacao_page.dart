// lib/features/users/classificacao_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interufmt/core/widgets/tabela_classificacao.dart';

class ClassificacaoPage extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> data;

  const ClassificacaoPage({super.key, required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // O ícone de seta
          onPressed: () {
            // Usa o GoRouter para voltar para a página inicial
            context.go('/home');
          },
        ),
      ),
      body: SingleChildScrollView(
        child: TabelaClassificacao(title: title, data: data),
      ),
    );
  }
}
