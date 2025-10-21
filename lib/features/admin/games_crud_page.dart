// lib/features/admin/games_crud_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:interufmt/core/data/repositories/athletes_repository.dart';
import 'package:interufmt/core/data/repositories/athletics_repository.dart';
import 'package:interufmt/core/data/repositories/games_repository.dart';
import 'package:interufmt/core/data/repositories/modalities_repository.dart';
import 'package:interufmt/core/data/repositories/venues_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GamesCrudPage extends StatefulWidget {
  static const String routename = 'games-crud';

  const GamesCrudPage({super.key});

  @override
  State<GamesCrudPage> createState() => _GamesCrudPageState();
}

class _GamesCrudPageState extends State<GamesCrudPage> {
  late GamesRepository _repository;
  late ModalitiesRepository _modalitiesRepository;
  late AthleticsRepository _athleticsRepository;
  late VenuesRepository _venuesRepository;

  List<Map<String, dynamic>> _games = [];
  List<Map<String, dynamic>> _filteredGames = [];
  List<Map<String, dynamic>> _modalities = [];
  List<Map<String, dynamic>> _athletics = [];
  List<Map<String, dynamic>> _venues = [];

  bool _isLoading = true;
  String _searchQuery = '';
  String _filterStatus = 'all'; // all, scheduled, inprogress, finished
  String _filterSeries = 'all'; // all, A, B

