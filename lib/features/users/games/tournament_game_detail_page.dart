import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:interufmt/core/theme/app_colors.dart';
import 'package:interufmt/core/theme/app_icons.dart';
import 'package:interufmt/core/widgets/row_2team_stats_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/data/models/tournament_game_detail_model.dart';
import '../../../core/data/repositories/tournament_game_detail_repository.dart';
import '../athletes/athlete_detail_page.dart';

class TournamentGameDetailPage extends StatefulWidget {
  final String gameId;

  const TournamentGameDetailPage({super.key, required this.gameId});

  @override
  TournamentGameDetailPageState createState() =>
      TournamentGameDetailPageState();
}

class TournamentGameDetailPageState extends State<TournamentGameDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TournamentGameDetailRepository _repository;

  TournamentGameDetail? _gameDetail;
  List<GameStatistic> _statistics = [];
  Map<String, List<GameAthlete>> _athletes = {'teamA': [], 'teamB': []};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _repository = TournamentGameDetailRepository(Supabase.instance.client);
    _loadGameDetail();
  }

  Future<void> _loadGameDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Load game detail, statistics, and athletes
      final futures = await Future.wait([
        _repository.getTournamentGameDetail(widget.gameId),
        _repository.getGameStatistics(widget.gameId),
        _repository.getGameAthletes(widget.gameId),
      ]);

      setState(() {
        _gameDetail = futures[0] as TournamentGameDetail?;
        _statistics = futures[1] as List<GameStatistic>;
        _athletes = futures[2] as Map<String, List<GameAthlete>>;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar detalhes do jogo: $error';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _gameDetail?.modality ?? 'Detalhes do Jogo',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState()
          : _gameDetail == null
          ? const Center(child: Text('Jogo não encontrado'))
          : _buildGameContent(),
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
            onPressed: _loadGameDetail,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent() {
    if (_gameDetail == null) return const SizedBox.shrink();

    return Column(
      children: [
        _buildGameHeader(),
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Estatísticas'),
              Tab(text: 'Atletas'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildStatisticsTab(), _buildAthletesTab()],
          ),
        ),
      ],
    );
  }

  Widget _buildGameHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Modality and Phase
          Text(
            _gameDetail!.modality,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getPhaseColor(_gameDetail!.phase),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _gameDetail!.phase,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Teams and Score
          Row2teamStatsWidget(
            teamALogo: _gameDetail!.teamALogo,
            teamBLogo: _gameDetail!.teamBLogo,
            scoreA: _gameDetail!.scoreA,
            scoreB: _gameDetail!.scoreB,
            displayScoreA: _gameDetail!.scoreA,
            displayScoreB: _gameDetail!.scoreB,
            extraTextScore: _gameDetail!.statusDisplayText,
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGameInfo(),
          const SizedBox(height: 24),
          _buildStatistics(),
        ],
      ),
    );
  }

  Widget _buildGameInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informações do Jogo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            AppIcons.icTrophy,
            'Status',
            _gameDetail!.statusDisplayText,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            AppIcons.icCalendar,
            'Data',
            _gameDetail!.formattedDate,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            AppIcons.icClock,
            'Horário',
            _gameDetail!.formattedTime,
          ),
          if (_gameDetail!.venueName != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              AppIcons.icLocation,
              'Local',
              _gameDetail!.venueName!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String icon, String label, String value) {
    return Row(
      children: [
        SvgPicture.asset(
          icon,
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(
            AppColors.primary,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: AppColors.primaryText),
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    if (_statistics.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.bar_chart,
              size: 48,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Estatísticas não disponíveis',
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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estatísticas do Jogo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          ..._statistics.asMap().entries.map((entry) {
            final index = entry.key;
            final stat = entry.value;
            final isLast = index == _statistics.length - 1;

            return Column(
              children: [
                _buildStatisticRow(stat),
                if (!isLast) const Divider(height: 24),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatisticRow(GameStatistic stat) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            stat.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
        ),
        Expanded(
          child: Text(
            '${stat.teamAValue}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            '${stat.teamBValue}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildAthletesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTeamAthletes(_gameDetail!.teamAName, _athletes['teamA']!),
          const SizedBox(height: 24),
          _buildTeamAthletes(_gameDetail!.teamBName, _athletes['teamB']!),
        ],
      ),
    );
  }

  Widget _buildTeamAthletes(String teamName, List<GameAthlete> athletes) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Text(
                  teamName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          if (athletes.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Nenhum atleta encontrado',
                  style: TextStyle(
                    color: Colors.grey.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: athletes.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final athlete = athletes[index];
                return _buildAthleteRow(athlete);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAthleteRow(GameAthlete athlete) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AthleteDetailPage(
              athleteId: athlete.athleteId,
              gameId: widget.gameId,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${athlete.shirtNumber}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                athlete.fullName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.secondaryText,
            ),
          ],
        ),
      ),
    );
  }

  Color _getPhaseColor(String phase) {
    switch (phase.toLowerCase()) {
      case 'final':
        return Colors.amber;
      case 'semifinal':
        return Colors.orange;
      case 'quartas de final':
        return Colors.blue;
      case 'oitavas de final':
        return Colors.green;
      default:
        return AppColors.primary;
    }
  }
}
