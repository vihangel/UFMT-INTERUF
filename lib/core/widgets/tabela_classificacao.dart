// lib/core/widgets/tabela_classificacao.dart

import 'package:flutter/material.dart';
import 'package:interufmt/core/data/atletica_model.dart';

class TabelaClassificacao extends StatelessWidget {
  final String title;
  final List<Atletica> data;

  const TabelaClassificacao({
    super.key,
    required this.title,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(4),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1),
                5: FlexColumnWidth(2),
              },
              children: [
                // Cabeçalho da tabela
                const TableRow(
                  children: [
                    Text('#', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      'Atlética',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // Ícones de medalha (ou outros ícones)
                    Icon(Icons.emoji_events, size: 16),
                    Icon(Icons.emoji_events, size: 16),
                    Icon(Icons.emoji_events, size: 16),
                    Text(
                      'Pontos',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                // Linhas da tabela (dados das atléticas)
                ...data.map((atletica) {
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(atletica.posicao.toString()),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(atletica.nome),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(atletica.ouro.toString()),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(atletica.prata.toString()),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(atletica.bronze.toString()),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(atletica.pontos.toString()),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
