// lib/features/users/games/games_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:interufmt/core/theme/app_colors.dart';
import 'package:interufmt/core/theme/app_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/data/models/bracket_game_model.dart';
import '../../../core/data/repositories/bracket_games_repository.dart';

class GamesPage extends StatefulWidget {
  final String modalityId;
  final String modalityName;

  const GamesPage({
    super.key,
    required this.modalityId,
    required this.modalityName,
  });

  @override
  GamesPageState createState() => GamesPageState();
}

class GamesPageState extends State<GamesPage> with TickerProviderStateMixin {
  late TabController _seriesTabController;
  late TabController _serieAPhasesController;
  late TabController _serieBPhasesController;
  late BracketGamesRepository _repository;

  final Map<String, Map<String, List<BracketGame>>> _gamesData = {
    'A': {'Oitavas': [], 'Quartas': [], 'Semis': [], 'Final': []},
    'B': {'Oitavas': [], 'Quartas': [], 'Semis': [], 'Final': []},
  };

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _seriesTabController = TabController(length: 2, vsync: this);
    _serieAPhasesController = TabController(length: 4, vsync: this);
    _serieBPhasesController = TabController(length: 4, vsync: this);
    _repository = BracketGamesRepository(Supabase.instance.client);
    _loadAllGames();
  }

  Future<void> _loadAllGames() async {
    if (!mounted) return;
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Load games for both series
      final allGames = await _repository.getAllBracketGamesByModality(
        modalityId: widget.modalityId,
      );

      _gamesData['A'] = allGames['A'] ?? {};
      _gamesData['B'] = allGames['B'] ?? {};

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Erro ao carregar jogos: $error';
        });
      }
    }
  }

  @override
  void dispose() {
    _seriesTabController.dispose();
    _serieAPhasesController.dispose();
    _serieBPhasesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.modalityName,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _seriesTabController,
          tabs: const [
            Tab(text: 'Série A'),
            Tab(text: 'Série B'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState()
          : TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _seriesTabController,
              children: [
                _buildSeriesContent('A', _serieAPhasesController),
                _buildSeriesContent('B', _serieBPhasesController),
              ],
            ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAllGames,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildSeriesContent(String series, TabController phasesController) {
    return Column(
      children: [
        // Phases TabBar
        Container(
          color: Colors.grey.withValues(alpha: 0.1),
          child: TabBar(
            controller: phasesController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            indicatorSize: TabBarIndicatorSize.tab,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Oitavas'),
              Tab(text: 'Quartas'),
              Tab(text: 'Semis'),
              Tab(text: 'Final'),
            ],
          ),
        ),
        // Phases TabBarView
        Expanded(
          child: TabBarView(
            controller: phasesController,
            children: [
              _buildPhaseContent(series, 'Oitavas'),
              _buildPhaseContent(series, 'Quartas'),
              _buildPhaseContent(series, 'Semis'),
              _buildPhaseContent(series, 'Final'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhaseContent(String series, String phase) {
    final games = _gamesData[series]![phase] ?? [];

    if (games.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/ic_trophy.svg',
              width: 64,
              height: 64,
              colorFilter: ColorFilter.mode(
                Colors.grey.withValues(alpha: 0.5),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum jogo encontrado\npara $phase',
              style: TextStyle(
                color: Colors.grey.withValues(alpha: 0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllGames,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildGameCard(game),
          );
        },
      ),
    );
  }

  Widget _buildGameCard(BracketGame game) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: _getStatusColor(game.status), width: 6),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Phase, Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getPhaseColor(game.phase),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      game.phase,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        game.status,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      game.statusDisplayText,
                      style: TextStyle(
                        color: _getStatusColor(game.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Time and venue info
              _RowIconLabel(AppIcons.icClock, game.startTimeDateFormatted),

              if (game.venueName != null) ...[
                const SizedBox(height: 6),
                _RowIconLabel(AppIcons.icLocation, game.venueName!),
              ],

              const SizedBox(height: 16),

              // Teams and score
              if (game.hasTeams)
                _buildTeamsAndScore(game)
              else
                _buildNoTeamsContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamsAndScore(BracketGame game) {
    return Row(
      children: [
        // Team A
        Expanded(
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.withValues(alpha: 0.1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    game.teamALogoPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.shield, color: Colors.grey);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                game.teamAName ?? 'A definir',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Score
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${game.scoreA} X ${game.scoreB}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryText,
              ),
            ),
          ),
        ),

        // Team B
        Expanded(
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.withValues(alpha: 0.1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    game.teamBLogoPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.shield, color: Colors.grey);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                game.teamBName ?? 'A definir',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoTeamsContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.help_outline, color: Colors.grey),
          SizedBox(width: 8),
          Text('Times a serem definidos', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return AppColors.error;
      case 'inprogress':
      case 'in_progress':
        return AppColors.warning;
      case 'finished':
        return AppColors.success;
      default:
        return Colors.grey;
    }
  }

  Color _getPhaseColor(String phase) {
    switch (phase.toLowerCase()) {
      case 'final':
        return Colors.amber;
      case 'semifinal':
      case 'semis':
        return Colors.orange;
      case 'quartas':
        return Colors.blue;
      case 'oitavas':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class _RowIconLabel extends StatelessWidget {
  final String icon;
  final String label;
  const _RowIconLabel(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          icon,
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(
            AppColors.primaryText,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.primaryText, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
