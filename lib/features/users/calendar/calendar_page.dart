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
  late CalendarGamesRepository _repository;

  // Dynamic dates loaded from database
  final Map<String, List<DateTime>> _availableDates = {'A': [], 'B': []};

  // Selected date for each series
  DateTime? _selectedDateA;
  DateTime? _selectedDateB;

  final Map<String, List<CalendarGame>> _currentGames = {'A': [], 'B': []};

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _seriesTabController = TabController(length: 2, vsync: this);
    _repository = CalendarGamesRepository(Supabase.instance.client);
    _loadAvailableDates();
  }

  Future<void> _loadAvailableDates() async {
    if (!mounted) return;
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Load available dates for both series
      final datesA = await _repository.getDistinctDatesForSeries('A');
      final datesB = await _repository.getDistinctDatesForSeries('B');

      if (mounted) {
        setState(() {
          _availableDates['A'] = datesA;
          _availableDates['B'] = datesB;

          // Set initial selected dates
          if (datesA.isNotEmpty) {
            _selectedDateA = datesA.first;
          }
          if (datesB.isNotEmpty) {
            _selectedDateB = datesB.first;
          }

          _isLoading = false;
        });

        // Load games for initial dates
        if (_selectedDateA != null) {
          await _loadGamesForDate('A', _selectedDateA!);
        }
        if (_selectedDateB != null) {
          await _loadGamesForDate('B', _selectedDateB!);
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Erro ao carregar datas disponíveis: $error';
        });
      }
    }
  }

  Future<void> _loadGamesForDate(String series, DateTime date) async {
    if (!mounted) return;
    try {
      final games = await _repository.getGamesBySeriesAndDate(
        series: series,
        date: date,
      );

      if (mounted) {
        setState(() {
          _currentGames[series] = games;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao carregar jogos: $error';
        });
      }
    }
  }

  @override
  void dispose() {
    _seriesTabController.dispose();
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
              children: [_buildSeriesContent('A'), _buildSeriesContent('B')],
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
            onPressed: _loadAvailableDates,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  String _formatDateForDropdown(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildSeriesContent(String series) {
    final availableDates = _availableDates[series]!;
    final selectedDate = series == 'A' ? _selectedDateA : _selectedDateB;
    final games = _currentGames[series]!;

    if (availableDates.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma data disponível para esta série',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        // Date Dropdown Filter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.grey.withValues(alpha: 0.1),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<DateTime>(
                  value: selectedDate,
                  decoration: const InputDecoration(
                    labelText: 'Selecione a data',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: availableDates.map((date) {
                    return DropdownMenuItem<DateTime>(
                      value: date,
                      child: Text(_formatDateForDropdown(date)),
                    );
                  }).toList(),
                  onChanged: (DateTime? newDate) {
                    if (newDate != null) {
                      setState(() {
                        if (series == 'A') {
                          _selectedDateA = newDate;
                        } else {
                          _selectedDateB = newDate;
                        }
                      });
                      _loadGamesForDate(series, newDate);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        // Games List
        Expanded(child: _buildGamesList(games)),
      ],
    );
  }

  Widget _buildGamesList(List<CalendarGame> games) {
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
              'Nenhum jogo agendado\npara esta data',
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
      onRefresh: () async {
        final series = _seriesTabController.index == 0 ? 'A' : 'B';
        final selectedDate = series == 'A' ? _selectedDateA : _selectedDateB;
        if (selectedDate != null) {
          await _loadGamesForDate(series, selectedDate);
        }
      },
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
