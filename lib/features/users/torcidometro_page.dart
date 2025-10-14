// lib/features/users/torcidometro_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interufmt/core/data/atletica_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:interufmt/features/users/athletics/athletics_page.dart';

// Mapeamento de cores final para todas as atléticas (usado para as barras)
const Map<String, Color> ATLETICA_COLORS = {
  'Trojan': Color(0xFF1E3A8A),
  'Pintada': Color(0xFFFF5722),
  'Guará': Color(0xFFD32F2F),
  'Turuna': Color(0xFFDC2626),
  'Hydra': Color(0xFF00796B),
  'Macabra': Color(0xFF22543D),
  'Gato Preto': Color(0xFFB71C1C),
  'Admafia': Color(0xFF1976D2),
  'Ampère': Color(0xFFFBC02D),
  'Arcaica': Color(0xFFF9A825),
  'Armada': Color(0xFFD32F2F),
  'Atena': Color(0xFF673AB7),
  'Atômica': Color(0xFFFFD600),
  'Barões': Color(0xFFC62828),
  'Búfalos': Color(0xFFD50000),
  'Caiman': Color(0xFF558B2F),
  'Caótica': Color(0xFFE65100),
  'Compila': Color(0xFF0D47A1),
  'Deltas': Color(0xFF1A237E),
  'Detona': Color(0xFFFF8F00),
  'Devora': Color(0xFFF4511E),
  'Enfúria': Color(0xFF00BCD4),
  'Infernal': Color(0xFF880E4F),
  'Monopólio': Color(0xFF000000),
  'Quântica': Color(0xFFB3E5FC),
  'Rústica': Color(0xFF0D47A1),
  'Tempesta': Color(0xFF1565C0),
  'Tormenta': Color(0xFFD50000),
  'Turbulenta': Color(0xFF0D47A1),
  'Sumaúma': Color(0xFF558B2F),
  'Rochedo': Color(0xFFFF9800),
  'Transtorna': Color(0xFFFF9800),
};

class TorcidometroPage extends StatefulWidget {
  static const String routename = 'torcidometro';

  const TorcidometroPage({super.key});

  @override
  State<TorcidometroPage> createState() => _TorcidometroPageState();
}

class _TorcidometroPageState extends State<TorcidometroPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dados simulados com o Model Atletica
  final List<Atletica> _serieA = [
    const Atletica(
      posicao: 1,
      nome: 'Trojan',
      ouro: 0,
      prata: 0,
      bronze: 0,
      pontos: 241,
    ),
    const Atletica(
      posicao: 2,
      nome: 'Pintada',
      ouro: 0,
      prata: 0,
      bronze: 0,
      pontos: 192,
    ),
    const Atletica(
      posicao: 3,
      nome: 'Guará',
      ouro: 0,
      prata: 0,
      bronze: 0,
      pontos: 140,
    ),
    const Atletica(
      posicao: 4,
      nome: 'Turuna',
      ouro: 0,
      prata: 0,
      bronze: 0,
      pontos: 112,
    ),
    const Atletica(
      posicao: 5,
      nome: 'Hydra',
      ouro: 0,
      prata: 0,
      bronze: 0,
      pontos: 87,
    ),
    const Atletica(
      posicao: 6,
      nome: 'Macabra',
      ouro: 0,
      prata: 0,
      bronze: 0,
      pontos: 68,
    ),
    const Atletica(
      posicao: 7,
      nome: 'Gato Preto',
      ouro: 0,
      prata: 0,
      bronze: 0,
      pontos: 62,
    ),
    const Atletica(
      posicao: 8,
      nome: 'Admafia',
      ouro: 0,
      prata: 0,
      bronze: 0,
      pontos: 41,
    ),
  ];

  final List<Atletica> _serieB = [
    const Atletica(
      posicao: 1,
      nome: 'Macabra',
      ouro: 0,
      prata: 0,
      bronze: 0,
      pontos: 310,
    ),
    const Atletica(
      posicao: 2,
      nome: 'Gato Preto',
      ouro: 0,
      prata: 0,
      bronze: 0,
      pontos: 280,
    ),
    const Atletica(
      posicao: 3,
      nome: 'Admafia',
      ouro: 0,
      prata: 0,
      bronze: 0,
      pontos: 150,
    ),
    const Atletica(
      posicao: 4,
      nome: 'Caótica',
      ouro: 0,
      prata: 0,
      bronze: 0,
      pontos: 90,
    ),
  ];

  late double _maxPointsA;
  late double _maxPointsB;

  // Função auxiliar para gerar o caminho do asset
  String _getAtleticAssetPath(String nome) {
    return 'assets/images/Atlética $nome.png';
  }

  // Função auxiliar para obter a cor da atlética
  Color _getAtleticaColor(String nome) {
    return ATLETICA_COLORS[nome] ?? Colors.grey[400]!;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Ordena e calcula a pontuação máxima
    _serieA.sort((a, b) => b.pontos.compareTo(a.pontos));
    _serieB.sort((a, b) => b.pontos.compareTo(a.pontos));
    _maxPointsA = _serieA.isNotEmpty ? _serieA.first.pontos.toDouble() : 1.0;
    _maxPointsB = _serieB.isNotEmpty ? _serieB.first.pontos.toDouble() : 1.0;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Torcidômetro'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.goNamed(AthleticsPage.routename);
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Série A'),
            Tab(text: 'Série B'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRankingTab(_serieA, _maxPointsA, 'Série A'),
          _buildRankingTab(_serieB, _maxPointsB, 'Série B'),
        ],
      ),
    );
  }

  Widget _buildRankingTab(
    List<Atletica> ranking,
    double maxPoints,
    String seriesTitle,
  ) {
    if (ranking.isEmpty) {
      return const Center(
        child: Text('Nenhuma atlética encontrada nesta série.'),
      );
    }

    final Atletica topAtletica = ranking.first;
    final List<Atletica> restOfRanking = ranking.skip(1).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          // 1. Destaque Top 1
          _buildTopRankCard(topAtletica),

          // 2. Ranking de Barras
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildBarRankingList(restOfRanking, maxPoints),
          ),
        ],
      ),
    );
  }

  Widget _buildTopRankCard(Atletica atletica) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '#1',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.amber[800],
              ),
            ),
            const SizedBox(height: 10),
            // Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.asset(
                _getAtleticAssetPath(atletica.nome),
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.sports_soccer, size: 100),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              atletica.nome,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              '${atletica.pontos} Pontos',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarRankingList(List<Atletica> list, double maxPoints) {
    return Column(
      children: list.asMap().entries.map((entry) {
        final Atletica atletica = entry.value;
        final double ratio = atletica.pontos / maxPoints;
        final Color atleticaColor = _getAtleticaColor(atletica.nome);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Ícone de Bola (Substituído pela logo da atlética no seu último pedido)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: ClipOval(
                  child: Image.asset(
                    _getAtleticAssetPath(atletica.nome),
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Usando o ícone de futebol como fallback visual
                      return const Icon(Icons.sports_soccer, size: 24);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // 2. Barra de Progresso e Pontuação
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // Barra de Fundo
                      Container(height: 30, color: Colors.grey[200]),
                      // Barra de Progresso
                      Container(
                        height: 30,
                        // Ajusta a largura para ser relativa à tela, mas com um limite visual (75%)
                        width: MediaQuery.of(context).size.width * ratio * 0.75,
                        color: atleticaColor, // Cor dinâmica
                      ),
                      // Texto da Pontuação
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${atletica.pontos}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        );
      }).toList(),
    );
  }
}
