import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:interufmt/core/widgets/card_game_widget.dart';
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

  // Competition dates for each series
  final Map<String, List<DateTime>> _competitionDates = {
    'A': [
      DateTime(2025, 10, 31), // October 31
      DateTime(2025, 11, 1), // November 1
      DateTime(2025, 11, 2), // November 2
    ],
    'B': [
      DateTime(2025, 11, 14), // November 14
      DateTime(2025, 11, 15), // November 15
      DateTime(2025, 11, 16), // November 16
    ],
  };

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
    if (!mounted) return;
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Load games for both series with their specific dates
      for (String series in ['A', 'B']) {
        final seriesDates = _competitionDates[series]!;
        for (int dayIndex = 0; dayIndex < seriesDates.length; dayIndex++) {
          final dayLabel = 'Dia ${dayIndex + 1}';
          final games = await _repository.getGamesBySeriesAndDate(
            series: series,
            date: seriesDates[dayIndex],
          );
          _gamesData[series]![dayLabel] = games;
        }
      }

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
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.black),
        //   onPressed: () => context.goNamed(HomePage.routename),
        // ),
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

  String _formatDateForTab(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  List<Tab> _getTabsForSeries(String series) {
    final dates = _competitionDates[series]!;
    return [
      Tab(text: 'Dia 1\n${_formatDateForTab(dates[0])}'),
      Tab(text: 'Dia 2\n${_formatDateForTab(dates[1])}'),
      Tab(text: 'Dia 3\n${_formatDateForTab(dates[2])}'),
    ];
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
            tabs: _getTabsForSeries(series),
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
            child: CardGame(
              status: game.status,
              startTimeDateFormatted: game.startTimeDateFormatted,
              statusDisplayText: game.statusDisplayText,
              gameIcon: game.gameIcon,
              modalityPhase: game.modalityPhase,
              venueName: game.venueName,
              gameId: game.gameId,
              modalityId: game.modalityId,
              series: game.series,
              isTwoTeamGame: game.isTwoTeamGame,
              isMultiTeamGame: game.isMultiTeamGame,
              multiTeamLogos: game.multiTeamLogos,
              teamALogo: game.teamALogo,
              teamBLogo: game.teamBLogo,
              scoreA: game.scoreA,
              scoreB: game.scoreB,
              displayScoreA: game.displayScoreA,
              displayScoreB: game.displayScoreB,
            ),
          );
        },
      ),
    );
  }
}
