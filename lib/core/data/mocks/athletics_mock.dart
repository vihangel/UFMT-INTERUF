import 'package:interufmt/core/data/atletica_model.dart';

/// Fallback method with mock data based on the user's example
List<Atletica> getMockDataForSeries(String series) {
  if (series == 'A') {
    // Data from user's example result
    return [
      const Atletica(
        posicao: 1,
        nome: 'Gato Preto',
        ouro: 1,
        prata: 0,
        bronze: 0,
        pontos: 100,
      ),
      const Atletica(
        posicao: 2,
        nome: 'Macabra',
        ouro: 0,
        prata: 2,
        bronze: 0,
        pontos: 70,
      ),
      const Atletica(
        posicao: 3,
        nome: 'Trojan',
        ouro: 1,
        prata: 0,
        bronze: 0,
        pontos: 60,
      ),
      const Atletica(
        posicao: 4,
        nome: 'Rustica',
        ouro: 0,
        prata: 0,
        bronze: 2,
        pontos: 30,
      ),
    ];
  } else {
    // Mock data for series B (fallback data)
    return [
      const Atletica(
        posicao: 1,
        nome: 'Admafia',
        ouro: 2,
        prata: 1,
        bronze: 0,
        pontos: 250,
      ),
      const Atletica(
        posicao: 2,
        nome: 'Metralha',
        ouro: 1,
        prata: 2,
        bronze: 1,
        pontos: 170,
      ),
      const Atletica(
        posicao: 3,
        nome: 'Pintada',
        ouro: 0,
        prata: 1,
        bronze: 3,
        pontos: 110,
      ),
      const Atletica(
        posicao: 4,
        nome: 'Outra B',
        ouro: 0,
        prata: 0,
        bronze: 1,
        pontos: 20,
      ),
      const Atletica(
        posicao: 5,
        nome: 'Mais B',
        ouro: 0,
        prata: 0,
        bronze: 0,
        pontos: 0,
      ),
      const Atletica(
        posicao: 6,
        nome: 'Uma B',
        ouro: 0,
        prata: 0,
        bronze: 0,
        pontos: 0,
      ),
    ];
  }
}

/// Converts the raw query result to a list of Atletica objects with positions
List<Atletica> convertToAtleticaList(List<dynamic> queryResult) {
  final List<Atletica> atleticas = [];

  for (int i = 0; i < queryResult.length; i++) {
    final row = queryResult[i] as Map<String, dynamic>;

    atleticas.add(
      Atletica(
        posicao: i + 1, // Position based on order from query (1-indexed)
        nome: row['name'] as String,
        ouro: int.tryParse(row['gold_medals'].toString()) ?? 0,
        prata: int.tryParse(row['silver_medals'].toString()) ?? 0,
        bronze: int.tryParse(row['bronze_medals'].toString()) ?? 0,
        pontos: int.tryParse(row['points'].toString()) ?? 0,
      ),
    );
  }

  return atleticas;
}
