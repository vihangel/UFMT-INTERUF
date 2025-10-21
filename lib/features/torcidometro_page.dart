// lib/features/users/torcidometro_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interufmt/core/data/atletica_model.dart';
import 'package:interufmt/features/users/home/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/data/repositories/torcidometro_repository.dart';
import '../core/services/voting_service.dart';
import '../core/data/services/auth_service.dart';
import 'escolha_atletica_page.dart';

// Mapeamento de cores final para todas as atléticas (usado para as barras)
const Map<String, Color> ATLETICA_COLORS = {
  'Trojan': Color(0xFF1E3A8A),
  'Pintada': Color(0xFFFF5722),
  'Guara': Color(0xFFD32F2F),
  'Hydra': Color(0xFF00796B),
  'Macabra': Color(0xFF22543D),
  'GatoPreto': Color(0xFFB71C1C),
  'Admafia': Color(0xFF1976D2),
  'Ampere': Color(0xFFFBC02D),
  'Arcaica': Color(0xFFF9A825),
  'Armada': Color(0xFFD32F2F),
  'Atena': Color(0xFF673AB7),
  'Atomica': Color(0xFFFFD600),
  'Baroes': Color(0xFFC62828),
  'Bufalos': Color(0xFFD50000),
  'Caiman': Color(0xFF558B2F),
  'Caotica': Color(0xFFE65100),
  'Compila': Color(0xFF0D47A1),
  'Deltas': Color(0xFF1A237E),
  'Detona': Color(0xFFFF8F00),
  'Devora': Color(0xFFF4511E),
  'Enfuria': Color(0xFF00BCD4),
  'Infernal': Color(0xFF880E4F),
  'Monopolio': Color(0xFF000000),
  'Quantica': Color(0xFFB3E5FC),
  'Rustica': Color(0xFF0D47A1),
  'Tempesta': Color(0xFF1565C0),
  'Tormenta': Color(0xFFD50000),
  'Turbulenta': Color(0xFF0D47A1),
  'Sumauma': Color(0xFF558B2F),
  'Rochedo': Color(0xFFFF9800),
  'Transtorna': Color(0xFFFF9800),
  'Metralha': Color(0xFF424242),
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
  late TorcidometroRepository _repository;
  late VotingService _votingService;
  late AuthService _authService;

  List<Atletica> _serieA = [];
  List<Atletica> _serieB = [];

  bool _isLoadingA = true;
  bool _isLoadingB = true;
  String? _errorMessageA;
  String? _errorMessageB;

  double _maxPointsA = 1.0;
  double _maxPointsB = 1.0;

  // User vote info
  String? _userVotedAthleticId;
  Map<String, dynamic>? _userVotedAthletic;
  bool _isLoadingUserVote = true;

  // Função auxiliar para gerar o caminho do asset
  String _getAtleticAssetPath(String logo) {
    return 'assets/images/$logo';
  }

  // Função auxiliar para obter a cor da atlética
  Color _getAtleticaColor(String nome) {
    return ATLETICA_COLORS[nome] ?? Colors.grey[400]!;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _repository = TorcidometroRepository(Supabase.instance.client);
    _votingService = VotingService(Supabase.instance.client);
    _authService = AuthService(Supabase.instance.client);
    _loadRankings();
    _loadUserVote();
  }

  Future<void> _loadRankings() async {
    // Load Serie A
    _loadSerieA();
    // Load Serie B
    _loadSerieB();
  }

  Future<void> _loadUserVote() async {
    setState(() {
      _isLoadingUserVote = true;
    });

    try {
      if (_authService.isAuthenticated) {
        final votedAthleticId = await _votingService.getAuthenticatedUserVote();

        if (votedAthleticId != null) {
          // Fetch athletic details
          final response = await Supabase.instance.client
              .from('athletics')
              .select('id, nickname, name, logo_url, series')
              .eq('id', votedAthleticId)
              .single();

          setState(() {
            _userVotedAthleticId = votedAthleticId;
            _userVotedAthletic = response;
          });
        }
      }
    } catch (error) {
      print('Error loading user vote: $error');
    } finally {
      setState(() {
        _isLoadingUserVote = false;
      });
    }
  }

  Future<void> _loadSerieA() async {
    try {
      setState(() {
        _isLoadingA = true;
        _errorMessageA = null;
      });

      final rankings = await _repository.getRankingBySeries('A');

      setState(() {
        _serieA = rankings;
        _maxPointsA = _serieA.isNotEmpty
            ? _serieA.first.pontos.toDouble()
            : 1.0;
        _isLoadingA = false;
      });
    } catch (error) {
      setState(() {
        _isLoadingA = false;
        _errorMessageA = 'Erro ao carregar ranking da Série A: $error';
      });
    }
  }

  Future<void> _loadSerieB() async {
    try {
      setState(() {
        _isLoadingB = true;
        _errorMessageB = null;
      });

      final rankings = await _repository.getRankingBySeries('B');

      setState(() {
        _serieB = rankings;
        _maxPointsB = _serieB.isNotEmpty
            ? _serieB.first.pontos.toDouble()
            : 1.0;
        _isLoadingB = false;
      });
    } catch (error) {
      setState(() {
        _isLoadingB = false;
        _errorMessageB = 'Erro ao carregar ranking da Série B: $error';
      });
    }
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
            context.goNamed(HomePage.routename);
          },
        ),
      ),
      body: Column(
        children: [
          // User Vote Card (above tabs)
          _buildUserVoteCard(),

          // Tabs
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Série A'),
              Tab(text: 'Série B'),
            ],
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRankingTabWithLoading(
                  _serieA,
                  _maxPointsA,
                  'Série A',
                  _isLoadingA,
                  _errorMessageA,
                  _loadSerieA,
                ),
                _buildRankingTabWithLoading(
                  _serieB,
                  _maxPointsB,
                  'Série B',
                  _isLoadingB,
                  _errorMessageB,
                  _loadSerieB,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserVoteCard() {
    if (_isLoadingUserVote) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    // User is not authenticated
    if (!_authService.isAuthenticated) {
      return Container(
        margin: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          child: InkWell(
            onTap: () {
              // Navigate to escolha atletica page to login and vote
              context.pushNamed(EscolhaAtleticaPage.routename);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.how_to_vote,
                    size: 40,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Faça login para votar',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Escolha sua atlética e ajude no torcidômetro!',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // User is authenticated but hasn't voted
    if (_userVotedAthletic == null) {
      return Container(
        margin: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          child: InkWell(
            onTap: () {
              // Navigate to escolha atletica page to vote
              context.pushNamed(EscolhaAtleticaPage.routename);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.how_to_vote_outlined,
                    size: 40,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Você ainda não votou',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Escolha sua atlética favorita!',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // User has voted - show their vote
    final athletic = _userVotedAthletic!;
    final athleticName = athletic['nickname'] as String;
    final logoUrl = athletic['logo_url'] as String?;
    final series = athletic['series'] as String;
    final atleticaColor = _getAtleticaColor(athleticName);

    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 3,
        color: Colors.grey[100],
        child: InkWell(
          onTap: () async {
            // Show dialog to confirm vote change
            final shouldChange = await _showChangeVoteDialog(athleticName);
            if (shouldChange == true && mounted) {
              context.pushNamed(EscolhaAtleticaPage.routename);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Athletic Logo
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: logoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            _getAtleticAssetPath(logoUrl),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.sports,
                                size: 30,
                                color: atleticaColor,
                              );
                            },
                          ),
                        )
                      : Icon(Icons.sports, size: 30, color: atleticaColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Seu voto',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        athleticName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: atleticaColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Série $series',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Icon(Icons.swap_horiz, color: Colors.grey[600], size: 24),
                    const SizedBox(height: 4),
                    Text(
                      'Trocar',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showChangeVoteDialog(String currentAthleticName) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Trocar voto?'),
          content: Text(
            'Você está votando atualmente em $currentAthleticName.\n\n'
            'Deseja trocar seu voto?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            ElevatedButton(
              child: const Text('Trocar voto'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildRankingTabWithLoading(
    List<Atletica> ranking,
    double maxPoints,
    String seriesTitle,
    bool isLoading,
    String? errorMessage,
    VoidCallback onRetry,
  ) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

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
                _getAtleticAssetPath(atletica.logo ?? ''),
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
                    _getAtleticAssetPath(atletica.logo ?? ''),
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
