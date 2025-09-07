// lib/core/data/atletica_model.dart

class Atletica {
  final int posicao;
  final String nome;
  final int ouro;
  final int prata;
  final int bronze;
  final int pontos;

  const Atletica({
    required this.posicao,
    required this.nome,
    required this.ouro,
    required this.prata,
    required this.bronze,
    required this.pontos,
  });

  Map<String, dynamic> toMap() {
    return {
      'posicao': posicao,
      'nome': nome,
      'ouro': ouro,
      'prata': prata,
      'bronze': bronze,
      'pontos': pontos,
    };
  }

  // Adicionado o método fromJson
  factory Atletica.fromJson(Map<String, dynamic> json) {
    return Atletica(
      posicao: json['posicao'] as int,
      nome: json['nome'] as String,
      ouro: json['ouro'] as int,
      prata: json['prata'] as int,
      bronze: json['bronze'] as int,
      pontos: json['pontos'] as int,
    );
  }
}
