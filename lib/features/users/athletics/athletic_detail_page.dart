// lib/features/users/athletics/athletic_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:interufmt/core/theme/app_colors.dart';
import 'package:interufmt/core/widgets/card_game_widget.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/data/athletics_item_model.dart';
import '../../../core/data/models/athletic_detail_model.dart';
import '../../../core/data/models/athletic_game_model.dart';
import '../../../core/data/models/modality_with_status_model.dart';
import '../../../core/data/repositories/athletic_detail_repository.dart';
import '../games/game_detail_page.dart';
import '../games/games_page.dart';
import '../games/tournament_game_detail_page.dart';

import 'package:interufmt/features/torcidometro_page.dart';

class AthleticDetailPage extends StatefulWidget {
  final AthleticsItem athletic;

  const AthleticDetailPage({super.key, required this.athletic});

  @override
  AthleticDetailPageState createState() => AthleticDetailPageState();
}

class AthleticDetailPageState extends State<AthleticDetailPage>
    with TickerProviderStateMixin {
  late TabController _mainTabController;
  late AthleticDetailRepository _repository;

  AthleticDetail? _athleticDetail;
  List<ModalityAggregated> _modalities = [];
  List<DateTime> _availableDates = [];
  DateTime? _selectedDate;
  List<AthleticGame> _currentGames = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
    _repository = AthleticDetailRepository(Supabase.instance.client);
    _loadAthleticDetail();
  }

  Future<void> _loadAthleticDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Load athletic detail
      final detail = await _repository.getAthleticDetail(widget.athletic.id);

      if (detail != null) {
        _athleticDetail = detail;

        // Get available dates from database
        _availableDates = await _repository.getDistinctDatesForAthletic(
          widget.athletic.id,
        );

        // Set initial selected date
        if (_availableDates.isNotEmpty) {
          _selectedDate = _availableDates.first;

          // Load games for initial date
          await _loadGamesForDate(_selectedDate!);
        }

        // Load modalities
        _modalities = await _repository.getAthleticModalities(
          widget.athletic.id,
        );
      }

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar detalhes da atlética: $error';
      });
    }
  }

  Future<void> _loadGamesForDate(DateTime date) async {
    if (!mounted) return;
    try {
      final dateString = date.toIso8601String().split('T')[0];
      final games = await _repository.getAthleticGames(
        widget.athletic.id,
        dateString,
      );

      if (mounted) {
        setState(() {
          _currentGames = games;
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
    _mainTabController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatGameTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.athletic.nickname,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.bar_chart,
              color: Colors.black,
            ), // Ícone de barras
            onPressed: () {
              context.goNamed(TorcidometroPage.routename);
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: _athleticDetail != null
            ? TabBar(
                controller: _mainTabController,
                tabs: const [
                  Tab(text: 'Calendário'),
                  Tab(text: 'Modalidades'),
                ],
              )
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState()
          : _athleticDetail == null
          ? const Center(child: Text('Atlética não encontrada'))
          : Column(
              children: [
                _buildAthleticHeader(),
                Expanded(
                  child: TabBarView(
                    controller: _mainTabController,
                    children: [_buildCalendarTab(), _buildModalitiesTab()],
                  ),
                ),
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
            onPressed: _loadAthleticDetail,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildAthleticHeader() {
    if (_athleticDetail == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        children: [
          // Athletic Logo
          ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: Container(
              height: 120,
              width: 120,
              color: AppColors.background,
              child: Image.asset(
                'assets/${_athleticDetail!.assetPath}',
                height: 120,
                width: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: const Icon(
                      Icons.sports,
                      size: 60,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Athletic Nickname
          Text(
            _athleticDetail!.nickname,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Athletic Name
          Text(
            _athleticDetail!.name,
            style: TextStyle(fontSize: 16, color: AppColors.secondaryText),
            textAlign: TextAlign.center,
          ),
          if (_athleticDetail!.description != null) ...[
            const SizedBox(height: 12),
            Text(
              _athleticDetail!.description!,
              style: TextStyle(fontSize: 14, color: AppColors.secondaryText),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCalendarTab() {
    if (_availableDates.isEmpty) {
      return const Center(child: Text('Nenhuma data disponível'));
    }

    return Column(
      children: [
        // Date Dropdown Filter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<DateTime>(
                  value: _selectedDate,
                  decoration: const InputDecoration(
                    labelText: 'Selecione a data',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: _availableDates.map((date) {
                    return DropdownMenuItem<DateTime>(
                      value: date,
                      child: Text(_formatDate(date)),
                    );
                  }).toList(),
                  onChanged: (DateTime? newDate) {
                    if (newDate != null) {
                      setState(() {
                        _selectedDate = newDate;
                      });
                      _loadGamesForDate(newDate);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        // Games List
        Expanded(child: _buildGamesForDate()),
      ],
    );
  }

  Widget _buildGamesForDate() {
    final games = _currentGames;

    if (games.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum jogo nesta data',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: games.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: CardGame(
          status: games[index].status,
          startTimeDateFormatted: games[index].startTimeDateFormatted,
          gameIcon: games[index].gameIcon,
          modalityPhase: games[index].modalityPhase,
          venueName: games[index].venueName,
          gameId: games[index].gameId,
          modalityId: games[index].modalityId ?? '',
          series: games[index].series ?? '',
          isTwoTeamGame: games[index].isTwoTeamGame,
          isMultiTeamGame: games[index].isMultiTeamGame,
          multiTeamLogos: games[index].multiTeamLogos,
          teamALogo: games[index].teamALogo,
          teamBLogo: games[index].teamBLogo,
          scoreA: games[index].scoreA,
          scoreB: games[index].scoreB,
          displayScoreA: games[index].scoreA,
          displayScoreB: games[index].scoreB,
          extraTextScore: games[index].statusDisplayText,
          onTap: () {
            if (games[index].isTwoTeamGame) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TournamentGameDetailPage(gameId: games[index].gameId),
                ),
              );
            } else if (games[index].isMultiTeamGame) {
              final modalityName = games[index].modalityPhase
                  .split(' - ')
                  .first;

              final modality = _modalities.firstWhere(
                (m) => games[index].modalityPhase.contains(m.name),
                orElse: () => _modalities.first,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameDetailPage(
                    modalityId: modality.id,
                    modalityName: modalityName,
                    series: modality.series,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildModalitiesTab() {
    if (_modalities.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma modalidade encontrada',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _modalities.length,
      itemBuilder: (context, index) => _buildModalityCard(_modalities[index]),
    );
  }

  Widget _buildModalityCard(ModalityAggregated modality) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () {
          // Navigate based on whether it's a unique game or tournament
          if (modality.isUniqueGame == true) {
            // Navigate to game detail page for unique games
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameDetailPage(
                  modalityId: modality.id,
                  modalityName: '${modality.name} ${modality.gender}',
                  series: modality.series,
                ),
              ),
            );
          } else {
            // Navigate to games page for tournament brackets
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GamesPage(
                  modalityId: modality.id,
                  modalityName: '${modality.name} ${modality.gender}',
                ),
              ),
            );
          }
        },
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: modality.icon != null
                ? SvgPicture.asset(
                    'assets/icons/ic_${modality.icon}.svg',
                    colorFilter: const ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    ),
                    fit: BoxFit.contain,
                  )
                : const Icon(Icons.sports, color: AppColors.primary, size: 24),
          ),
        ),
        title: Text(
          '${modality.name} ${modality.gender}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _getModalityStatusColor(modality.modalityStatus),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            modality.modalityStatus,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'finished':
        return 'FINALIZADO';
      case 'live':
        return 'AO VIVO';
      case 'scheduled':
        return 'AGENDADO';
      default:
        return status.toUpperCase();
    }
  }

  Color _getModalityStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'concluída':
      case 'finalizada':
        return Colors.green;
      case 'em andamento':
      case 'em disputa':
        return Colors.orange;
      case 'programada':
      case 'não iniciada':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