  @override
  void initState() {
    super.initState();
    _repository = GamesRepository(Supabase.instance.client);
    _modalitiesRepository = ModalitiesRepository(Supabase.instance.client);
    _athleticsRepository = AthleticsRepository(Supabase.instance.client);
    _venuesRepository = VenuesRepository(Supabase.instance.client);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final futures = await Future.wait([
        _repository.getAllGames(),
        _modalitiesRepository.getAllModalities(),
        _athleticsRepository.getAllAthleticsForCrud(),
        _venuesRepository.getAllVenuesForCrud(),
      ]);

      setState(() {
        _games = List<Map<String, dynamic>>.from(futures[0]);
        _modalities = List<Map<String, dynamic>>.from(futures[1]);
        _athletics = List<Map<String, dynamic>>.from(futures[2]);
        _venues = List<Map<String, dynamic>>.from(futures[3]);
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar jogos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    _filteredGames = _games.where((game) {
      // Apply search filter
      final modality = game['modalities'] as Map<String, dynamic>?;
      final modalityName = modality != null
          ? '${modality['name']} ${modality['gender']}'
          : '';

      final matchesSearch =
          _searchQuery.isEmpty ||
          modalityName.toLowerCase().contains(_searchQuery.toLowerCase());

      // Apply status filter
      final matchesStatus =
          _filterStatus == 'all' || game['status'] == _filterStatus;

      // Apply series filter
      final matchesSeries =
          _filterSeries == 'all' || game['series'] == _filterSeries;

      return matchesSearch && matchesStatus && matchesSeries;
    }).toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _onFilterChanged() {
    setState(() {
      _applyFilters();
    });
  }

  Future<void> _showCreateDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _GameFormDialog(
        repository: _repository,
        modalities: _modalities,
        athletics: _athletics,
        venues: _venues,
      ),
    );

    if (result == true) {
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jogo criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> game) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _GameFormDialog(
        repository: _repository,
        modalities: _modalities,
        athletics: _athletics,
        venues: _venues,
        game: game,
      ),
    );

    if (result == true) {
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jogo atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _showManageDialog(Map<String, dynamic> game) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            GameManagementPage(gameId: game['id'], game: game),
      ),
    );
    await _loadData();
  }

  Future<void> _showDeleteDialog(Map<String, dynamic> game) async {
    final modality = game['modalities'] as Map<String, dynamic>?;
    final modalityName = modality != null
        ? '${modality['name']} ${modality['gender']}'
        : 'Jogo';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir o jogo "$modalityName"?\n\nEsta ação excluirá todos os atletas e estatísticas associados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteGame(game['id']);
    }
  }

  Future<void> _deleteGame(String id) async {
    try {
      await _repository.deleteGame(id);
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jogo excluído com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir jogo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'scheduled':
        return 'Agendado';
      case 'inprogress':
      case 'in_progress':
        return 'Em Andamento';
      case 'finished':
        return 'Finalizado';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Jogos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por modalidade...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filterStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                    ),
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text('Todos', overflow: TextOverflow.ellipsis),
                      ),
                      DropdownMenuItem(
                        value: 'scheduled',
                        child: Text(
                          'Agendado',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'inprogress',
                        child: Text(
                          'Em Andamento',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'finished',
                        child: Text(
                          'Finalizado',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _filterStatus = value);
                        _onFilterChanged();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filterSeries,
                    decoration: const InputDecoration(
                      labelText: 'Série',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                    ),
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text('Todas', overflow: TextOverflow.ellipsis),
                      ),
                      DropdownMenuItem(
                        value: 'A',
                        child: Text('Série A', overflow: TextOverflow.ellipsis),
                      ),
                      DropdownMenuItem(
                        value: 'B',
                        child: Text('Série B', overflow: TextOverflow.ellipsis),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _filterSeries = value);
                        _onFilterChanged();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Games list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredGames.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sports_soccer,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Nenhum jogo encontrado'
                              : 'Nenhum jogo encontrado para "$_searchQuery"',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredGames.length,
                      itemBuilder: (context, index) {
                        final game = _filteredGames[index];
                        final modality =
                            game['modalities'] as Map<String, dynamic>?;
                        final venue = game['venues'] as Map<String, dynamic>?;
                        final aAthletic =
                            game['a_athletic'] as Map<String, dynamic>?;
                        final bAthletic =
                            game['b_athletic'] as Map<String, dynamic>?;

                        // Check if game is unique: a_athletic_id is null AND athletics_standings is not null
                        final isUniqueGame =
                            game['a_athletic_id'] == null &&
                            game['athletics_standings'] != null;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ExpansionTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  game['status'],
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isUniqueGame
                                    ? Icons.emoji_events
                                    : Icons.sports_soccer,
                                color: _getStatusColor(game['status']),
                              ),
                            ),
                            title: Text(
                              modality != null
                                  ? '${modality['name']} ${modality['gender']}'
                                  : 'Modalidade não encontrada',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                          game['status'],
                                        ).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        _getStatusText(game['status']),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: _getStatusColor(
                                            game['status'],
                                          ),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Série ${game['series']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 12,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('dd/MM/yyyy HH:mm').format(
                                        DateTime.parse(game['start_at']),
                                      ),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                if (venue != null) ...[
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 12,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          venue['name'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (isUniqueGame) ...[
                                      const Text(
                                        'Jogo Único (Rankings)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Este jogo usa rankings de atléticas',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ] else ...[
                                      const Text(
                                        'Times',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Column(
                                            children: [
                                              Text(
                                                aAthletic?['nickname'] ?? 'TBD',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '${game['score_a'] ?? 0}',
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Text(
                                            'X',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                bAthletic?['nickname'] ?? 'TBD',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '${game['score_b'] ?? 0}',
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      alignment: WrapAlignment.center,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () =>
                                              _showManageDialog(game),
                                          icon: const Icon(
                                            Icons.settings,
                                            size: 16,
                                          ),
                                          label: const Text('Gerenciar'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: () =>
                                              _showEditDialog(game),
                                          icon: const Icon(
                                            Icons.edit,
                                            size: 16,
                                          ),
                                          label: const Text('Editar'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: () =>
                                              _showDeleteDialog(game),
                                          icon: const Icon(
                                            Icons.delete,
                                            size: 16,
                                          ),
                                          label: const Text('Excluir'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('Novo Jogo'),
      ),
    );
  }
}

// Game Form Dialog
class _GameFormDialog extends StatefulWidget {
  final GamesRepository repository;
  final List<Map<String, dynamic>> modalities;
  final List<Map<String, dynamic>> athletics;
  final List<Map<String, dynamic>> venues;
  final Map<String, dynamic>? game;

  const _GameFormDialog({
    required this.repository,
    required this.modalities,
    required this.athletics,
    required this.venues,
    this.game,
  });

  @override
  State<_GameFormDialog> createState() => _GameFormDialogState();
}

class _GameFormDialogState extends State<_GameFormDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedModalityId;
  String? _selectedVenueId;
  String? _selectedAthleticA;
  String? _selectedAthleticB;
  String _selectedSeries = 'A';
  String _selectedStatus = 'scheduled';
  DateTime? _startAt;
  bool _isUniqueGame = false;
  List<String> _selectedAthleticsForRanking = [];
  bool _isLoading = false;

  // Score controllers
  final _scoreAController = TextEditingController();
  final _scoreBController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.game != null) {
      final game = widget.game!;
      final modality = game['modalities'] as Map<String, dynamic>?;
      final venue = game['venues'] as Map<String, dynamic>?;
      final aAthletic = game['a_athletic'] as Map<String, dynamic>?;
      final bAthletic = game['b_athletic'] as Map<String, dynamic>?;

      _selectedModalityId = modality?['id'];
      _selectedVenueId = venue?['id'];
      _selectedAthleticA = aAthletic?['id'];
      _selectedAthleticB = bAthletic?['id'];
      _selectedSeries = game['series'];
      _selectedStatus = game['status'];
      _startAt = DateTime.parse(game['start_at']);

      // Initialize scores
      if (game['score_a'] != null) {
        _scoreAController.text = game['score_a'].toString();
      }
      if (game['score_b'] != null) {
        _scoreBController.text = game['score_b'].toString();
      }

      // Determine if game is unique: a_athletic_id is null AND athletics_standings is not null
      _isUniqueGame =
          game['a_athletic_id'] == null && game['athletics_standings'] != null;

      if (_isUniqueGame && game['athletics_standings'] != null) {
        try {
          final standings = game['athletics_standings'];
          // Handle both Map and List formats
          if (standings is Map) {
            if (standings['id_atletics'] != null) {
              final idList = standings['id_atletics'] as List;
              _selectedAthleticsForRanking = idList
                  .map((id) => id.toString())
                  .toList();
            }
          } else if (standings is List) {
            // If it's already a list of IDs
            _selectedAthleticsForRanking = standings
                .map((id) => id.toString())
                .toList();
          }
        } catch (e) {
          print('Error loading athletics_standings: $e');
          _selectedAthleticsForRanking = [];
        }
      }
    }
  }

  @override
  void dispose() {
    _scoreAController.dispose();
    _scoreBController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startAt ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startAt ?? DateTime.now()),
      );

      if (time != null) {
        setState(() {
          _startAt = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedModalityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma modalidade'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_startAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione a data e hora'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_isUniqueGame &&
        (_selectedAthleticA == null || _selectedAthleticB == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione ambos os times'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isUniqueGame && _selectedAthleticsForRanking.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione pelo menos uma atlética para o ranking'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Parse scores
      final scoreA = _scoreAController.text.isNotEmpty
          ? int.tryParse(_scoreAController.text)
          : null;
      final scoreB = _scoreBController.text.isNotEmpty
          ? int.tryParse(_scoreBController.text)
          : null;

      if (widget.game == null) {
        // Create
        await widget.repository.createGame(
          modalityId: _selectedModalityId!,
          series: _selectedSeries,
          startAt: _startAt!,
          venueId: _selectedVenueId,
          aAthleticId: _isUniqueGame ? null : _selectedAthleticA,
          bAthleticId: _isUniqueGame ? null : _selectedAthleticB,
          athleticsStandings: _isUniqueGame
              ? {'id_atletics': _selectedAthleticsForRanking}
              : null,
          status: _selectedStatus,
        );
      } else {
        // Update - Use flags to clear fields when switching game types
        await widget.repository.updateGame(
          id: widget.game!['id'],
          modalityId: _selectedModalityId,
          series: _selectedSeries,
          startAt: _startAt,
          venueId: _selectedVenueId,
          // For bracket games, set team IDs. For unique games, clear them
          aAthleticId: _isUniqueGame ? null : _selectedAthleticA,
          bAthleticId: _isUniqueGame ? null : _selectedAthleticB,
          clearAthleticIds: _isUniqueGame,
          // Include scores
          scoreA: scoreA,
          scoreB: scoreB,
          // For unique games, set standings. For bracket games, clear them
          athleticsStandings: _isUniqueGame
              ? {'id_atletics': _selectedAthleticsForRanking}
              : null,
          clearAthleticsStandings: !_isUniqueGame,
          status: _selectedStatus,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.game != null;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(isEdit ? Icons.edit : Icons.add, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    isEdit ? 'Editar Jogo' : 'Novo Jogo',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Game Type Switch
                      SwitchListTile(
                        title: const Text('Jogo Único (Rankings)'),
                        subtitle: const Text(
                          'Para modalidades como xadrez que usam rankings',
                        ),
                        value: _isUniqueGame,
                        onChanged: (value) {
                          setState(() => _isUniqueGame = value);
                        },
                      ),

                      const SizedBox(height: 16),

                      // Modality dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedModalityId,
                        decoration: const InputDecoration(
                          labelText: 'Modalidade *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.sports),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        isExpanded: true,
                        items: widget.modalities
                            .map(
                              (modality) => DropdownMenuItem<String>(
                                value: modality['id'] as String,
                                child: Text(
                                  '${modality['name']} ${modality['gender']}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedModalityId = value);
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Modalidade é obrigatória';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Series and Status
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedSeries,
                              decoration: const InputDecoration(
                                labelText: 'Série *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(
                                  value: 'A',
                                  child: Text(
                                    'A',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'B',
                                  child: Text(
                                    'B',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedSeries = value;
                                    // Clear athletic selections when series changes
                                    // because athletics from one series won't be in the other
                                    _selectedAthleticA = null;
                                    _selectedAthleticB = null;
                                    _selectedAthleticsForRanking.clear();
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedStatus,
                              decoration: const InputDecoration(
                                labelText: 'Status *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.info),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(
                                  value: 'scheduled',
                                  child: Text(
                                    'Agendado',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'inprogress',
                                  child: Text(
                                    'Em Andamento',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'finished',
                                  child: Text(
                                    'Finalizado',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedStatus = value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Date and Time
                      InkWell(
                        onTap: _selectDateTime,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Data e Hora *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _startAt == null
                                ? 'Selecione a data e hora'
                                : DateFormat(
                                    'dd/MM/yyyy HH:mm',
                                  ).format(_startAt!),
                            style: TextStyle(
                              color: _startAt == null
                                  ? Colors.grey[600]
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Venue
                      DropdownButtonFormField<String>(
                        value: _selectedVenueId,
                        decoration: const InputDecoration(
                          labelText: 'Local',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        isExpanded: true,
                        items: widget.venues
                            .map(
                              (venue) => DropdownMenuItem<String>(
                                value: venue['id'] as String,
                                child: Text(
                                  venue['name'],
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedVenueId = value);
                        },
                      ),

                      const SizedBox(height: 16),

                      // Score fields (only for bracket games)
                      if (!_isUniqueGame) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _scoreAController,
                                decoration: const InputDecoration(
                                  labelText: 'Pontuação Time A',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.sports_score),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    final score = int.tryParse(value);
                                    if (score == null) {
                                      return 'Número inválido';
                                    }
                                    if (score < 0) {
                                      return 'Deve ser positivo';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _scoreBController,
                                decoration: const InputDecoration(
                                  labelText: 'Pontuação Time B',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.sports_score),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    final score = int.tryParse(value);
                                    if (score == null) {
                                      return 'Número inválido';
                                    }
                                    if (score < 0) {
                                      return 'Deve ser positivo';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      if (_isUniqueGame) ...[
                        // Athletics for Ranking
                        const Text(
                          'Atléticas Participantes *',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 300),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: widget.athletics
                                  .where((a) => a['series'] == _selectedSeries)
                                  .map((athletic) {
                                    final athleticId = athletic['id'] as String;
                                    final isSelected =
                                        _selectedAthleticsForRanking.contains(
                                          athleticId,
                                        );

                                    return CheckboxListTile(
                                      title: Text(
                                        athletic['nickname'] ??
                                            athletic['name'],
                                      ),
                                      value: isSelected,
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            _selectedAthleticsForRanking.add(
                                              athleticId,
                                            );
                                          } else {
                                            _selectedAthleticsForRanking.remove(
                                              athleticId,
                                            );
                                          }
                                        });
                                      },
                                    );
                                  })
                                  .toList(),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Athletic A
                        DropdownButtonFormField<String>(
                          value: _selectedAthleticA,
                          decoration: const InputDecoration(
                            labelText: 'Time A *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.shield),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          isExpanded: true,
                          items: widget.athletics
                              .where((a) => a['series'] == _selectedSeries)
                              .map(
                                (athletic) => DropdownMenuItem<String>(
                                  value: athletic['id'] as String,
                                  child: Text(
                                    athletic['nickname'] ?? athletic['name'],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedAthleticA = value);
                          },
                          validator: (value) =>
                              value == null ? 'Selecione o Time A' : null,
                        ),

                        const SizedBox(height: 16),

                        // Athletic B
                        DropdownButtonFormField<String>(
                          value: _selectedAthleticB,
                          decoration: const InputDecoration(
                            labelText: 'Time B *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.shield),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          isExpanded: true,
                          items: widget.athletics
                              .where((a) => a['series'] == _selectedSeries)
                              .map(
                                (athletic) => DropdownMenuItem<String>(
                                  value: athletic['id'] as String,
                                  child: Text(
                                    athletic['nickname'] ?? athletic['name'],
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedAthleticB = value);
                          },
                          validator: (value) =>
                              value == null ? 'Selecione o Time B' : null,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isEdit ? 'Salvar' : 'Criar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Game Management Page (for athletes and stats)
class GameManagementPage extends StatefulWidget {
  final String gameId;
  final Map<String, dynamic> game;

  const GameManagementPage({
    super.key,
    required this.gameId,
    required this.game,
  });

  @override
  State<GameManagementPage> createState() => _GameManagementPageState();
}

class _GameManagementPageState extends State<GameManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modality = widget.game['modalities'] as Map<String, dynamic>?;
    final modalityName = modality != null
        ? '${modality['name']} ${modality['gender']}'
        : 'Jogo';

    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciar: $modalityName'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Atletas', icon: Icon(Icons.person)),
            Tab(text: 'Estatísticas', icon: Icon(Icons.bar_chart)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AthletesTab(gameId: widget.gameId, game: widget.game),
          _StatisticsTab(gameId: widget.gameId, game: widget.game),
        ],
      ),
    );
  }
}

// Athletes Tab (placeholder - will be implemented next)
class _AthletesTab extends StatefulWidget {
  final String gameId;
  final Map<String, dynamic> game;

  const _AthletesTab({required this.gameId, required this.game});

  @override
  State<_AthletesTab> createState() => _AthletesTabState();
}

class _AthletesTabState extends State<_AthletesTab> {
  late GamesRepository _gamesRepository;
  late AthletesRepository _athletesRepository;

  List<Map<String, dynamic>> _gameAthletes = [];
  List<Map<String, dynamic>> _availableAthletes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _gamesRepository = GamesRepository(Supabase.instance.client);
    _athletesRepository = AthletesRepository(Supabase.instance.client);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final athletes = await _gamesRepository.getGameAthletes(widget.gameId);

      // Get all available athletes
      final allAthletes = await _athletesRepository.getAllAthletes();

      setState(() {
        _gameAthletes = athletes;
        _availableAthletes = allAthletes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar atletas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showAddAthleteDialog() async {
    // Filter out athletes already in the game
    final athletesInGame = _gameAthletes
        .map((a) => (a['athletes'] as Map<String, dynamic>)['id'] as String)
        .toSet();

    final availableToAdd = _availableAthletes
        .where((a) => !athletesInGame.contains(a['id']))
        .toList();

    if (availableToAdd.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todos os atletas já estão no jogo'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    String? selectedAthleteId;
    final shirtController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Atleta'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedAthleteId,
                decoration: const InputDecoration(
                  labelText: 'Atleta *',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                isExpanded: true,
                items: availableToAdd.map((athlete) {
                  final athletic =
                      athlete['athletics'] as Map<String, dynamic>?;
                  return DropdownMenuItem<String>(
                    value: athlete['id'] as String,
                    child: Text(
                      '${athlete['full_name']} - ${athletic?['nickname'] ?? ''}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedAthleteId = value;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: shirtController,
                decoration: const InputDecoration(
                  labelText: 'Número da Camisa *',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedAthleteId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Selecione um atleta'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final shirtNumber = int.tryParse(shirtController.text);
              if (shirtNumber == null || shirtNumber < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Número da camisa inválido'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                await _gamesRepository.addAthleteToGame(
                  gameId: widget.gameId,
                  athleteId: selectedAthleteId!,
                  shirtNumber: shirtNumber,
                );
                Navigator.pop(context, true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao adicionar atleta: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _loadData();
    }
  }

  Future<void> _removeAthlete(String athleteId, String athleteName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Atleta'),
        content: Text('Deseja remover $athleteName do jogo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _gamesRepository.removeAthleteFromGame(
          gameId: widget.gameId,
          athleteId: athleteId,
        );
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Atleta removido com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao remover atleta: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Atletas no Jogo (${_gameAthletes.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showAddAthleteDialog,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Atleta'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _gameAthletes.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhum atleta adicionado ao jogo',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _gameAthletes.length,
                  itemBuilder: (context, index) {
                    final athleteGame = _gameAthletes[index];
                    final athlete =
                        athleteGame['athletes'] as Map<String, dynamic>;
                    final athletic =
                        athlete['athletics'] as Map<String, dynamic>?;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          backgroundImage: athletic?['logo_url'] != null
                              ? AssetImage(
                                  'assets/images/${athletic!['logo_url']}',
                                )
                              : null,
                          child: athletic?['logo_url'] == null
                              ? Text(
                                  '${athleteGame['shirt_number']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        title: Text(athlete['full_name'] as String),
                        subtitle: Text(
                          '${athletic?['name'] ?? 'Sem atlética'} - Camisa #${athleteGame['shirt_number']}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeAthlete(
                            athlete['id'] as String,
                            athlete['full_name'] as String,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// Statistics Tab (placeholder - will be implemented next)
class _StatisticsTab extends StatefulWidget {
  final String gameId;
  final Map<String, dynamic> game;

  const _StatisticsTab({required this.gameId, required this.game});

  @override
  State<_StatisticsTab> createState() => _StatisticsTabState();
}

class _StatisticsTabState extends State<_StatisticsTab> {
  late GamesRepository _repository;

  List<Map<String, dynamic>> _gameStats = [];
  List<Map<String, dynamic>> _statDefinitions = [];
  Map<String, Map<String, Map<String, dynamic>>> _athleteStats = {};
  List<Map<String, dynamic>> _gameAthletes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = GamesRepository(Supabase.instance.client);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final futures = await Future.wait([
        _repository.getGameStats(widget.gameId),
        _repository.getStatDefinitions(),
        _repository.getGameAthletes(widget.gameId),
      ]);

      _gameStats = futures[0];
      _statDefinitions = futures[1];
      _gameAthletes = futures[2];

      // Load athlete stats for each athlete
      final athleteStatsFutures = <Future<List<Map<String, dynamic>>>>[];
      for (final athleteGame in _gameAthletes) {
        final athlete = athleteGame['athletes'] as Map<String, dynamic>;
        athleteStatsFutures.add(
          _repository.getAthleteGameStats(
            gameId: widget.gameId,
            athleteId: athlete['id'] as String,
          ),
        );
      }

      final athleteStatsResults = await Future.wait(athleteStatsFutures);

      // Organize athlete stats by athlete ID and stat code
      for (int i = 0; i < _gameAthletes.length; i++) {
        final athlete = _gameAthletes[i]['athletes'] as Map<String, dynamic>;
        final athleteId = athlete['id'] as String;
        _athleteStats[athleteId] = {};

        for (final stat in athleteStatsResults[i]) {
          final statCode = stat['stat_code'] as String;
          _athleteStats[athleteId]![statCode] = stat;
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar estatísticas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateGameStat(String statCode, int currentValue) async {
    final controller = TextEditingController(text: currentValue.toString());

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Atualizar ${_getStatName(statCode)}'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Valor',
            suffix: Text(_getStatUnit(statCode)),
          ),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null) {
                Navigator.pop(context, value);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        await _repository.updateGameStat(
          gameId: widget.gameId,
          statCode: statCode,
          value: result,
        );
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Estatística atualizada com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao atualizar estatística: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _updateAthleteGameStat(
    String athleteId,
    String athleteName,
    String statCode,
    int currentValue,
  ) async {
    final controller = TextEditingController(text: currentValue.toString());

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$athleteName - ${_getStatName(statCode)}'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Valor',
            suffix: Text(_getStatUnit(statCode)),
          ),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null) {
                Navigator.pop(context, value);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        await _repository.updateAthleteGameStat(
          gameId: widget.gameId,
          athleteId: athleteId,
          statCode: statCode,
          value: result,
        );
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Estatística atualizada com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao atualizar estatística: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _getStatName(String statCode) {
    final stat = _statDefinitions.firstWhere(
      (s) => s['code'] == statCode,
      orElse: () => {'name': statCode},
    );
    return stat['name'] as String;
  }

  String _getStatUnit(String statCode) {
    final stat = _statDefinitions.firstWhere(
      (s) => s['code'] == statCode,
      orElse: () => {'unit': ''},
    );
    return stat['unit'] as String? ?? '';
  }

  int _getGameStatValue(String statCode) {
    final stat = _gameStats.firstWhere(
      (s) => s['stat_code'] == statCode,
      orElse: () => {'value': 0},
    );
    return stat['value'] as int? ?? 0;
  }

  int _getAthleteStatValue(String athleteId, String statCode) {
    return _athleteStats[athleteId]?[statCode]?['value'] as int? ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Estatísticas do Jogo'),
              Tab(text: 'Estatísticas dos Atletas'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [_buildGameStatsView(), _buildAthleteStatsView()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameStatsView() {
    if (_statDefinitions.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma definição de estatística disponível',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _statDefinitions.length,
      itemBuilder: (context, index) {
        final statDef = _statDefinitions[index];
        final statCode = statDef['code'] as String;
        final statName = statDef['name'] as String;
        final statUnit = statDef['unit'] as String? ?? '';
        final value = _getGameStatValue(statCode);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(statName),
            subtitle: statDef['description'] != null
                ? Text(statDef['description'] as String)
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$value $statUnit',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _updateGameStat(statCode, value),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAthleteStatsView() {
    if (_gameAthletes.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum atleta adicionado ao jogo',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    if (_statDefinitions.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma definição de estatística disponível',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _gameAthletes.length,
      itemBuilder: (context, index) {
        final athleteGame = _gameAthletes[index];
        final athlete = athleteGame['athletes'] as Map<String, dynamic>;
        final athleteId = athlete['id'] as String;
        final athleteName = athlete['full_name'] as String;
        final athletic = athlete['athletics'] as Map<String, dynamic>?;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[200],
              backgroundImage: athletic?['logo_url'] != null
                  ? AssetImage('assets/images/${athletic!['logo_url']}')
                  : null,
              child: athletic?['logo_url'] == null
                  ? Text(
                      '${athleteGame['shirt_number']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            title: Text(athleteName),
            subtitle: Text(
              '${athletic?['name'] ?? 'Sem atlética'} - Camisa #${athleteGame['shirt_number']}',
            ),
            children: _statDefinitions.map((statDef) {
              final statCode = statDef['code'] as String;
              final statName = statDef['name'] as String;
              final statUnit = statDef['unit'] as String? ?? '';
              final value = _getAthleteStatValue(athleteId, statCode);

              return ListTile(
                title: Text(statName),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$value $statUnit',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _updateAthleteGameStat(
                        athleteId,
                        athleteName,
                        statCode,
                        value,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
