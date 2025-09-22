// lib/features/users/classificacao_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interufmt/core/data/atletica_model.dart';
import 'package:interufmt/core/widgets/tabela_classificacao.dart';
import 'package:interufmt/features/users/home/home_page.dart';

class RatingPage extends StatelessWidget {
  static const String routename = 'classificacao';
  final String title;
  final List<Atletica> data; // Agora aceita uma lista de objetos Atletica

  const RatingPage({super.key, required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.goNamed(HomePage.routename);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: TabelaClassificacao(
          title: title,
          data:
              data, // Passa a lista de objetos Atletica para a TabelaClassificacao
        ),
      ),
    );
  }
}
