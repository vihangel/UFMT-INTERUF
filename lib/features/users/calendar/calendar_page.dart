import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:interufmt/features/users/home/home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/data/models/calendar_game_model.dart';
import '../../../core/data/repositories/calendar_games_repository.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  CalendarPageState createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage>
    with TickerProviderStateMixin {
  late TabController _seriesTabController;
  late TabController _serieADaysController;
  late TabController _serieBDaysController;
  late CalendarGamesRepository _repository;

  // Competition dates (August 30, 31, September 1)
  final List<DateTime> _competitionDates = [
    DateTime(2025, 8, 30),
    DateTime(2025, 8, 31),
    DateTime(2025, 9, 1),
  ];

  final Map<String, Map<String, List<CalendarGame>>> _gamesData = {
    'A': {'Dia 1': [], 'Dia 2': [], 'Dia 3': []},
    'B': {'Dia 1': [], 'Dia 2': [], 'Dia 3': []},
  };

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _seriesTabController = TabController(length: 2, vsync: this);
    _serieADaysController = TabController(length: 3, vsync: this);
    _serieBDaysController = TabController(length: 3, vsync: this);
    _repository = CalendarGamesRepository(Supabase.instance.client);
    _loadAllGames();
  }

  Future<void> _loadAllGames() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Load games for both series
      for (String series in ['A', 'B']) {
        for (int dayIndex = 0;
            dayIndex < _competitionDates.length;
            dayIndex++) {
          final dayLabel = 'Dia ${dayIndex + 1}';
          final games = await _repository.getGamesBySeriesAndDate(
            series: series,
            date: _competitionDates[dayIndex],
          );
          _gamesData[series]![dayLabel] = games;
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar jogos: $error';
      });
    }
  }

  @override
  void dispose() {
    _seriesTabController.dispose();
    _serieADaysController.dispose();
    _serieBDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Calendário',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.goNamed(HomePage.routename),
        ),
        bottom: TabBar(
          controller: _seriesTabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
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
                  controller: _seriesTabController,
                  children: [
                    _buildSeriesContent('A', _serieADaysController),
                    _buildSeriesContent('B', _serieBDaysController),
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

  Widget _buildSeriesContent(String series, TabController daysController) {
    return Column(
      children: [
        // Days TabBar
        Container(
          color: Colors.grey.withValues(alpha: 0.1),
          child: TabBar(
            controller: daysController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: 'Dia 1\n30/08'),
              Tab(text: 'Dia 2\n31/08'),
              Tab(text: 'Dia 3\n01/09'),
            ],
          ),
        ),
        // Days TabBarView
        Expanded(
          child: TabBarView(
            controller: daysController,
            children: [
              _buildDayContent(series, 'Dia 1'),
              _buildDayContent(series, 'Dia 2'),
              _buildDayContent(series, 'Dia 3'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDayContent(String series, String day) {
    final games = _gamesData[series]![day] ?? [];

    if (games.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/ic_calendar.svg',
              width: 64,
              height: 64,
              colorFilter: ColorFilter.mode(
                Colors.grey.withValues(alpha: 0.5),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum jogo agendado\npara $day',
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

  Widget _buildGameCard(CalendarGame game) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Time, Status, Venue
            Row(
              children: [
                // Time
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${game.startAt.hour.toString().padLeft(2, '0')}:${game.startAt.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(game.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    game.statusDisplayText,
                    style: TextStyle(
                      color: _getStatusColor(game.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                // Venue
                if (game.venueName != null)
                  Row(
                    children: [
                      const Icon(Icons.place, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        game.venueName!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Modality Phase
            Text(
              game.modalityPhase,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            // Game Content: Two-team or Multi-team
            if (game.isTwoTeamGame)
              _buildTwoTeamGameContent(game)
            else if (game.isMultiTeamGame)
              _buildMultiTeamGameContent(game)
            else
              _buildUnknownGameContent(game),
          ],
        ),
      ),
    );
  }

  Widget _buildTwoTeamGameContent(CalendarGame game) {
    return Row(
      children: [
        // Team A
        Expanded(
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.withValues(alpha: 0.1),
                ),
                child: game.teamALogo != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/${game.teamALogo}',
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.shield, color: Colors.grey);
                          },
                        ),
                      )
                    : const Icon(Icons.shield, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                '${game.displayScoreA}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // VS
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'VS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        // Team B
        Expanded(
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.withValues(alpha: 0.1),
                ),
                child: game.teamBLogo != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/${game.teamBLogo}',
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.shield, color: Colors.grey);
                          },
                        ),
                      )
                    : const Icon(Icons.shield, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                '${game.displayScoreB}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMultiTeamGameContent(CalendarGame game) {
    final logos = game.multiTeamLogos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Participantes:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: logos.map((logo) {
            return Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withValues(alpha: 0.1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/$logo',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.shield,
                      color: Colors.grey,
                      size: 16,
                    );
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildUnknownGameContent(CalendarGame game) {
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
          Text(
            'Informações dos participantes não disponíveis',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.blue;
      case 'inprogress':
      case 'in_progress':
        return Colors.orange;
      case 'finished':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
